% [O,algo] = GetRankTable(O,ttest)
%
% Takes field Table of class O and ranks imputation algorithms by RMSE
% creates field RankTable in object O
%

function [O,algo] = GetRankTable(O,ttest,rankRMSE)

if ~exist('ttest','var') || isempty(ttest)
    ttest = false;
end
if ~exist('rankRMSE','var') || isempty(rankRMSE)
    rankRMSE = false;
end

%% Get
if ~isfield(O,'Table') % if GetTable hasn't been performed before
    O = GetTable(O);
    if ttest
        O = RMSEttest(O);  
    end
    if ~isfield(O,'Table')
        warning('Imputations failed or are not findable in O.')
        return
    end
end

Tab = get(O,'Table');
Tab = Tab(:,2:end,:); % clear 0 first column

method = get(O,'method_imput');
%method = meth.name;

npat = size(Tab,3);

%% find lowest rank
if ttest
    n=11; % Sort by RMSEttest instead of RMSE
else
    n=6;
end

%% Rank
if rankRMSE
    RMSE = nanmean(Tab(n,:,:),3);
    [~,idxrank] = sort(RMSE,2,'MissingPlacement','last'); 
else
    idx = ones(npat,size(Tab,2))*size(Tab,2);    
    idboot = zeros(npat,size(Tab,2));
    for b=1:npat
        [~,idx(b,:)] = sort(Tab(n,:,b),'MissingPlacement','last'); 
      %  idx(b,end-sum(isnan(Tab(n,:,b)))+1:end) = size(Tab,2);
        idboot(b,idx(b,:)) = 1:size(Tab,2);
    end
    idboot(idboot==0) = size(Tab,2);
    if npat==1
        [~,idxrank] = sort(idboot,2,'MissingPlacement','last'); 
    else
        [~,idxrank] = sort(sum(idboot),2,'MissingPlacement','last'); 
    end
end

T = nanmean(Tab(5:end,idxrank,:),3);
algo = method(idxrank);

O = set(O,'RankTable',T);
O = set(O,'RankMethod',algo);

% plot Ranktable
path = get(O,'path');
[path,filename,~] = fileparts(path);
save([path filesep filename filesep 'RankTable.mat'],'T','algo')

RowName = {'MeanError';'RMSE';'F';'Acc';'PCC';'time'};
if size(T,1)>6
    RowName = {RowName{:} 'RMSEt'};
end

if exist([path filesep filename filesep 'Table_Rank.png'],'file')
    delete([path filesep filename filesep 'Table_Rank.png']);
end
figure
uitable('Data',T(:,1:min(6,size(T,2))),'ColumnName',algo(1:min(6,size(T,2))),'RowName',RowName,'Units', 'Normalized', 'Position',[0, 0, 1, 0.38]);
print(gcf,[path filesep filename filesep 'Table_Rank'],'-dpng','-r50');
