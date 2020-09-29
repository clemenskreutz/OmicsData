% [O,algo] = GetTable(O,[rankby,RMSEttest,group])
%
% Creates table to display performance of imputation algorithms within DIMA
%
% O - OmicsData class object
% rankby - string of performance measure which should serve as rank 
% criterion                                                        ['RMSE']
% RMSEttest - flag if RMSE of ttest should be calculated           [false]
% group - indices for ttest                             
%
% algo - imputation algorithms ranked by 'rankby'

function [O,algo] = GetTable(O,rankby,RMSEttest,group)

if ~exist('O','var')
    error('OmicsData object has to be passed in to function GetTable.m.')
end
if ~exist('rankby','var') || isempty(rankby)
    rankby = 'RMSE';
end
if ~exist('RMSEttest','var') || isempty(RMSEttest)
    if strcmp(rankby,'RMSEt')
        RMSEttest = true;
    else
        RMSEttest=false;
    end
end
if exist('group','var')
    if length(size(group))==1 % if number of clusters is given, do clustering to get sample indices of group
        O = set(O,'data',get(O,'data_original'),'Set to original');
        erg = clusterR(O,group,2);
        group = erg.samplecluster==1;
        group(2,:) = erg.samplecluster==2;
    end
elseif RMSEttest % find 2 clusters if no info is given
        O = set(O,'data',get(O,'data_original'),'Set to original');
        erg = clusterR(O,2,2);     
        group(1,:) = (erg.samplecluster==1)';
        group(2,:) = (erg.samplecluster==2)';
end

% Get variables from class
comp = get(O,'data_complete');                % Complete dataset without missing values, to compare "right" solution
imp = get(O,'data_imput');           % Imputed data
mis = get(O,'data_mis');

method = get(O,'method_imput');

if ~isempty(imp)
    Dev = nan(size(imp,3),size(imp,4)); RMSE=Dev; RSR=Dev; pF=Dev; Acc=Dev; PCC=Dev; RMSEt=Dev;
    for p=1:size(imp,3) % for each pattern S of MV
        if RMSEttest
            for i=1:size(comp,1)
                [~,~,~,stat] = ttest2(comp(i,group(1,:)),comp(i,group(2,:)));
                t(i) = stat.tstat;
            end
            t(isinf(t)) = nan;
        end
        for a=1:size(imp,4)  % for each imputation algorithm
            im = imp(:,:,p,a);
            if ~all(isnan(im))
                ndata = sum(sum(isnan(mis(:,:,p)) & ~isnan(comp))); % # data values which are compared here
                Diff = im-comp;
                Dev(p,a) = sum(sum(abs(Diff),'omitnan'),'omitnan')/ndata;
                RMSE(p,a) = sqrt(sum(sum(Diff.^2,'omitnan'),'omitnan'))/ndata; 
                RSR(p,a) = RMSE(p,a)/std(comp(:),'omitnan');
                [~,pF(p,a)] = vartest2(im(:),comp(:));
                Acc(p,a) = length(find(abs(Diff./comp)<0.05))/size(O,1)/size(O,2)*100;
                cor = corrcoef([im(:) comp(:)],'Rows','complete');
                PCC(p,a) = cor(2,1);
                if RMSEttest
                    for i=1:size(comp,1)
                        [~,~,~,statm] = ttest2(im(i,group(1,:)),im(i,group(2,:)));
                        tm(i) = statm.tstat;
                    end
                    tm(isinf(tm)) = nan;
                    RMSEt(p,a) = sqrt( sum((t-tm).^2,'omitnan') /sum(~isnan(t) & ~isnan(tm)));
    %                 if isinf(RMSEt(p,a))
    %                     fprintf('Infinite value in RMSEttest.m')
    %                 end
                end
            end
        end
    end

    %% Rank algorithms
    %if rankbyrank
    
        idx = ones(p,a);    
        idboot = zeros(p,a);
        try
            eval(['rankcriterion = ',rankby,';']);
        catch
            error(['Could not find ' rankby ' as ranking variable. Try another like Dev,RMSE,RSR,pF,Acc,PCC,RMSEt, or add your ranking criterion in the previous section.']);
        end
        for p=1:size(imp,3)
            if strncmp(rankby,'p',1)
                [~,idx(p,:)] = sort(rankcriterion(p,:),'descend','MissingPlacement','last'); 
            else
                [~,idx(p,:)] = sort(rankcriterion(p,:),'MissingPlacement','last'); % idx(:,1) is best algo
            end
            idboot(p,idx(p,:)) = 1:a;                        % idboot==1 is best algo
        end
        idboot(idboot==0) = a;
        if p==1
            [rank,rankidx] = sort(idboot,2,'MissingPlacement','last'); 
        else
            [rank,rankidx] = sort(mean(idboot,'omitnan'),2,'MissingPlacement','last'); 
        end

    %else  % Rank by mean instead of doing a ranking of each pattern
    %    mu = mean(RMSE,2,'omitnan');
    %    [rank,rankidx] = sort(mu,2,'MissingPlacement','last'); 
    %end
    M = [nanmean(Dev);nanmean(RMSE);nanmean(RSR);nanmean(pF);nanmean(Acc);nanmean(PCC)];
    RowNames = {'MeanError';'RMSE';'RSR';'pF';'Acc';'PCC'};
    if RMSEttest
        M = [M; nanmean(RMSEt)];
        RowNames = [RowNames;'RMSEt'];
    end
    M = [M(:,rankidx); rank];
    algo = method(rankidx);
    RowNames = [RowNames;'rank'];
    T = array2table(M,'VariableNames',algo,'RowNames',RowNames);

    %% Save
    O = set(O,'RankTable',T);
    O = set(O,'RankMethod',algo);
    O = set(O,'rankidx',rankidx);
    O = set(O,'DIMA',algo(1));
end

