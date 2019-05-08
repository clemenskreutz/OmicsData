% OmicsKernelDensityPlot(O, [yvals], [ylab], [option])
% 
%   Plotting of the difference of the individaul pdfs of the samples via 
%   and the density of the complete data set.
% 
%   yvals   the numbers used for each sample as y-axis
% 
%   ylab    string used as ylabel
% 
%   option  '' do nothing (default)
% 
%           'renormalize': Each density is multipied with the proportion
%           of missing, i.e. not every density has area 1. 
%           Density and reference densitiy are multiplied.
%           This plot indicates where NA occurs compared to the whole data
%           set.
% 
% Example: 
% [~,rf] = sort(sum(isnan(O),1));
% Osort = set(O(:,rf),'name','raw, NA sorted');
% OmicsKernelDifferencePlot(Osort,sum(isnan(Osort),1)/get(Osort,'nf'),'NA','renormalize' );


function OmicsKernelDifferencePlot(O, yvals, ylab, option)
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
if ~exist('option','var') || isempty(option)
    option = '';
end

[f,pts] = ksdensity(O,'samples');
[fref,pts2] = ksdensity(O,'all');
if sum(abs(pts-pts2))>0
    error('discretization does not coincide. Improve the code.')
end

switch option
    case '' % do nothing
    case 'renormalize' % the area of the density is proportional to the proportion of available data
        for i=1:size(f,2)
            f(:,i) = f(:,i)*sum(~isnan(O(:,i)))/get(O,'nf');
        end
        fref = fref * sum(sum(~isnan(O)))/get(O,'nf')/get(O,'ns');
    otherwise
        option
        error('Option unknown.')
end
        

fplot = f-fref*ones(1,size(f,2));

nx = ceil(sqrt(size(f,2)));
ny = ceil(size(f,2)/nx);
yls = NaN(size(f,2),2);

figure
for i=1:size(f,2)
    subplot(nx,ny,i)
    plot(pts,fplot(:,i));
    grid on
    yls(i,:) = ylim;
    title(sprintf('%.2f %s',yvals(i),ylab))
    set(gca,'FontSize',5);
end
yl = [nanmin(yls(:,1)),nanmax(yls(:,2))];

for i=1:size(f,2)
    subplot(nx,ny,i)
    ylim(yl);
end
% suptitle(['ksdensity, sample - all (',option,')']);
suptitle(get(O,'name'));

