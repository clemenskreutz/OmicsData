
function O = GetTable(O)

if ~exist('O','var')
    error('OmicsData object has to be passed in to function GetTable.m.')
end

% Get variables from class
dat = get(O,'data_complete',true);                % Complete dataset without missing values, to compare "right" solution
if isempty(dat)
    dat = get(O,'data_full');
    dat = dat(:,:,1);
end
dat_mis = get(O,'data_mis',true);        % simulated missing values       
if isempty(dat_mis)
    dat_mis = get(O,'data');
end
dat_imp = get(O,'data_imput');           % Imputed data
method = get(O,'method_imput');
%method = meth.name;
t = get(O,'time_imput'); 

if ~isempty(dat_imp)
    Tsave = nan(11,size(dat_imp,4)+1,size(dat_mis,3));
    for b=1:size(dat_mis,3)
        % Columns of just imputed data
        Y = dat(isnan(dat_mis(:,:,b)));                         % for complete data     
        X = nan(size(Y,1),size(dat_imp,4));
        for i=1:size(dat_imp,4)
            im = dat_imp(:,:,b,i);
            X(:,i) = im(isnan(dat_mis(:,:,b)));                 % for imputed data
        end
        if sum(~isnan(Y))<20                                  % if too less data
            warning('Less than 20 MV imputed. Table not calculated.')
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
            if all(isnan(X(:,i)))
                T = [T table([nan(10,1); t(i)])];
            else
                Quad = nansum(nansum(nansum((X(:,i)-Y).^2)));
                Diffm(:,i) = X(:,i)-Y;
                Diffrel(:,i) = abs(Diffm(:,i)./Y);
                Dev = nansum(nansum(abs(Diffm(:,i))))/size(Y,1);
                %MeanDiff = nansum(nansum(Diffm(:,i)))/size(Y,1);

                RMSE(i) = sqrt(Quad/size(Y,1)); 
                RSR(i) = RMSE(i)./nanstd(dat(:));
                F(i) = nansum((X(:,i)-nanmean(X(:,i))).^2)/sum(~isnan(X(:,i)))/nansum((Y-nanmean(Y)).^2)*sum(~isnan(Y));
                Acc(i) = length(find(Diffrel(:,i)<0.05))/size(Y,1)*100;   % #values <5% deviation to original value
                T = [T table([nanmean(X(:,i)); nanstd(X(:,i)); nanmin(X(:,i)); nanmax(X(:,i)); Dev; RMSE(i); RSR(i); F(i); Acc(i); PCC(i+1,1); t(i)])];
            end
            T.Properties.VariableNames(i+1) = erase(method(i),'.');
        end
        Tsave(:,:,b) = T{:,:};
    end
    
    %% Save
    O = set(O,'Table',Tsave);
end

