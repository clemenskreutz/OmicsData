% OmicsKernelDensityPlot(O, [yvals], [ylab])
% 
%   Plotting of the pdf of the samples via kernel density estimation.
% 
%   yvals   the numbers used for each sample as y-axis
% 
%   ylab    string used as ylabel
% 
% Example: 
% 

function OmicsKernelDensityPlot(O,yvals,ylab)
if ~exist('yvals','var') || isempty(yvals)
    yvals = 1:get(O,'ns');
else
    if length(yvals)~=get(O,'ns')
        error('length(yvals) ~= get(O,''n'')');
    end
end
if ~exist('ylab','var') || isempty(ylab)
    ylab = 'sample index';
end

dat = get(O,'data');

[f,pts] = ksdensity(O);
for i=1:size(f,2) % renormalize w.r.t. prop of missing values
    f(:,i) = f(:,i)*sum(~isnan(dat(:,i)))/size(dat,1);
end

y = NaN*f;
for i=1:size(dat,2)
    y(:,i) = yvals(i);
end

plot3(pts,y,f,'LineWidth',1.5);
set(gca,'FontSize',14,'LineWidth',1.5)
grid on
xlabel('data')
ylabel(ylab)
zlabel('ksdensity')
