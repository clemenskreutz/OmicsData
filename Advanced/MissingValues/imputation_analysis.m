% function [T,p] = imputation_analysis(plt)
%
% plt - plot&save boxplot&histogram of Original vs imputed      [true]
%
% Output:
% T - Table of mean/std/min/max/diff/leastsqaures of original and imputed data

function imputation_analysis(plt)

global O

if ~exist('O','var')
    error('OmicsData object has to be passed in to function imputation_boxplot.m.')
end
if ~exist('plt','var') || isempty('plt')
    plt = true;
end


% Get variables from class
dat = get(O,'data_full');                % Complete dataset without missing values, to compare "right" solution
dat_sim_mis = get(O,'data_mis');         % simulated missing values
mispat = isnan(dat_sim_mis);             % simulated missing pattern                
Imp = get(O,'data_imput');               % Imputed data
method = get(O,'method_imput');
t = get(O,'time_imput'); 

if ~isempty(Imp)
    mispat = double(mispat);
    mispat(mispat==0)=nan;
    n_mis_row_rel = round(1- sum(isnan(mispat),2)/size(mispat,2),1);
    n_mis_row = sum(isnan(dat_sim_mis),2);

    % No method double ? Can happen by trying stuff.
    if length(unique(method)) < length(method)
        [uniqueM,~,ind] = unique(method);
        repeatedM = uniqueM(histc(ind,1:max(ind))>1);
        for i=1:length(repeatedM)
            [~,idxdouble] = find(strcmp(method,repeatedM{i}));
            method(idxdouble(2)) = [];
            Imp(:,:,:,idxdouble(2)) = [];
            O = set(O,'data_imput',Imp);
            O = set(O,'method_imput',method);
        end
    end

    % calculate just imputed values (before and after imputation)
    dat_mis_ges = nan(size(mispat,1),size(mispat,2),size(mispat,3));
    if length(size(dat))<3
        for nn = 1:size(mispat,3)
            dat_mis_ges(:,:,nn) = dat.*mispat(:,:,nn);
        end
    else
        dat_mis_ges = dat.*mispat;
    end
    dat_imp_ges = nan(size(Imp,1),size(Imp,2),size(Imp,3),size(Imp,4));
    for i=1:size(Imp,4)
        dat_imp_ges(:,:,:,i) = Imp(:,:,:,i).*mispat;
    end
    Tsave = nan(9,size(dat_imp_ges,4)+1,size(dat_mis_ges,3));

    for b=1:size(dat_mis_ges,3)
        dat_mis = dat_mis_ges(:,:,b);
        dat_imp = dat_imp_ges(:,:,b,:);
        method = get(O,'method_imput');
        % Columns of just imputed data
        Y = dat_mis(~isnan(dat_mis));
        X = nan(size(Y,1),size(dat_imp,4));
        for i=1:size(dat_imp,4)
            im = dat_imp(:,:,1,i);
            %if all(all(isnan(im),2))
            %    break
            %end
            X(:,i) = im(~isnan(dat_mis));
        end

        %% Table    
        T = table([nanmean(Y);nanstd(Y);nanmin(Y);nanmax(Y);0;0;0;0;0]);
        T.Properties.VariableNames = {'original'};
        T.Properties.RowNames = {'mean','std','min','max','MeanError','RMSE','Acc','PCC','time'};
        Diffm = nan(size(dat_imp,1),size(dat_imp,2),size(dat_imp,4));
        Diffrel = nan(size(dat_imp,1),size(dat_imp,2),size(dat_imp,4));
        Diffrow = nan(size(dat_imp,1),size(dat_imp,4));
        Quadrow = nan(size(dat_imp,1),size(dat_imp,4));
        Acc = nan(size(dat_imp,1),size(dat_imp,2),size(dat_imp,4));
        RMSE = nan(size(dat_imp,4),1);

        for i=1:size(dat_imp,4)
            Quad = 0;
            if length(size(dat_mis)) == 3
                Quad = Quad + sum(sum(nansum((dat_mis - dat_imp(:,:,:,i)).^2))); 
            elseif length(size(dat_mis)) == 2
                for j=1:size(dat_imp,3)
                    Quad = Quad + sum(nansum((dat_mis - dat_imp(:,:,j,i)).^2));
                end
            end
            if all(isnan(dat_imp(:,:,:,i)))
                Quad = NaN;
            end
            Diffm(:,:,i) = dat_imp(:,:,:,i)-dat_mis;
            Diffrel(:,:,i) = abs(dat_imp(:,:,:,i)-dat_mis)./dat_mis;
            Diffrow(:,i) = nansum(abs(dat_imp(:,:,:,i)-dat_mis),2);
            Quadrow(:,i) = sqrt( nansum((dat_imp(:,:,:,i)-dat_mis).^2,2) ./ n_mis_row(:,:,b) );
            RMSE(i) = sqrt(Quad/size(Y,1)); 

            Dev = nansum(nansum(abs(Diffm(:,:,i))))/size(Y,1);
            Acc = length(find(Diffrel(:,:,i)<0.05))/size(Y,1)*100;   % #values <5% deviation to original value
            PCC = corrcoef([Y X],'Rows','complete');
            T = [T table([nanmean(X(:,i)); nanstd(X(:,i)); nanmin(X(:,i)); nanmax(X(:,i)); Dev; RMSE(i); Acc; PCC(i+1,1); t(i)])];
            T.Properties.VariableNames(i+1) = method(i);
        end

        Tsave(:,:,b) = T{:,:};

        %% Sort imputation matrix by RMSE for plotting
        [~,idx] = sort(table2array(T(6,2:end)),'MissingPlacement','last');

        T = [T(:,1) T(:,idx+1)]
        dat_imp = dat_imp(:,:,:,idx);
        Diffm = Diffm(:,:,idx);
        Diffrow = Diffrow(:,idx);

        Quadrow = Quadrow(:,idx);
        X = X(:,idx);
        method = method(idx);
        Var = T(6,:);
        
        % Save path
        path = get(O,'path');
        [filepath,name] = fileparts(path);
        if exist([filepath '\' name '\' name '_Boxplot_Difference_' num2str(b) '.png'],'file')
            delete([filepath '\' name '\' name '_Boxplot_Difference_*.png']);
            delete([filepath '\' name '\' name '_Cloud_*.png']);
            delete([filepath '\' name '\' name '_Table*.png']);
        end

        %% Plot
        if plt

            Diffc = nan(size(X));
            for i=1:size(X,2)
                Diffc(:,i) = abs(X(:,i)-Y);
            end
            Diffc(:,all(isnan(Diffc)))=[];

            figure; set(gcf,'units','points','position',[10,10,380,300])
            plot(T{6,2:end},'rx','LineWidth',3)
            hold on;
            boxplot(Diffc,'Symbol','.','OutlierSize',4) %,'DataLim',[-0.01 15]) 
            set(gca,'XTick',1:size(dat_imp,4)+1);
            set(gca,'XTickLabel',method,'XTickLabelRotation',45, 'FontSize',11);  
            ylabel('|Imputed - Original|', 'FontSize',11)
            legend('RMSE')
            title('Imputation error', 'FontSize',15)
            %ylim([-0.1 15+0.1])
            fig=gcf;  print([filepath '/' name '/' name '_Boxplot_Difference_' num2str(b)],'-dpng','-r200');


             %% Correlation of imp/orig
             figure; set(gcf,'units','points','position',[10,10,500,300]) %('units','normalized','outerposition',[0 0 1 1]) 
             n=min([6,size(X,2)]);
             for i=1:n
                if all(isnan(X(:,i)))
                    break
                else
                    subplot(2,ceil(n/2),i)
                    scatter(Y,X(:,i),'.')
                    hold on
                    [anz,c] = hist3([Y(:),X(:,i)]);
                    contour(c{1},c{2},anz')
                    plot(nanmin(Y):nanmax(Y),nanmin(Y):nanmax(Y),'-r')
                    %plot(Y,X(:,i),'.')
                    xlabel('original')
                    xlim([nanmin(Y),nanmax(Y)])
                    ylim([nanmin(Y),nanmax(Y)])
                    ylabel('imputed')
                    title(method{i},'Interpreter','none')
                    text(0.05,0.9,['RMSE=' num2str(round(T{6,i+1},2))],'Units','normalized');
                    if ~isnan(T{8,i+1})
                        text(0.95,0.1,['PCC=' num2str(round(T{8,i+1},2))],'Units','normalized','HorizontalAlignment','right');
                    end
                end
             end
             fig=gcf;  print([filepath '/' name '/' name '_Cloud6_' num2str(b)],'-dpng','-r100');
        end

        uitable('Data',T{:,:},'ColumnName',T.Properties.VariableNames,'RowName',T.Properties.RowNames,'Units', 'Normalized', 'Position',[0, 0, 1, 1]);
        save([filepath '/' name '/Table.mat'],'T');
        fig =gcf;   print([filepath '/' name '/' name '_Table_' num2str(b)],'-dpng','-r100');

        %% Replace dat by best imputation method
        %O = set(O,'data',dat_imp(:,:,1,1),['Simulated dataset imputed with ' method{1}]);
    end

    O = set(O,'Table',Tsave);
end
GetRankTable;