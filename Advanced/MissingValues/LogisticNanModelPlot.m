
function LogisticNanModelPlot

global O

if ~exist('O','var')
    error('MissingValues/LogisticNanModel.m requires class O as global variable or input argument.')
end

out = get(O,'out');
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
% try
%     dat = get(O,'data_original');
% catch
%     dat = get(O,'data');
% end
dat = get(O,'data');

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
 