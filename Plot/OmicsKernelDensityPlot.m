% OmicsKernelDensityPlot(O)
% 
%   Plotting of the pdf of the samples via kernel density estimation.

function OmicsKernelDensityPlot(O)
dat = get(O,'data');
pts = linspace(nanmin(dat(:)),nanmax(dat(:)),200);

f = NaN(length(pts),size(dat,2));
% xi = f;
y = f;
for i=1:size(dat,2)
    [f(:,i)] = ksdensity(dat(:,i),pts,'Bandwidth',0.7);
    y(:,i) = i;
end

plot3(pts,y,f,'LineWidth',1.5);
set(gca,'FontSize',14,'LineWidth',1.5)
xlabel('data')
ylabel('sample index')
zlabel('ksdensity')
