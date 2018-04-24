% Data overview

function plotdata

global O

dat = get(O,'data');
SampleNames = get(O,'SampleNames');

figure
imagesc(dat)
title('Data matrix')

figure
imagesc(isnan(dat))
title('Missing values in data')

figure
plot(log10(dat),'o')
xlabel('Protein')
ylabel('data value')

figure
plot(log10(dat'))
xlabel('Measurement')
ylabel('data value')
legend(SampleNames,'Location','eastoutside')

