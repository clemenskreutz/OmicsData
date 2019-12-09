% image(O,map)
%
%   Plottet eine Heatmap in der ArrayView von einer Eigenschaft
%
%   map         Die Colormap, default: map = redgreencmap.
% 
%   resizeFig   [true]
%               If true, then     set(gcf,'Position',[500  100  700  700])
% 
%   omitOutlierQuantile     [0]
%               The fraction of outliers (quantiles) that are set to
%               the Quantile in order to not impact the colorbar
%               Example: If omitOutlierQuantile=0.01, then the smalles 1%
%               and the largest 1% (>99%) are set to the 0.01 and 0.99
%               quantiles
%               
% Examples:
% image(Osim2,[],[],0.02)  % set smallest 2% and largest 2% to resp. quantiles
% 

function image(O,map,resizeFig,omitOutlierQuantile)
if ~exist('resizeFig','var') || isempty(resizeFig)
    resizeFig = true;
end
if ~exist('omitOutlierQuantile','var') || isempty(omitOutlierQuantile)
    omitOutlierQuantile = 0;
elseif omitOutlierQuantile>=0.5 || omitOutlierQuantile<0
    error('omitOutlierQuantile has to be in the range [0,0.5)')
end

if(~exist('map','var') | isempty(map))
    rgmap = redgreencmap;
else
    rgmap = map;
end

dat = get(O,'data');
q1 = quantile(dat(:),omitOutlierQuantile);
q2 = quantile(dat(:),1-omitOutlierQuantile);
dat(dat>q2) = q2;
dat(dat<q1) = q1;


Min = nanmin(dat(:));
Max = nanmax(dat(:));
clim = NaN(1,2);
clim(1) = Min;
clim(2) = Max;

if Max-Min > 1000
    warning('Data spread over more than 3 orders of magnitude. No log-transformation applied.')
end

% NaNs ersetzen, so dass sie weiss sind (1. Zeile in der colormap)
indnan = find(isnan(dat));

if(length(indnan)>0)%(nspots-get(O,'nf')))
    cmap = [1,1,1;rgmap];
    clim(1) = Min - 1*(Max-Min)./(size(cmap,1)-2);
    dat(indnan) = clim(1);
%     dat(indnot) = Min - 1*(Max-Min)./(size(cmap,1)-2) + 10*eps; % Damit das runden nicht falsche Farbe macht
% else
%     cmap = [0,0,1;rgmap];
%     clim(1) = Min - 1*(Max-Min)./(size(cmap,1)-1);
%     dat(indnot) = clim(1);
else
    cmap = rgmap;
end
dat(find(dat==Min)) = Min+10*eps; % Damit das runden nicht falsche Farbe macht

imagesc(dat,clim);
colormap(gca,cmap);
colorbar
ylabel('features')
xlabel('samples')

if resizeFig
    set(gcf,'Position',[500  100  700  700])
end

title(str2label(get(O,'default_data')));

