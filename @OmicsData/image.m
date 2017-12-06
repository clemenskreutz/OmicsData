% image(O,map)
%
%   Plottet eine Heatmap in der ArrayView von einer Eigenschaft
%
%   map         Die Colormap, default: map = redgreencmap.

function image(O,map)

if(~exist('map','var') | isempty(map))
    rgmap = redgreencmap;
else
    rgmap = map;
end

dat = get(O,'data');

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
colormap(cmap);
colorbar
ylabel('features')
xlabel('samples')

nf = get(O,'nf');
set(gcf,'Position',[500  100  700  750])

title(str2label(get(O,'default_data')));

