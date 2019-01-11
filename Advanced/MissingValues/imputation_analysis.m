% function [T,p] = imputation_analysis(log,plt)
%
% log - logging data before analysis?       [true, if range(dat)>10^3]
% plt - plot&save boxplot&histogram of Original vs imputed      [true]
%
% Output:
% T - Table of mean/std/min/max/diff/leastsqaures of original and imputed data

function imputation_analysis(log,plt)

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

mispat = double(mispat);
mispat(mispat==0)=nan;
n_mis_row_rel = round(1- sum(isnan(mispat),2)/size(mispat,2),1);
n_mis_row = sum(isnan(dat_sim_mis),2);

% No method double ? Can happen by trying stuff.
if length(unique(method)) < length(method)
    [uniqueM,~,ind] = unique(method);
    repeatedM = uniqueM(histc(ind,1:max(ind))>1);
    for i=1:length(repeatedM)
        [~,idxdouble] = find(strcmp(method,repeatedM));
        method(idxdouble(2)) = [];
        Imp(:,:,:,idxdouble(2)) = [];
        O = set(O,'data_imput',Imp);
        O = set(O,'method_imput',method);
    end
end

% calculate just imputed values (before and after imputation)
dat_mis_ges = nan(size(mispat,1),size(mispat,2),size(mispat,3));
for nn = 1:size(mispat,3)
    dat_mis_ges(:,:,nn) = dat.*mispat(:,:,nn);
end
dat_imp_ges = nan(size(Imp,1),size(Imp,2),size(Imp,3),size(Imp,4));
for i=1:size(Imp,4)
    dat_imp_ges(:,:,:,i) = Imp(:,:,:,i).*mispat;
end
Tsave = nan(9,length(method)+1,size(dat_mis_ges,3));

for b=1:size(dat_mis_ges,3)
    dat_mis = dat_mis_ges(:,:,b);
    dat_imp = dat_imp_ges(:,:,b,:);
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

    % Log ? (Ist schon!)
    if ~exist('log','var') || isempty(log)
        if range(dat)>10^30
            log = true;
        else, log = false;
        end
    end
    if log   
        Y(Y<=0) = nan;  % for dat<0, log is ignored
        Y = log10(Y);
        X(Y<=0) = nan;  % just nan where X<0
        X(X<=0) = 1;  % just nan where X<0
        X = log10(X);
    end
    if log   
        dat_mis(dat_mis<=0) = nan;  % for dat<0, log is ignored
        dat_mis = log10(dat_mis);
        dat_imp(dat_mis<=0) = nan;  % just nan where dat_mis<0
        dat_imp(dat_imp<=0) = 1;  % just nan where dat_mis<0
        dat_imp = log10(dat_imp);
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
        Diffm(:,:,i) = dat_imp(:,:,:,i)-dat_mis;
        Diffrel(:,:,i) = abs(dat_imp(:,:,:,i)-dat_mis)./dat_mis;
        Diffrow(:,i) = nansum(abs(dat_imp(:,:,:,i)-dat_mis),2);
        Quadrow(:,i) = sqrt( nansum((dat_imp(:,:,:,i)-dat_mis).^2,2) ./ n_mis_row(:,:,b) );
        RMSE(i) = sqrt(Quad/size(Y,1)); %/std(nanstd(dat)); 

        Dev = nansum(nansum(abs(Diffm(:,:,i))))/size(Y,1);
        Acc = length(find(Diffrel(:,:,i)<0.05))/size(Y,1)*100;   % #values <5% deviation to original value
        PCC = corrcoef([Y X]);
        %p = anova1([Y X(:,i)],[],'off');
        T = [T table([nanmean(X(:,i)); nanstd(X(:,i)); nanmin(X(:,i)); nanmax(X(:,i)); Dev; RMSE(i); Acc; PCC(i+1,1); t(i)])];
        T.Properties.VariableNames(i+1) = method(i);
    end

    Tsave(:,:,b) = T{:,:};
    
    %% Sort imputation matrix by RMSE for plotting
    [~,idx] = sort(table2array(T(6,2:end)));
    %del = sum(T{6,:}>3);
    %idx(end-del+1:end) = [];

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
    if ~exist([filepath '/' name],'dir')
        mkdir(filepath, name)
    end
    %save([filepath '/' name '/O.mat'],'O');


    %% Plot
    if plt

        % whole matrix
    %    plotmatrixpattern(dat_mis,dat_imp,T)
    %    fig=gcf;  print([filepath '/' name '/' name '_Matrix_Imp_' num2str(b)],'-dpng','-r50');

    %    plotmatrixpattern( [],Diffm,T);
    %    fig=gcf;  print([filepath '/' name '/' name '_Matrix_Imp_Diff_' num2str(b)],'-dpng','-r50');

    %% Boxplot RMSE
    percent = [0.2 0.5 0.8];
    figure('units','normalized','outerposition',[0 0 1 1])  
    for i=1:length(percent)
        a = Quadrow(find(n_mis_row_rel(:,:,b)==percent(i)),:);
        [~,idx2] = sort(median(a));
        subplot(1,length(percent),i)
        boxplot(a(:,idx2))
        set(gca,'XTickLabel',horzcat(method(idx2)),'FontSize',8,'XTickLabelRotation',45,'OuterPosition',get(gca,'OuterPosition')+[0 0.1 0 -0.1]); 
        %if i==1
            ylabel('$\overline{RMSE}$','Interpreter','latex')
        %end
        ylim([0 max(nanmax(Quadrow))])
        title([num2str(percent(i)*100) '% missing'])
    end
    fig=gcf;  print([filepath '/' name '/' name '_RMSE_boxplot_' num2str(b)],'-dpng','-r50');

    %% RMSE per algorithm
    figure
    plot(T{6,2:end},'o')
    set(gca,'XTick',1:size(T,2)-1);
    set(gca,'XTickLabel',horzcat(T.Properties.VariableNames),'FontSize',11);  
    ylabel('RMSE')
    title('Find best imputation method','FontSize',11)
    print([filepath '/' name '/' name '_RMSE_' num2str(b)],'-dpng','-r50');

    %% RMSE per missing value or mean
     meanquad = nan(11,size(Quadrow,2));
     x = 0:0.1:1;
     for i=1:11
        for j=1:size(Quadrow,2)
            meanquad(i,j) = nanmean(Quadrow(find(n_mis_row_rel(:,:,b)==round(i/10-0.1,1)),j));
            stdquad(i,j) = nanstd(Quadrow(find(n_mis_row_rel(:,:,b)==round(i/10-0.1,1)),j));
         end
     end
    for i=11:-1:1
        if all(all(isnan(meanquad(i,:))))
            meanquad(i,:) = [];
            stdquad(i,:) = [];
            x(i) = [];
        end
    end

     meandat = round(mean(dat,2));
     mi = round(min(meandat));
     ma = round(max(meandat));
     meandatquad = nan(ma-mi+1,size(Quadrow,2));
     meanmis = nan(ma-mi+1);
     Quadrow(isnan(Quadrow)) = 0;
     for i=0:ma-mi
        for j=1:size(Quadrow,2)
            meandatquad(i+1,j) = mean(Quadrow(find(meandat==i+mi),j));
            stddatquad(i+1,j) = std(Quadrow(find(meandat==i+mi),j));
            meanmis(i+1,j) = mean(n_mis_row_rel(find(meandat==i+mi),:,b));
        end
     end
     if j>5
        j=5;
     end
    % figure('units','normalized','outerposition',[0 0 1 1])  
    %  subplot(1,2,1)
    %  plot(x,fliplr(meanquad),'o-')                                                  % fliplr to have uppest legend correspond to uppest plot
    %  xlabel('Missing values')
    %  ylabel('$\overline{RMSE}$','Interpreter','latex')
    %   set(gca,'OuterPosition',get(gca,'OuterPosition')+[0 0.1 0 -0.1]);
    %  
    %  subplot(1,2,2)
    %  plot(mi:ma,fliplr(meandatquad),'o-')
    %  xlabel('Mean of row')
    %  ylabel('$\overline{RMSE}$','Interpreter','latex')
    method2 = fliplr(method);
    %  legend(method2,'Interpreter','none') %,'Location','northeastoutside')
    %   set(gca,'OuterPosition',get(gca,'OuterPosition')+[0 0.1 0 -0.1]);
    % fig=gcf;  print([filepath '/' name '/' name '_RMSE_' num2str(b)],'-dpng','-r50');

    %% RMSE for the first 5
    figure('units','normalized','outerposition',[0 0 1 1])  
    %  subplot(1,2,1)
     errorbar(fliplr(meanquad(:,1:j)),fliplr(stdquad(:,1:j)))
     xlabel('Missing values')
     ylabel('$\overline{RMSE}$','Interpreter','latex')
     text(1,nanmax(nanmax(meanquad))*1.05,'$\sum$RMSE','Interpreter','latex','FontSize',8)
     for i=1:j
         text(1.02,meanquad(end,i),num2str(round(T{6,i+1},2)))
     end
      set(gca,'OuterPosition',get(gca,'OuterPosition')+[0 0.1 0 -0.1]);

    %  subplot(1,2,2)
    %  plot(mi:ma,meandatquad(:,1:5),'o-')
    %  xlabel('Mean of row')
    %  ylabel('$\overline{RMSE}$','Interpreter','latex')
     legend(method2(end-j+1:end),'Interpreter','none')
      set(gca,'OuterPosition',get(gca,'OuterPosition')+[0 0.1 0 -0.1]);
    fig=gcf;  print([filepath '/' name '/' name '_RMSE5_' num2str(b)],'-dpng','-r50');

        %% Boxplot & Histogram
      %  figure; set(gca,'fontname','arial'); set(gcf,'units','points','position',[10,10,450,250])
       figure('units','normalized','outerposition',[0 0 1 1])  
        title('Difference to original value');  
        Diffc = nan(size(X));
        for i=1:size(X,2)
            if log
                Diffc(:,i) = X(:,i)-Y;
            else
                Diffc(:,i) = abs(X(:,i)-Y);
            end
            %Diff(:,:,:,i) = log10(abs(dat_imp(:,:,:,i)-dat_mis));
            %Diff = dat_imp(:,:,:,i)-dat_mis;
            histogram(Diffc(:,i),'FaceAlpha',0.2,'BinEdges',0:0.1:4)
            hold on
        end
        xlabel('Difference in Magnitude to original data')
        ylabel('Frequency')
        legend(method,'Interpreter','none')
        fig=gcf;  print([filepath '/' name '/' name '_Histogram_' num2str(b)],'-dpng','-r50');

    %     figure('units','normalized','outerposition',[0 0 1 1])  
    %     boxplot([Y X])
    %     set(gca,'XTick',1:size(dat_imp,4)+1);
    %     set(gca,'XTickLabel',horzcat('Original',method),'FontSize',8);  
    %     ylabel('data distribution')
    %     fig=gcf;  print([filepath '/' name '/' name '_Boxplot_data_' num2str(b)],'-dpng','-r50');

        figure; set(gcf,'units','points','position',[10,10,300,300])
        boxplot(Diffc) 
        set(gca,'XTick',1:size(dat_imp,4)+1);
        set(gca,'XTickLabel',method,'XTickLabelRotation',45, 'FontSize',11);  
        ylabel('Imputed - Original', 'FontSize',11)
        title('Imputation error', 'FontSize',15)
        fig=gcf;  print([filepath '/' name '/' name '_Boxplot_Difference_' num2str(b)],'-dpng','-r200');

        %% Compare columns of imputed data

        % Compare differences to original value, as column
        figure; set(gca,'fontname','arial'); set(gcf,'units','points','position',[10,10,500,300])
        %figure('units','normalized','outerposition',[0 0 1 1])  
        imagesc([Y-Y Diffc].')  % imagesc([Y X].') original values
        title('Comparison of imputation methods','FontSize',11);  
        set(gca,'YTick',1:size(dat_imp,4)+1);
        set(gca,'YTickLabel',horzcat('Original',method),'TickLabelInterpreter','none','FontSize',11);  
        xlabel('data index','FontSize',11)
        set(gca, 'XTickLabel', [])
        c=colorbar('FontSize',11); % autoumn
        colormap pink
        c.Label.String = 'Difference in magnitude';
        fig=gcf;  print([filepath '/' name '/' name '_Diff_column_' num2str(b)],'-dpng','-r100');

         %% Correlation of imp/orig
         figure('units','normalized','outerposition',[0 0 1 1]) 
         for i=1:size(X,2)
            subplot(2,ceil(size(X,2)/2),i)
            plot(Y,X(:,i),'.')
            xlabel('original')
            xlim([6,11])
            ylim([6,11])
            ylabel('imputed')
            title(method{i},'Interpreter','none')
            text(6.3,10.7,['RMSE=' num2str(round(RMSE(i),1))]);
            text(9.3,6.3,['PCC=' num2str(round(PCC(i+1,1),2))]);
         end
         fig=gcf;  print([filepath '/' name '/' name '_Cloud_' num2str(b)],'-dpng','-r100');
    end

    uitable('Data',T{:,:},'ColumnName',T.Properties.VariableNames,'RowName',T.Properties.RowNames,'Units', 'Normalized', 'Position',[0, 0, 1, 1]);
    save([filepath '/' name '/Table.mat'],'T');
    fig =gcf;   print([filepath '/' name '/' name '_Table_' num2str(b)],'-dpng','-r100');

    %% Replace dat by best imputation method
    %O = set(O,'data',dat_imp(:,:,1,1),['Simulated dataset imputed with ' method{1}]);
end

O = set(O,'Table',Tsave);