% OmicsPlotFeatures(O,option)
%
%   Plotting of the features data (rows as lines)
%
%   option      plot options
%               ['']  get(O,'data') is plotted
%               'isnan'  isnan(O) is ploted
% 
%   sampleAnno  An array which is plotted as colorbar at the bottom
%               Can be used to indicate groups of samples (e.g. WT, KO)
%

function OmicsPlotFeatures(O,option,sampleAnno,subplots)
if ~exist('option','var') || isempty(option)
    option = '';
end
if ~exist('sampleAnno','var') || isempty(sampleAnno)
    sampleAnno = [];
end
if ~exist('subplots','var') || isempty(subplots)
    subplots = true;
end

switch lower(option)
    case {'na','nan','isnan'}
        dat = isnan(O);
    otherwise
        dat = get(O,'data');
end


if(subplots)
    fnames = get(O,'fnames');
    nx = ceil(sqrt(size(dat,1)));
    ny = ceil(size(dat,1)/nx);
    for i=1:size(dat,1)
        subplot(nx,ny,i)
        plot(dat(i,:));
        title(str2label(fnames{i}));
        if ~isempty(sampleAnno)
            hold on
            yl = ylim;
            hold on
            imagesc(1:size(dat,2),yl(1)-max(1.1,0.1*range(yl)),sampleAnno);
            yl = ylim;
            yl(2) = yl(2)+0.1*range(yl);
            ylim(yl);
        end
    end
else
    plot(dat');
end


