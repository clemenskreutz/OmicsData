
function PlotImputation(O)

if ~exist('O','var')
    error('OmicsData object has to be given as input argument.')
end

%% Get variables from class
dat = get(O,'data_complete');                % Complete dataset without missing values, to compare "right" solution
dat_mis = get(O,'data_mis',true);         % simulated missing values       
if isempty(dat_mis)
    dat_mis = get(O,'data');
end
dat_imp = get(O,'data_imput');               % Imputed data
dat_original = get(O,'data_original');           % Original input data
method = get(O,'method_imput');
Tab = get(O,'Table');
path = get(O,'path');
[filepath,name] = fileparts(path);

if isempty(Tab)
    warning('imputation_analysis.m: Table in class O is empty. Try running O = GetTable(O) first.')
else

for b=1:size(dat_mis,3)
    
    %% Just imputed data
    Y = dat(isnan(dat_mis(:,:,b)));                         % for complete data
    X = nan(size(Y,1),size(dat_imp,4));
    for i=1:size(dat_imp,4)
        im = dat_imp(:,:,b,i);
        X(:,i) = im(isnan(dat_mis(:,:,b)));                 % for imputed data
    end
    if length(Y)<20 || sum(sum(~isnan(X)))<20        % if too less data
        continue
    end
    
    %% Sort by RMSE
    [~,idx] = sort(Tab(6,2:end,b),'MissingPlacement','last');

    T = [Tab(:,1,b) Tab(:,idx+1,b)];
    dat_imp = dat_imp(:,:,:,idx);

    X = X(:,idx);
    method = method(idx);

    %% Plot
    if exist([filepath '\' name '\' name '_Boxplot_Difference_' num2str(b) '.png'],'file')
        delete([filepath '\' name '\' name '_Boxplot_Difference_*.png']);
        delete([filepath '\' name '\' name '_Cloud*.png']);
        delete([filepath '\' name '\' name '_Table*.png']);
    end
    
    Diffc = nan(size(X));
    for i=1:size(X,2)
        Diffc(:,i) = abs(X(:,i)-Y);
    end
    Diffc(:,all(isnan(Diffc)))=[];

    figure; set(gcf,'units','normalized','outerposition',[0 0 0.3 0.5]); %set(gcf,'units','points','position',[10,10,380,300])
    boxplot(Diffc,'PlotStyle','compact','Symbol','.','DataLim',[0 5])
    %violin(Diffc,'facecolor',[0 0 1],'facealpha',1,'medc','','mc','k','bw',0.05);
    hold on;
    p2 = plot(T(6,2:end),'rd','MarkerFaceColor','r','LineWidth',1);
%            ylim([-0.02 5.05])
    set(gca,'XTick',1:size(dat_imp,4)+1);
    set(gca,'XTickLabel',method,'XTickLabelRotation',45, 'FontSize',14);  
    ylabel('|Imputed - Original|', 'FontSize',14)
    legend(p2,'RMSE','Location','northwest')
    title('Imputation error', 'FontSize',18)
    %set(gca,'FontSize', 20)
    print([filepath '/' name '/' name '_Boxplot_Difference_' num2str(b)],'-dpng','-r100');


     %% Correlation of imp/orig
     figure; set(gcf,'units','normalized','outerposition',[0 0 .5 .8])                       
     methodhist = method(:,~all(isnan(X))); % if a method did not work
     X = X(:,~all(isnan(X)));
     n = [1,round(size(X(~all(isnan(X))),2)/2),size(X(~all(isnan(X))),2)];
     bottom = 0; top = 13;
     myColorMap = jet(256);
     myColorMap(1:5,:) = 1;

     for j=1:length(n)               
        i = n(j);
        subplot(2,ceil(length(n)/2),j)
        hold on
        xlabel('original')
        ylabel('imputed')
        [anz,c] = hist3([Y(:),X(:,i)],'Nbins',[70,70]);
        colormap(myColorMap);
        caxis manual
        caxis([bottom top]);
        H = pcolor(c{1}(:), c{2}(:), anz');
        shading interp
        set(H,'edgecolor','none');
        %contour(c{1},c{2},anz','ShowText','on');%,[50 75 95]);
        limin = min(nanmin(Y),min(nanmin(X(:,i)))); limax = max(nanmax(Y),max(nanmax(X(:,i))));
        plot(limin:limax,limin:limax,'-r')
        xlim([limin,limax])
        ylim([limin,limax])
        title(methodhist{i},'Interpreter','none')                    
%                             text(0.05,0.9,['RMSE=' num2str(round(T{6,i+1},2))],'Units','normalized','FontSize', 18);
%                             if ~isnan(T{9,i+1})
%                                 text(0.95,0.1,['PCC=' num2str(round(T{9,i+1},2))],'Units','normalized','HorizontalAlignment','right','FontSize', 18);
%                             end
        set(gca,'FontSize', 12)
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
    legend([{'original'},methodhist{n}],'Interpreter','none','FontSize',12,'Position',[hp4(1)+hp4(3)/2 hp4(2)+0.13 hp4(3)/2.5 hp4(3)*0.5])
    print([filepath '/' name '/' name '_Cloud6_' num2str(b)],'-dpng','-r100');

    % Table
    uitable('Data',T,'ColumnName',['original' method],'Units','Normalized','Position',[0, 0, 1, 1]);
    print([filepath '/' name '/' name '_Table_' num2str(b)],'-dpng','-r100');
end
end

%% Histogram of datasets
figure
edges = nanmin(nanmin(dat)):0.1:nanmax(nanmax(dat));
histogram(dat_original,edges)
hold on
histogram(dat,edges)
histogram(dat_mis,edges)
histogram(dat_imp(:,:,:,1),edges);
legend('Original','Complete','Simulated','Imputed')
print([filepath '/' name '/' name '_Histogram'],'-dpng','-r100');
