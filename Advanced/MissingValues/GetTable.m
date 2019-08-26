
function O = GetTable(O)

if ~exist('O','var')
    error('OmicsData object has to be passed in to function imputation_boxplot.m.')
end

% Get variables from class
dat = get(O,'data_complete');                % Complete dataset without missing values, to compare "right" solution
dat_mis_ges = get(O,'data_mis',true);        % simulated missing values       
if isempty(dat_mis_ges)
    dat_mis_ges = get(O,'data');
end
dat_imp_ges = get(O,'data_imput');           % Imputed data
meth = get(O,'method_imput');
method = meth.name;
t = get(O,'time_imput'); 


if ~isempty(dat_imp_ges)

    Tsave = nan(11,size(dat_imp_ges,4)+1,size(dat_mis_ges,3));

    for b=1:size(dat_mis_ges,3)
        dat_mis = dat_mis_ges(:,:,b);
        dat_imp = dat_imp_ges(:,:,b,:);
        
        % Columns of just imputed data
        Y = dat(isnan(dat_mis));                         % for complete data
        X = nan(size(Y,1),size(dat_imp,4));
        for i=1:size(dat_imp,4)
            im = dat_imp(:,:,1,i);
            X(:,i) = im(isnan(dat_mis));                 % for imputed data
        end
        if length(Y)<20 || sum(sum(~isnan(X)))<20        % if too less data
            continue
        end
        
        % Initialize 
        T = table([nanmean(Y);nanstd(Y);nanmin(Y);nanmax(Y);0;0;0;0;0;0;0]);
        T.Properties.VariableNames = {'original'};
        T.Properties.RowNames = {'mean','std','min','max','MeanError','RMSE','RSR','F','Acc','PCC','time'};
        Diffm = nan(size(X,1),size(dat_imp,4));
        Diffrel = nan(size(X,1),size(dat_imp,4));
        Acc = nan(size(X,1),size(dat_imp,4));
        RMSE = nan(size(dat_imp,4),1);
        RSR = nan(size(dat_imp,4),1);
        F = nan(size(dat_imp,4),1);
        PCC = corrcoef([Y X],'Rows','complete');
        
        %% Calc performance measures per algorithm, write in Table
        for i=1:size(X,2)
            Quad = nansum(nansum(nansum((X(:,i)-Y).^2)));
            if all(isnan(dat_imp(:,:,:,i)))
                Quad = NaN;
            end
            Diffm(:,i) = X(:,i)-Y;
            Diffrel(:,i) = abs(Diffm(:,i)./Y);
            Dev = nansum(nansum(abs(Diffm(:,i))))/size(Y,1);
            MeanDiff = nansum(nansum(Diffm(:,i)))/size(Y,1);
            
            RMSE(i) = sqrt(Quad/size(Y,1)); 
            RSR(i) = RMSE(i)./nanstd(dat(:));
            F(i) = nansum((X(:,i)-nanmean(X(:,i))).^2)/sum(~isnan(X(:,i)))/nansum((Y-nanmean(Y)).^2)*sum(~isnan(Y));
            Acc(i) = length(find(Diffrel(:,i)<0.05))/size(Y,1)*100;   % #values <5% deviation to original value
            T = [T table([nanmean(X(:,i)); nanstd(X(:,i)); nanmin(X(:,i)); nanmax(X(:,i)); Dev; RMSE(i); RSR(i); F(i); Acc(i); PCC(i+1,1); t(i)])];
            T.Properties.VariableNames(i+1) = erase(method(i),'.');
        end
        Tsave(:,:,b) = T{:,:};
    end
    
    %% Save
    O = set(O,'Table',Tsave);
end

