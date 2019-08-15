
function LogisticNanModelPlot(O,out)

if ~exist('O','var')
    error('MissingValues/LogisticNanModel.m requires class O as global variable or input argument.')
end

path = get(O,'path');
[filepath,name] = fileparts(path);
mkdir(filepath, name)   

t = out.type(:,1);
b1 = out.b(t==1,:);
b2 = out.b(t==2,:);
b2s = sort(mean(b2,2));
b3 = out.b(t==3,:);
b3s = sort(mean(b3,2));

figure
boxplot(b1)
title('Intensity coefficient')
ylabel('Intensity Coefficient')
fig =gcf;   print([filepath '/' name '/' name '_LogRegInt'],'-dpng','-r100');
 
figure
boxplot(b2')
title('Coefficients per experiment')
xlabel('Experiments')
ylabel('Regression coefficients')
 fig =gcf;   print([filepath '/' name '/' name '_LogRegCol'],'-dpng','-r100');
 
 figure
plot(b2s)
title('Coefficients per experiment')
xlabel('Experiments')
ylabel('Regression coefficients')
 fig =gcf;   print([filepath '/' name '/' name '_LogRegCol2'],'-dpng','-r100');
 
figure
suptitle('Coefficients per Protein')
subplot(1,3,1)
plot(1:length(b3),b3s)
xlabel('# of row')
ylabel('b: log reg coeff for row (sorted)')
subplot(1,3,2)
histogram(b3s)
xlabel('b')
ylabel('Frequency')

% Probability
logit = exp(b3s);
p = 1./(1./logit+1); 


subplot(1,3,3)
histogram(p)
xlabel('p (missing values)')
ylabel('Frequency')
fig =gcf;   print([filepath '/' name '/' name '_LogRegrow'],'-dpng','-r100');

%% Log Plot
dat = get(O,'data_original');
if isempty(dat)
    dat = get(O,'data');
end

figure
subplot(1,2,1)
misrow = sort(sum(isnan(dat),2)/size(dat,2));
plot(misrow)
xlim([1 length(misrow)])
ylim([ 0 1])
xlabel('proteins sorted')
ylabel('Missing values [%]')
title('Missing values per protein')
hold off

subplot(1,2,2)
miscol = sort(sum(isnan(dat),1)/size(dat,1));
plot(miscol)
xlim([1 length(miscol)])
ylim([ 0 0.7])
xlabel('experiments sorted')
title('Missing values per experiment')
ylabel('Missing values [%]')
hold off
fig =gcf;   print([filepath '/' name '/' name '_LogReg'],'-dpng','-r100');

%% Mean Boxplot
n_mis_row_rel = round(sum(isnan(dat),2)/size(dat,2),1);
meandat = round(nanmean(dat,2),1);
mi = nanmin(meandat);
ma = 25.7;% nanmax(meandat);
c=1;
meanmis = nan(round((ma-mi)*10+1),length(n_mis_row_rel));
 for i=mi:0.1:ma
    d = n_mis_row_rel(meandat==i);
    meanmis(c,1:length(d)) = d;
    c=c+1;
 end
 
%% fit
m = mi:0.1:ma;
mis = nanmean(meanmis.');
m(isnan(mis))=[];   % nan values can not be fitted
mis(isnan(mis))=[];
 
x0=[1;-nanmean(meandat)];
fun=@(x)(nanmax(mis)./(1+exp(x(1)*(m+x(2))))-mis);
options = optimset('TolFun',1e-20,'TolX',1e-20);
[x,~] = lsqnonlin(fun,x0,[],[],options);

% Calc logregpoints
m = mi:0.1:ma;
mexp = nanmax(mis)./(1+exp(x(1)*(m+x(2)))); 


%% Boxplot
figure; set(gca,'fontname','arial'); set(gcf,'units','points','position',[10,10,550,300])
boxplot(meanmis.','Symbol','.','OutlierSize',2)
set(gca,'XTick',1:5:size(meanmis,1),'XTickLabel',mi:0.5:ma, 'FontSize',11,'XTickLabelRotation',90);  
ylabel('Missing values [%]')
xlabel('Mean protein intensity')
hold on
plot(mexp)
legend('logistic fit')
ylim([-0.05 nanmax(mis)+0.05])
title('Missing values per protein intensity')
print([filepath '/' name '/' name '_MeanBoxplot'],'-dpng','-r100');
 