%  This function does not consider "rows" (proteins) as comprehenisve
%  predictors as done by LogisticNanModel.m 
%  It "only" tests each row individually

function OmicsNaModel(O)
%%
isna = isnan(O);
isample = ones(get(O,'nf'),1)*[1:get(O,'ns')];
m = nanmedian(O,2)*ones(1,get(O,'ns'));

xsample = x2fx(isample(:),'linear',1);

y = isna(:);
% X = [xsample, m(:)];
X = [xsample, m(:)-nanmedian(m(:))];
m(isnan(m)) = nanmin(m(:));
ind = ~isnan(m);


[b,dev,stats] = glmfit(X(ind,:),y(ind),'binomial','link','logit','constant','off');
pred = reshape(glmval(b,X(ind,:),'logit','constant','off'),length(ind),size(isna,2));


ysim = binornd(1,pred);

%
close all
subplot(5,1,1)
errorbar(1:length(b),b,stats.se,'o')
ylabel('p_{est}')
title('parameters')
axis tight
abplot(0,0)
subplot(5,1,2)
imagesc(X(1:100:end,:))
ylabel('data points')
xlabel('parameter index')
title('design matrix')
set(gca,'YTick',[]);
colorbar
subplot(5,1,3:5)
image(O)

% print -dpng RawMean
print -dpng CenteredMean


%%
Osim = set(O,'data',ysim,'Simulation');
[~,rfo] = sort(-get(O(find(ind(:,1)==1),:),'propna'));
[~,rf] = sort(-nanmean(Osim,2));

figure
subplot(4,1,1:2)
imagesc(isnan(O(rfo,:)))
subplot(4,1,3:4)
imagesc(get(Osim(rf,:),'data')==1)
print -dpng Image_Osim


%% Problem so far: the simulation does not produce enough features with many NaN
% Teste, ob die kleinen Means auf ein quantil geschoben werden sollten
% [linkes tail in hist(m(:),100)]
qs = logspace(-3,-0.5,24)
devs = NaN(size(qs));
bs = [];
for i=1:length(qs)
    mtmp = m(:);
    qtmp = quantile(mtmp,qs(i));
    mtmp(mtmp<qtmp) = qtmp;
    Xtmp = [xsample, mtmp(:)-nanmedian(mtmp(:))];
    [bs(:,i),devs(i),stats] = glmfit(Xtmp,y,'binomial','link','logit','constant','off');
end
mqs = quantile(m(:),qs);
plot(mqs,devs)
xlabel('quantile of means used for rounding')
ylabel('deviance');
print -dpng RoundingSmallMeans
%
[~,imin]=min(devs);
bmin = bs(:,imin);
m2 = m(:);
m2(m2<mqs(19))=mqs(19);
hist(m2(:),100)
print -dpng MeansAfterRoundingToMinDeviance

Xmin = [xsample, m2(:)-nanmedian(m2(:))];
predmin = reshape(glmval(bmin,Xmin,'logit','constant','off'),length(ind),size(isna,2));
ysimmin = binornd(1,predmin);
Osimmin = set(O,'data',ysimmin,'SimulationMinDev');

[~,rf] = sort(-nanmean(Osimmin,2));

figure
subplot(4,1,1:2)
imagesc(isnan(O(rfo,:)))
subplot(4,1,3:4)
imagesc(get(Osimmin(rf,:),'data')==1)
print -dpng Image_Osimmin