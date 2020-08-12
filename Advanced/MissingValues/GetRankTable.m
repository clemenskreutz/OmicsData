% [O,algos] = GetRankTable(O,rankby,plt)
%
% ranking of imputation algorithms
%
% O - @OmicsData object
% rankby - string of performance measure for algorithm ranking    ['RMSE']
%          (eg 'RMSE','RMSEt','F')
% plt  - flag for plotting performance of five best algorithms
%
% algos - cell array of ranked imputation algorithms
%
% Example:
% Oimp = impute(O);
% [Oimp,algo] = GetRankTable(Oimp);
% ODIMA = imputation_original(O,algo);


function [O,algos] = GetRankTable(O,rankby,rankbyrank,plt)

if ~exist('rankby','var') || isempty(rankby)
    rankby = 'RMSE';
end
if ~exist('rankbyrank','var') || isempty(rankbyrank)
    rankbyrank = true;
end
if ~exist('plt','var') || isempty(plt)
    plt = false;
end

%% Get
Tab = get(O,'Table',true);
if isempty(Tab) % if GetTable hasn't been performed before
    O = GetTable(O);
    Tab = get(O,'Table',true);
    if isempty(Tab)
        warning('Imputations failed or are not findable in O.')
        return
    end
end
method = get(O,'method_imput');
npat = size(Tab,3);

if size(Tab,2)>length(method)
    Tab = Tab(:,2:end,:); % clear 0 first column
end



%% find lowest rank
if ~isnumeric(rankby)
    if strcmp(rankby,'RMSE')
        n = 6;
    elseif contains(rankby,'RMSEt')  || contains(rankby,'ttest')
        n=11; % Sort by RMSEttest instead of RMSE
    elseif contains(rankby,'p') || contains(rankby,'F')
        n=8;
    else
        warning(['\n Ranking critera ' rankby 'not known. Not Ranked!\n']);
        return
    end
else
    if rankby>size(Tab,1)
        warning(['\n Ranking criteria ' num2str(rankby) ' too large. What do you mean? Not Ranked!\n']);
        return
    end
    n = rankby;
end

%% Rank
if rankbyrank
    idx = ones(npat,size(Tab,2))*size(Tab,2);    
    idboot = zeros(npat,size(Tab,2));
    for b=1:npat
        [~,idx(b,:)] = sort(Tab(n,:,b),'MissingPlacement','last'); % idx(:,1) is best algo
        idboot(b,idx(b,:)) = 1:size(Tab,2);                        % idboot==1 is best algo
    end
    idboot(idboot==0) = size(Tab,2);
    if npat==1
        [rank,idxrank] = sort(idboot,2,'MissingPlacement','last'); 
    else
        [rank,idxrank] = sort(mean(idboot,'omitnan'),2,'MissingPlacement','last'); 
    end
else
    mu = mean(Tab(n,:,:),3,'omitnan');
    [rank,idxrank] = sort(mu,2,'MissingPlacement','last'); 
end

T = mean(Tab(:,idxrank,:),3,'omitnan');
T(end+1,:) = rank;
algos = method(idxrank);

if size(T,1)>8
    T = T(5:end,:);
end

RowName = {'MeanError';'RMSE';'RSR';'pF';'Acc';'PCC';'time'};
if size(T,1)>8
    RowName = {RowName{:} 'RMSEt'};
end
RowName = {RowName{:} ['rank_' rankby]};
T = array2table(T,'VariableNames',algos,'RowNames', RowName);
O = set(O,'RankTable',T);
O = set(O,'RankMethod',algos);

if plt
    if exist([path filesep filename filesep 'Table_Rank.png'],'file')
        delete([path filesep filename filesep 'Table_Rank.png']);
    end
    figure
    uitable('Data',T{:,1:min(6,size(T,2))},'ColumnName',algos(1:min(6,size(T,2))),'RowName',RowName,'Units', 'Normalized', 'Position',[0, 0, 1, 0.38]);
    print(gcf,[path filesep filename filesep 'Table_Rank'],'-dpng','-r500');
end
