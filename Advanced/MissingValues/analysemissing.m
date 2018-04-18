% O = missingpattern(O)
%  Analyze pattern of missing value
%  save in O.pattern

function O = missingpattern(O,missing,bins)

if ~exist('O','var')
    error('MissingValues/missingpattern.m requires class O as input argument.')
end
if ~exist('missing','var')
    missing = [];
end
if ~exist('bins','var') || isempty(bins)
    bins = 100;
end

% Names
names = get(O,'SampleNames');
if isfield(O,'Proteinnames')
    Pnames = get(O,'Proteinnames');
elseif isfield(O,'Proteinname')
    Pnames = get(O,'Proteinname');
elseif isfield(O,'ProteinIDs')
    Pnames = get(O,'ProteinIDs');
end

% Show data
dat = get(O,'data');
dat(dat==0) = nan;
datn = isnan(dat);
imagesc(datn)

% Count
nrow = sum(datn)./size(dat,1);
ncol = sum(datn,2);
edges = 0:size(datn,2);
ncol_rel = histcounts(ncol,edges)/histcounts(ncol,1);
%ncol(ncol==size(dat,2)) = [];
%ncol_rel = histcounts(ncol,size(datn,2))/histcounts(ncol,1);
n = sum(nrow)/size(dat,2);    % Total percentage of missing values
%men = mean(nanmean(dat));
mi = min(dat(~isnan(dat)));
ma = max(dat(~isnan(dat)));
% Sort
%[datsort,idx_nrow] = sort(datn);
[datsort2,idx_ncol] = sort(datn,2);
%[datsor,idx_ncol2] = sort(datsort,2);
[datsor2,idx_nrow] = sort(datsort2);
%figure
%imagesc(datsort);
figure
imagesc(datsort2)
%figure
%imagesc(datsor)
figure
imagesc(datsor2)

for i=1:size(idx_nrow,2)
    newInd(idx_nrow(:,i),i) = 1:size(idx_nrow,1);
    da(:,i) = datsor2(newInd(:,i),i);
end

figure
imagesc(da)

for i=1:size(idx_ncol,1)
    newInd2(i,idx_ncol(i,:)) = 1:size(idx_ncol,2);
    da2(i,:) = da(i,newInd2(i,:));
end

figure
imagesc(da2)

% mean <-> no. missing


% set(gca,'XTick',1:length(names));
% set(gca,'XTickLabel',names);
% set(gca,'XTickLabelRotation',60)
% set(gca,'YTick',1:length(Pnames));
% set(gca,'YTickLabel',Pnames);
% title('Missing data pattern sorted')
% colorbar('Ticks',[0 1],'TickLabels',{'not missing','missing'})
     
% if missing == 0                          
%     nrow = sum(dat==0);  
%     ncol = sum(dat==0,2);
% elseif strcmp(missing,'mix')
%     dat(dat==0) = nan;        
%     nrow = sum(isnan(dat));                % in example dataset02 really a mixture exists
%     ncol = sum(isnan(dat),2);
% else
%     nrow = sum(isnan(dat));      
%     ncol = sum(isnan(dat),2);
% end                                   

%% Pairwise correlation coefficients
RHOcol = corr(dat,'rows','pairwise');
% RHOcol = RHOcol.*(RHOcol>0.8);
figure
set(gcf,'units','normalized','outerposition',[0 0 1 1])
imagesc(RHOcol)
title('Pairwise linear correlation coefficients')
set(gca,'XTick',1:length(names));
set(gca,'XTickLabel',names);
set(gca,'XTickLabelRotation',45)
set(gca,'YTick',1:length(names));
set(gca,'YTickLabel',names);
colormap(jet)
colorbar

%% Correlation of columnwise mean with # missing
x = round(nrow',2,'significant');
y = log10(nanmean(dat)');
RHO = corr(x,y);
figure
%     P = polyfit(x,y,1);
%     yfit = P(1)*sort(x)+P(2);
%     plot(sort(x),yfit);
%     hold on;
%     boxplot(log10(dat),x,'PlotStyle','compact');
plot(x,y,'o');
lsline
xlabel('#missing')
ylabel('Log10(Mean)')
legend(['Pearson corr = ' num2str(RHO)])
title('Correlation of measurement values and number of missing values')


%% Correlation of rowwise mean with # missing
meanofrow = nanmean(dat,2);
%meanofrow(isnan(meanofrow)) = [];
yr = log10(grpstats(meanofrow,ncol));        % meanofmeanofrowwithsamenumberofmissingvalues
xr = unique(ncol/length(nrow));
RHO = corr(xr ,yr);
figure
%boxplot(meanofrow,round(ncol/length(nrow),2,'significant'),'PlotStyle','compact');
plot(xr,yr,'o');
lsline
xlabel('#missing')
ylabel('Log10(Mean)')
legend(['Pearson corr = ' num2str(RHO)])
title('Correlation of Protein values and number of missing values')

%% Mean proteins, missing
[meanvector,idx] = sort(meanofrow);
ncols = ncol(idx);
% bins = rows_womis;
% nb = bins;   % number of bins for Proteins
% if mod(size(meanvector,1),nb)~=0
%     for i=1:nb-mod(size(meanvector,1),nb)
%         meanvector = [meanvector; NaN];
%         ncols = [ncols;NaN];
%     end
% end
% 
% ncol2 = reshape(ncols,[],nb);
% meanmatrix(:,all(isnan(ncol2))) = [];
% ncol2(:,all(isnan(ncol2))) = [];
% minInt = round(meanmatrix(1,:),2);
% minInt(1) = min(min(ncol2));
% meanmis = nanmean(ncol2);
% figure
% boxplot(ncol2,'PlotStyle','compact','MedianStyle','line')
% set(gca,'XTick',1:99,'XTickLabel',minInt);
% set(gca,'XTickLabelRotation',60)

rows_womis = ceil(sum(all(~datn,2))/1);
kgt = floor(length(meanvector)/rows_womis);
differ = (length(meanvector)-rows_womis*kgt);
idx_fill = rows_womis - differ;
meanmatrix = nan(kgt+1,rows_womis);
meanmatrix(1:kgt,1:idx_fill) = reshape(meanvector(1:idx_fill*kgt),kgt,idx_fill);
meanmatrix(1:kgt+1,idx_fill+1:rows_womis) = reshape(meanvector(idx_fill*kgt+1:end),kgt+1,differ);
ncol2 = nan(kgt+1,rows_womis);
ncol2(1:kgt,1:idx_fill) = reshape(ncols(1:idx_fill*kgt),kgt,idx_fill);
ncol2(1:kgt+1,idx_fill+1:rows_womis) = reshape(ncols(idx_fill*kgt+1:end),kgt+1,differ);
meanInt = nanmean(meanmatrix);
meanmis = nanmean(ncol2);

figure
plot(meanInt,meanmis,'o')

hold on
p = fit(meanInt',meanmis','exp1');
plot(p,'-r')
coeff = [p.a p.b];
%plot(p,'predobs')
y1 = p(meanInt');
tr = find(abs(diff(y1))/max(y1) >0.005,1,'last');
plot([tr+0.5,tr+0.5],[0,max(max(ncol2))],'r','LineWidth',2)
xlabel('mean of Proteins')
ylabel('#missing')
legend('mean','exponential fit of means',['threshold MCAR' newline '#mis > ' num2str(round(size(dat,2)/10,2,'significant')) ', mean > ' num2str(round(meanmatrix(1,tr),2,'significant'))]);

MCAR = sum(nansum(ncol2(:,tr+1:end)))*size(y1,1)/(size(y1,1)-tr)/size(dat,1)/size(dat,2); % # Missing values under threshold * expansion to all (overall background MCAR) /all (to get percent)
MNAR = n-MCAR;

%% Boxplot rowwise mean
meanbox = nan(size(dat,1),size(dat,2)+1); c=0;
for i=1:size(dat,2)+1
    a = meanofrow(ncol==i-1);
    if all(isnan(a))
        meanbox(:,i-c) = [];
        c=c+1;
    else
        meanbox(1:size(a,1),i-c) = a;
    end
end
% meanbox = log10(meanbox);
figure
boxplot(meanbox)
xlabel('#missing')
ylabel('Mean of proteins')
title('Correlation of Protein values and number of missing values')
set(gca,'XTickLabel',0:size(dat,2));
hold on
x1 = 1:size(meanbox,2);
p = polyfit(x1,nanmean(meanbox),1);
y1 = polyval(p,x1);
plot(x1,y1)

% linear fit of all data, not just means
% x1 = ncol+1;
% b = meanofrow;
% p = polyfit(x1,b,1);
% y1 = polyval(p,x1);
% plot(x1,y1)
% legend('linear regression of mean','linear regression of all data points')
hold off


%% How many Proteins have how many missing vlaues (cdf)
% ncol_rel = histcounts(ncol,size(datn,2))/histcounts(ncol,1);
figure
subplot(1,3,1)
plot(0:size(dat,2)-1,ncol_rel)
xlabel('# missing values')
ylabel('# Proteins')
subplot(1,3,2)
ca = fliplr(cumsum(fliplr(ncol_rel)));
%plot(cumsum(a)./size(dat,1),linspace(0,1,31))
plot(0:size(dat,2)-1,ca)
xlabel('min # missing values')
ylabel('# Proteins')
subplot(1,3,3)
histogram(ncol)
xlabel('#missing values')
ylabel('count of rows/Proteins')

%% Write results in class
if sum(ncol)==0 || sum(nrow)==0
    warning('No missing and/or zero values detected (in missingpattern.m)');
elseif any(isnan(ncol)) || any(isnan(nrow))
    warning('Something went wrong in counting missing values (in missingpattern.m). Number of missing values is NaN.');
else
                                        
%    O = set(O,'mis_ncol',[]); 
    O = set(O,'mis_ncol',ncol./size(dat,2));
    O = set(O,'mis_idx_ncol',[]);
    O = set(O,'mis_idx_ncol',idx_ncol);

%    O = set(O,'mis_nrow',[]); 
    O = set(O,'mis_nrow',nrow);  
%    O = set(O,'mis_idx_nrow',[]); 
    O = set(O,'mis_idx_nrow',idx_nrow);

%    O = set(O,'mis_n',[]); 
    O = set(O,'mis_n',n,'number of missing values in data matrix');
    O = set(O,'MCAR',MCAR,'number of missing values completely atrandom');
    O = set(O,'MNAR',MNAR,'number of missing values not at random');
    O = set(O,'coeff_meanmis',coeff,'Coefficients of linear fit of mean to number missing values');
    %O = set(O,'mean',men,'mean of original matrix');
    O = set(O,'mindat',mi,'minimum of original matrix');
    O = set(O,'maxdat',ma,'maximum of original matrix');
    O = set(O,'meanInt',meanInt,'minimum intensity which belongs to mean missing values');
    O = set(O,'meanmis',meanmis,'mean missing value which belongs to minimum intensity');
%    O = set(O,'mis_ncol_rel',[]); 
    O = set(O,'mis_ncol_rel',ncol_rel,'Relative number of proteins having (column-1) missing values');
    fprintf('Missing pattern analyzed, written in mis_nrow, mis_ncol, mis_n and mis_pn.\n')
end

