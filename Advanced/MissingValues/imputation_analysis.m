% function [T,p] = imputation_analysis(log,anova,boxplt,histo)
%
% log - logging data before analysis?       [true, if range(dat)>10^3]
% anova - do anova for Original vs imputed                      [true]
% boxplot - plot boxplot of Original vs imputed                 [true]
% histo - plot histo of differences between Original vs imputed [true]
%
% Output:
% T - Table of mean/std/min/max/diff/leastsqaures of original and imputed data
% p - pvalues of anova Original vs imputed data

function [T,p] = imputation_analysis(log,anova,boxplt,histo)

global O

if ~exist('O','var')
    error('OmicsData object has to be passed in to function imputation_boxplot.m.')
end
if ~exist('anova','var') || isempty('anova')
    anova = true;
end
if ~exist('boxplt','var') || isempty('boxplt')
    boxplt = true;
end
if ~exist('histo','var') || isempty('histo')
    histo = true;
end

% Get variables from class
dat = get(O,'data_full');
Imp = get(O,'data_imput');
method = get(O,'method_imput');
mispat = get(O,'mis_pat');
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

% Log ?
if ~exist('log','var') || isempty(log)
    if range(dat)>10^3
        log = true;
    else, log = false;
    end
end
if log   
    dat_mis(dat_mis<=0) = nan;  % for dat<0, log is ignored
    dat_mis = log10(dat_mis);
    dat_imp(dat_imp<=0) = nan;
    dat_imp = log10(dat_imp);
end

%% Table
% dat = dat(~isnan(dat));                 % Write data in one column, to suppress columnwise boxplot
% Imp = Imp(~isnan(Imp(:,:,i)));
Y = dat_mis(~isnan(dat_mis));
T = table([nanmean(Y);nanstd(Y);nanmin(Y);nanmax(Y);0;0]);
T.Properties.VariableNames = {'original'};
T.Properties.RowNames = {'mean','std','min','max','Diff','LS'};

for i=1:size(dat_imp,4)
    Quad = 0;
    if length(size(dat_mis)) == 3
        Quad = Quad + sum(sum(nansum((dat_mis - dat_imp(:,:,:,i)).^2)));        
    elseif length(size(dat_mis)) == 2
        for j=1:size(dat_imp,3)
            Quad = Quad + sum(nansum((dat_mis - dat_imp(:,:,j,i)).^2));
        end
    end
    Quad = Quad/size(Imp,3);   
    X(:,i) = dat_imp(~isnan(dat_imp(:,:,:,i))); 
    T = [T table([nanmean(X(:,i)); nanstd(X(:,i)); nanmin(X(:,i)); nanmax(X(:,i)); nanmean(X(:,i))-nanmean(Y);Quad])];
    T.Properties.VariableNames(i+1) = method(i);
end

%% Anova
if anova
    for i=1:size(X,2)
        p = anova1([Y X(:,i)]);
    end
end

%% Boxplot
if boxplt
    figure
    boxplot([Y X])
    title('Comparison of imputation');   
    %  ylim = get(gca,'YLim');
    set(gca,'XTick',1:size(dat_imp,4)+1);
    set(gca,'XTickLabel',horzcat('Original',method));  
    ylabel('data value')
    text(size(dat_imp,4),max(nanmax(X)),['bootstrap = ' num2str(size(Imp,3))])
    %  text(0.52,0.98*ylim(2),['ls/bs = ' num2str(round(Quad,2,'significant'))]) 
end

%% Histogram plot
if histo
    figure    
    for i=1:size(dat_imp,4)
        %Diff = log10(abs(dat_imp(:,:,:,i)-dat_mis));
        Diff = dat_imp(:,:,:,i)-dat_mis;
        histogram(Diff,20,'FaceAlpha',0.2)
        hold on
        xlabel('Difference Imputation-True')
        ylabel('Frequency')
    end
    legend(method)
end