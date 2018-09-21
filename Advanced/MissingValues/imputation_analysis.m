% function [T,p] = imputation_analysis(log,anova,plt)
%
% log - logging data before analysis?       [true, if range(dat)>10^3]
% anova - do anova for Original vs imputed                      [true]
% plt - plot&save boxplot&histogram of Original vs imputed      [true]
%
% Output:
% T - Table of mean/std/min/max/diff/leastsqaures of original and imputed data
% p - pvalues of anova Original vs imputed data

function imputation_analysis(log,anova,plt)

global O

if ~exist('O','var')
    error('OmicsData object has to be passed in to function imputation_boxplot.m.')
end
if ~exist('anova','var') || isempty('anova')
    anova = true;
end
if ~exist('plt','var') || isempty('plt')
    plt = true;
end


% Get variables from class
dat = get(O,'data_full');                % Complete original dataset without missing values, to compare "right" solution
dat_sim_mis = get(O,'data_mis');         % simulated missing values
mispat = isnan(dat_sim_mis);             % simulated missing pattern                
Imp = get(O,'data_imput');               % Imputed data
method = get(O,'method_imput');

mispat = double(mispat);
mispat(mispat==0)=nan;


% calculate just imputed values (before and after imputation)
dat_mis = nan(size(mispat,1),size(mispat,2),size(mispat,3));
for nn = 1:size(mispat,3)
    dat_mis(:,:,nn) = dat.*mispat(:,:,nn);
end
dat_imp = nan(size(Imp,1),size(Imp,2),size(Imp,3),size(Imp,4));
for i=1:size(Imp,4)
    dat_imp(:,:,:,i) = Imp(:,:,:,i).*mispat;
end

% Columns of just imputed data
Y = dat_mis(~isnan(dat_mis));
X = nan(size(Y,1),size(dat_imp,4));
for i=1:size(dat_imp,4)
    im = dat_imp(:,:,1,i);
    X(:,i) = im(~isnan(im));
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
T = table([nanmean(Y);nanstd(Y);nanmin(Y);nanmax(Y);0;0;0]);
T.Properties.VariableNames = {'original'};
T.Properties.RowNames = {'mean','std','min','max','Diff','LS','p'};
Diffm = nan(size(dat_imp,1),size(dat_imp,2),size(dat_imp,4));

for i=1:size(dat_imp,4)
    Quad = 0;
    if length(size(dat_mis)) == 3
        Quad = Quad + sum(sum(nansum((dat_mis - dat_imp(:,:,:,i)).^2))); 
        %Diff = dat_imp(:,:,:,i)-dat_mis;
    elseif length(size(dat_mis)) == 2
        for j=1:size(dat_imp,3)
            Quad = Quad + sum(nansum((dat_mis - dat_imp(:,:,j,i)).^2));
        end
        Diffm(:,:,i) = dat_imp(:,:,:,i)-dat_mis;
    end
    Quad = Quad/size(Y,1);   
    %X(:,i) = dat_imp(~isnan(dat_imp(:,:,:,i))); 
    p = anova1([Y X(:,i)],[],'off');
    T = [T table([nanmean(X(:,i)); nanstd(X(:,i)); nanmin(X(:,i)); nanmax(X(:,i)); nanmean(X(:,i))-nanmean(Y); Quad; p])];
    T.Properties.VariableNames(i+1) = method(i);
end

%% Sort imputation matrix by least squared for plotting
[~,idx] = sort(table2array(T(6,2:end)));
T2 = [T(:,1) T(:,idx+1)]
dat_imp = dat_imp(:,:,:,idx);
Diffm = Diffm(:,:,idx);
X = X(:,idx);
method = method(idx);
LS = T(6,idx+1);

%% Plot

path = get(O,'path');
[filepath,name] = fileparts(path);
if ~exist([filepath '/' name],'dir')
    mkdir(filepath, name)
end
%plotmatrixpattern(dat_mis,dat_imp,T,idx)
%fig=gcf;  print([filepath '/' name '/' name '_Matrix_Imp'],'-dpng','-r200');

plotmatrixpattern( [],Diffm,T,idx);
fig=gcf;  print([filepath '/' name '/' name '_Matrix_Imp_Diff'],'-dpng','-r200');

% %% Just original
% dat_original = get(O,'data_original'); 
% figure; set(gcf,'units','points','position',[10,10,300,220])
% nr = size(dat_original,1);
% nc = size(dat_original,2);
% pcolor([dat_original nan(nr,1); nan(1,nc+1)]);
% shading flat;
% set(gca, 'ydir', 'reverse');
% caxis manual
% caxis([0 max(max(dat_original))]);
% title('Original data')
% ylabel('Proteins')
% xlabel('Experiments')
% c=colorbar;
% c.Label.String = 'Log10(LFQ Intensity)';
% fig=gcf;  print([filepath '/' name '/' name '_Matrix_original'],'-dpng','-r200');
% 
% %% Just original
% dat_original = get(O,'data_mis'); 
% figure; set(gcf,'units','points','position',[10,10,200,130])
% nr = size(dat_original,1);
% nc = size(dat_original,2);
% pcolor([dat_original nan(nr,1); nan(1,nc+1)]);
% shading flat;
% set(gca, 'ydir', 'reverse');
% caxis manual
% caxis([0 max(max(dat_original))]);
% title({'Original data','with simulated missing pattern'})
% ylabel('Proteins')
% xlabel('Experiments')
% fig=gcf;  print([filepath '/' name '/' name '_Matrix_simulated'],'-dpng','-r200');


if plt
    %% Boxplot & Histogram
    figure; set(gca,'fontname','arial'); set(gcf,'units','points','position',[10,10,450,250])
  
    
    subplot(3,1,1)
    title('Comparison of imputation methods');  
    %figure; set(gca,'fontname','arial'); set(gcf,'units','points','position',[10,10,210,150])
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
    
    subplot(3,1,2)
    boxplot([Y X])
    %  ylim = get(gca,'YLim');
    set(gca,'XTick',1:size(dat_imp,4)+1);
    set(gca,'XTickLabel',horzcat('Original',method));  
    ylabel('data distribution')
    %text(size(dat_imp,4),max(nanmax(X)),['bootstrap = ' num2str(size(Imp,3))])
    %  text(0.52,0.98*ylim(2),['ls/bs = ' num2str(round(Quad,2,'significant'))]) 
    
    subplot(3,1,3)
    boxplot(Diffc) 
    %  ylim = get(gca,'YLim');
    set(gca,'XTick',1:size(dat_imp,4)+1);
    set(gca,'XTickLabel',method);  
    ylabel('data difference')
    %text(size(dat_imp,4),max(nanmax(X)),['bootstrap = ' num2str(size(Imp,3))])
    %  text(0.52,0.98*ylim(2),['ls/bs = ' num2str(round(Quad,2,'significant'))]) 
      
    % Save fig
    path = get(O,'path');
    [filepath,name] = fileparts(path);
    if ~exist([filepath '/' name],'dir')
        mkdir(filepath, name)
    end
    fig=gcf;  print([filepath '/' name '/' name '_Compare_Imp'],'-dpng','-r200');
    
    %% Compare columns of imputed data
    figure; set(gca,'fontname','arial'); set(gcf,'units','points','position',[10,10,210,150])
    imagesc([Y X].') 
    title('Comparison of imputation methods');  
    set(gca,'YTick',1:size(dat_imp,4)+1);
    set(gca,'YTickLabel',horzcat('Original',method),'TickLabelInterpreter','none');  
    %set(gca,'xaxisLocation','top')
    xlabel('data index')
    set(gca, 'XTickLabel', [])
    %xlabel('Imputation method','FontWeight','bold')
    %text(size(dat_imp,4),size(X,1)/30,['bootstrap = ' num2str(size(Imp,3))])
    c=colorbar;
    c.Label.String = 'Log10(LFQ Intensity)';
    fig=gcf;  print([filepath '/' name '/' name '_ImpValues_column'],'-dpng','-r200');

    % Compare differences to original value, as column
    figure; set(gca,'fontname','arial'); set(gcf,'units','points','position',[10,10,260,150])
    imagesc([Y-Y Diffc].') 
    title('Comparison of imputation methods');  
    %  ylim = get(gca,'YLim');
    set(gca,'YTick',1:size(dat_imp,4)+1);
    set(gca,'YTickLabel',horzcat('Original',method),'TickLabelInterpreter','none');  
    %set(gca,'xaxisLocation','top')
    xlabel('data index')
    set(gca, 'XTickLabel', [])
    caxis manual
    caxis([0 5]);
    %xlabel('Imputation method','FontWeight','bold')
    %text(size(dat_imp,4),size(X,1)/30,['bootstrap = ' num2str(size(Imp,3))])
    c=colorbar;
    c.Label.String = 'Difference in magnitude';
    
    %Save fig
    fig=gcf;  print([filepath '/' name '/' name '_Diff_column'],'-dpng','-r200');
     
end
save([filepath '/' name '/Table.mat'],'T2');