
function plotdata(O)

dat = get(O,'data');
figure
plot(log10(dat),'o')
xlabel('Protein')
ylabel('data value')
legend('measurements','hellblau und rot sind nicht light','liegt an niedriger Tagesmessung','--> Quantil Norm')

figure
plot(log10(dat'))
xlabel('Measurement')
ylabel('data value')
% legend('Proteins','Arianes Quantil normalisierung?')

