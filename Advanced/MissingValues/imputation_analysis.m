% function [T,p] = imputation_analysis(plt)
%
% plt - plot&save boxplot&histogram of Original vs imputed      [true]
%
% Output:
% T - Table of mean/std/min/max/diff/leastsqaures of original and imputed data

function O = imputation_analysis(O,plt)

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
    Tsave = nan(10,size(dat_imp_ges,4)+1,size(dat_mis_ges,3));

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
        if length(Y)<10
            continue
        end
        %% Table    
        T = table([nanmean(Y);nanstd(Y);nanmin(Y);nanmax(Y);0;0;0;0;0;0]);
        T.Properties.VariableNames = {'original'};
        T.Properties.RowNames = {'mean','std','min','max','MeanError','RMSE','F','Acc','PCC','time'};
        Diffm = nan(size(X,1),size(dat_imp,4));
        Diffrel = nan(size(X,1),size(dat_imp,4));
        Acc = nan(size(X,1),size(dat_imp,4));
        RMSE = nan(size(dat_imp,4),1);
        F = nan(size(dat_imp,4),1);
        PCC = corrcoef([Y X],'Rows','complete');
        
        for i=1:size(dat_imp,4)
%             Quad = 0;
%             if length(size(dat_mis)) == 3
%                 Quad = Quad + sum(sum(nansum((dat_mis - dat_imp(:,:,:,i)).^2))); 
%             elseif length(size(dat_mis)) == 2
%                 for j=1:size(dat_imp,3)
%                     Quad = Quad + sum(nansum((dat_mis - dat_imp(:,:,j,i)).^2));
%                 end
%             end
            Quad = nansum(nansum(nansum((X(:,i)-Y).^2)));
            if all(isnan(dat_imp(:,:,:,i)))
                Quad = NaN;
            end
            Diffm(:,i) = X(:,i)-Y;
            Diffrel(:,i) = abs(Diffm(:,i)./Y);
            Dev = nansum(nansum(abs(Diffm(:,i))))/size(Y,1);
            MeanDiff = nansum(nansum(Diffm(:,i)))/size(Y,1);
            
            RMSE(i) = sqrt(Quad/size(Y,1)); 
            F(i) = nansum((X(:,i)-nanmean(X(:,i))).^2)/sum(~isnan(X(:,i)))/nansum((Y-nanmean(Y)).^2)*sum(~isnan(Y));
            %Acc(i) = nansum(Diffrel(:,i))/size(Y,1)*100;
            Acc(i) = length(find(Diffrel(:,i)<0.05))/size(Y,1)*100;   % #values <5% deviation to original value
            T = [T table([nanmean(X(:,i)); nanstd(X(:,i)); nanmin(X(:,i)); nanmax(X(:,i)); Dev; RMSE(i); F(i); Acc(i); PCC(i+1,1); t(i)])];
            T.Properties.VariableNames(i+1) = method(i);
        end

        Tsave(:,:,b) = T{:,:};

        %% Sort imputation matrix by RMSE for plotting
        [~,idx] = sort(table2array(T(6,2:end)),'MissingPlacement','last');

        T = [T(:,1) T(:,idx+1)]
        dat_imp = dat_imp(:,:,:,idx);

        X = X(:,idx);
        method = method(idx);
        
        % Save path
        path = get(O,'path');
        [filepath,name] = fileparts(path);
        if exist([filepath '\' name '\' name '_Boxplot_Difference_' num2str(b) '.png'],'file')
            delete([filepath '\' name '\' name '_Boxplot_Difference_*.png']);
            delete([filepath '\' name '\' name '_Cloud*.png']);
            delete([filepath '\' name '\' name '_Table*.png']);
        end

        %% Plot
        if plt

            Diffc = nan(size(X));
            for i=1:size(X,2)
                Diffc(:,i) = abs(X(:,i)-Y);
            end
            Diffc(:,all(isnan(Diffc)))=[];

            figure; set(gcf,'units','normalized','outerposition',[0 0 0.3 0.5]); %set(gcf,'units','points','position',[10,10,380,300])
            boxplot(Diffc,'PlotStyle','compact','Symbol','.','DataLim',[0 5])
            %violin(Diffc,'facecolor',[0 0 1],'facealpha',1,'medc','','mc','k','bw',0.05);
            hold on;
            p2 = plot(T{6,2:end},'rd','MarkerFaceColor','r','LineWidth',1);
            ylim([-0.02 5.05])
            set(gca,'XTick',1:size(dat_imp,4)+1);
            set(gca,'XTickLabel',method,'XTickLabelRotation',45, 'FontSize',14);  
            ylabel('|Imputed - Original|', 'FontSize',14)
            legend(p2,'Location','northwest','RMSE')
            title('Imputation error', 'FontSize',18)
            %set(gca,'FontSize', 20)
            print([filepath '/' name '/' name '_Boxplot_Difference_' num2str(b)],'-dpng','-r100');


             %% Correlation of imp/orig
             figure; set(gcf,'units','normalized','outerposition',[0 0 .5 .8])%set(gcf,'units','points','position',[10,10,600,300]) % 
             n = [1,round(size(X(~all(isnan(X))),2)/2),size(X(~all(isnan(X))),2)];
             %limin = min(nanmin(Y),min(nanmin(X(:,1:n)))); limax = max(nanmax(Y),max(nanmax(X(:,1:n))));
             bottom = 0; top = 13;
             myColorMap = jet(256);
             myColorMap(1:5,:) = 1;
           
             for j=1:length(n)               
                 i = n(j);
                 if all(isnan(X(:,i)))
                    break
                 else
                    subplot(2,ceil(length(n)/2),j)
                    hold on
                    xlabel('original')
                    ylabel('imputed')
                    [anz,c] = hist3([Y(:),X(:,i)],'Nbins',[70,70]);
                    max(max(anz))
                    wx=c{1}(:);
                    wy=c{2}(:);
                    colormap(myColorMap);
                    caxis manual
                    caxis([bottom top]);
                    H = pcolor(wx, wy, anz');
                    shading interp
                    set(H,'edgecolor','none');
                    %contour(c{1},c{2},anz','ShowText','on');%,[50 75 95]);
                    limin = min(nanmin(Y),min(nanmin(X(:,i)))); limax = max(nanmax(Y),max(nanmax(X(:,i))));
                    plot(limin:limax,limin:limax,'-r')
                    xlim([limin,limax])
                    ylim([limin,limax])
                    title(method{i},'Interpreter','none')                    
    %                             text(0.05,0.9,['RMSE=' num2str(round(T{6,i+1},2))],'Units','normalized','FontSize', 18);
    %                             if ~isnan(T{9,i+1})
    %                                 text(0.95,0.1,['PCC=' num2str(round(T{9,i+1},2))],'Units','normalized','HorizontalAlignment','right','FontSize', 18);
    %                             end
                    set(gca,'FontSize', 12)
                end
            end
             subplot(2,2,4)
             histogram(Y,limin:0.3:limax,'DisplayStyle','stairs','LineWidth',3);
             hold on;
             for j=1:length(n)
                 ii=n(j);
                 histogram(X(:,ii),limin:0.3:limax,'DisplayStyle','stairs','LineWidth',1.5);  
             end
             xlabel('intensity')
             ylabel('counts')
             title('Distribution')
            hp4 = get(gca,'Position');
            set(gca,'FontSize', 12)
            %legend({'Ori','Seq','mFo','Ame','Nor','kNN'},'Interpreter','none','Position',[hp4(1)+hp4(3)*2/3 hp4(2)+0.11 hp4(3)/2.5 hp4(3)*0.8],'FontSize',18);
            legend([{'original'},method{n}],'Interpreter','none','FontSize',12,'Position',[hp4(1)+hp4(3)/2 hp4(2)+0.13 hp4(3)/2.5 hp4(3)*0.5])
            print([filepath '/' name '/' name '_Cloud6_' num2str(b)],'-dpng','-r100');
        end

        uitable('Data',T{:,:},'ColumnName',T.Properties.VariableNames,'RowName',T.Properties.RowNames,'Units', 'Normalized', 'Position',[0, 0, 1, 1]);
        save([filepath '/' name '/Table.mat'],'T');
        print([filepath '/' name '/' name '_Table_' num2str(b)],'-dpng','-r100');

        %% Replace dat by best imputation method
        O = set(O,'data',dat_imp(:,:,1,1),['Simulated dataset imputed with ' method{1}]);
    end
    figure
    dat_original = get(O,'data_original');
    histogram(dat_original)
    hold on
    histogram(dat)
    histogram(dat_sim_mis)
    histogram(Imp(:,:,:,idx(1)));
    legend('Original','Complete','Simulated','Imputed')
    print([filepath '/' name '/' name '_Histogram'],'-dpng','-r100');
    
    O = set(O,'Table',Tsave);
end

