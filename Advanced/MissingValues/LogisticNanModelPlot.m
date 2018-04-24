
function LogisticNanModelPlot

global O

if ~exist('O','var')
    error('MissingValues/LogisticNanModel.m requires class O as global variable or input argument.')
end

out = get(O,'out');

t = out.type(:,1);
b1 = out.b(t==1,:);
b2 = out.b(t==2,:);
b3 = out.b(t==3,:);
b3s = sort(mean(b3,2));

figure
boxplot(b1)
title('Intensity coefficient')
ylabel('Intensity Coefficient')

figure

boxplot(b2')
title('Coefficients per experiment')
xlabel('Experiments')
ylabel('Regression coefficients')

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


