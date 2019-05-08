% [f,x] = ksdensity(O, [option], [nx], [bandwidth])
% 
%   Kernel density estimation of the data over features
% 
%   option  'samples' or simply 's'
%           'features' or simply 'f'
%           'all'
% 
%   nx      number of x values along the smoothed axis
% 
%   bandwidth   the bandwithd parameter passed to ksdensity
% 
% 
%   f       smoothed data 
%           [nx  x nsamples]  for option 'samples'
%           [nx  x nfeatures]  for option 'features'
%           [nx  x 1]  for option 'all'
% 
%   x       x values ranging from min(data), ... , max(data)

function [f,x] = ksdensity(O,option,nx,bandwidth)
if ~exist('option','var') || isempty(option)
    option = 'samples';
end

if ~exist('bandwidth','var') || isempty(bandwidth)
    bandwidth = 0.7;
end
if ~exist('nx','var') || isempty(nx)
    nx = 200;
end

dat = get(O,'data');
switch option
    case {'a','all'}
        dat = dat(:);
    case {'s','samples',''}
        dat = dat; % do nothing
    case {'f','features'}
        dat = dat';
end

x = linspace(nanmin(dat(:)),nanmax(dat(:)),nx);

f = NaN(length(x),size(dat,2));
for i=1:size(dat,2)
    [f(:,i)] = ksdensity(dat(:,i),x,'Bandwidth',bandwidth);
end

