% O = missingpattern(O)
%  Analyze pattern of missing value
%  save in O.pattern

function O = missingpattern(O,missing)

if ~exist('O','var')
    error('MissingValues/missingpattern.m requires class O as input argument.')
end
if ~exist('missing','var')
    missing = [];
end
dat = get(O,'data');

% Count missing values per column
ncol = zeros(size(dat,2),1);
if missing == 0
    dat(dat==0) = nan;                         % in example data files, no nans, just zero intensities in 30%
elseif strcmp(missing,'nan')
    ncol = sum(isnan(dat));                    % count all nan elements in column
else
    dat(dat==0) = nan;
    ncol = sum(isnan(dat)); 
end                                     
% Count = sum(ncol)/(size(dat,1)*size(dat,2))*100;

% Correlation columns
RHOcol = corr(dat,'rows','pairwise');
% RHOcol = RHOcol.*(RHOcol>0.8);
figure
set(gcf,'units','normalized','outerposition',[0 0 1 1])
imagesc(RHOcol)
%xlabel('column number')
%ylabel('column number')
title('Pairwise linear correlation coefficients')
names = get(O,'SampleNames');
set(gca,'XTick',1:length(names));
set(gca,'XTickLabel',names);
set(gca,'XTickLabelRotation',45)
set(gca,'YTick',1:length(names));
set(gca,'YTickLabel',names);
%set(gca,'YTickLabelRotation',45)
colormap(jet)
colorbar

% Correlation of mean with # missing
x = round(ncol'/size(dat,1),2,'significant');
y = log10(nanmean(dat))';
RHO = corr(x,y);
figure
%     P = polyfit(x,y,1);
%     yfit = P(1)*sort(x)+P(2);
%     plot(sort(x),yfit);
%     hold on;
%     boxplot(log10(dat),x,'PlotStyle','compact');
plot(ncol'/size(dat,1),log10(nanmean(dat))','o');
lsline
xlabel('#missing')
ylabel('Log10(Mean)')
legend(['Pearson corr = ' num2str(RHO)])
title('Correlation of measurement values and number of missing values')

% logisitic regression, number of missing per row
X = [ones(size(dat,2)/2,1),zeros(size(dat,2)/2,1)];



% Count missing values per row old
% [~,x] = sort(sum(isnan(dat),2));
% nrow = sum(isnan(dat),2);
% % dat(:,end+1) = nrow;
% % dat = sortrows(dat,size(dat,2));
% x = linspace(0,100,size(dat,1));
% y = nrow;
% n = (size(dat,2)-1) * ones(size(dat,1),1);
% [b,~,stats] = glmfit(x,[y n],'binomial','link','logit');
% yfit = glmval(b,x,'logit','size',n);
% figure
% plot(x, y./n,'-',x,yfit./n,'-','LineWidth',2)
% xlabel('ProteinID (other sorting)');
% ylabel('# missing values [%] per row');
% legend('data','logistic regression','Location','east')
% 
% meanofrow = log10(nanmean(dat,2));
% meanofmeanofrowwithsamenumberofmissingvalues = grpstats(meanofrow,nrow/length(ncol));
% RHO = corr(unique(nrow/length(ncol)) ,meanofmeanofrowwithsamenumberofmissingvalues);
% figure
% %boxplot(meanofrow,round(nrow/length(ncol),2,'significant'),'PlotStyle','compact');
% plot(unique(nrow/length(ncol)),meanofmeanofrowwithsamenumberofmissingvalues,'o');
% lsline
% xlabel('#missing')
% ylabel('Log10(Mean)')
% legend(['Pearson corr = ' num2str(RHO)])
% title('Correlation of Protein values and number of missing values')

% Count Proteins with certain number of missing values
for i=1:size(dat,2)
    a(i) = round(length(nrow(nrow==i-1)))./size(dat,1);
end

figure
subplot(1,2,1)
plot(0:size(dat,2)-1,a)
xlabel('# missing values')
ylabel('# Proteins')
subplot(1,2,2)
ca = fliplr(cumsum(fliplr(a)));
%plot(cumsum(a)./size(dat,1),linspace(0,1,31))
plot(0:size(dat,2)-1,ca)
xlabel('min # missing values')
ylabel('# Proteins')

% Write results in class
if sum(nrow)==0 || sum(ncol)==0
    warning('No missing and/or zero values detected (in missingpattern.m)');
elseif any(isnan(nrow)) || any(isnan(ncol))
    warning('Something went wrong in counting missing values (in missingpattern.m). Number of missing values is NaN.');
else
       dat = dat(:,1:end-1);
%       xlswrite('Data.xlsx',dat);
       O = set(O,'data',dat,'Data sorted by #missing values per row.'); 
    O = set(O,'mis_ncol',ncol./size(dat,1));                                         
    O = set(O,'mis_nrow',nrow./size(dat,2));
    O = set(O,'mis_logreg',stats);
    O = set(O,'mis_n',a,'Relative number of proteins having (column-1) missing values');
    fprintf('Missing pattern analyzed, written in mis_ncol, mis_nrow, mis_logreg.\n')
end

