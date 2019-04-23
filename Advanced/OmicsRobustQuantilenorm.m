% O = OmicsDataRobustQuantilenorm(O)
%
% O = OmicsDataRobustQuantilenorm(O,meanfun)
% 
%   meanfun     @nanmedian (Default)
%               @nanmean
%
%   Robust quantile-normalization of the samples.

function O = OmicsRobustQuantilenorm(O,meanfun)
if ~exist('meanfun','var') || isempty(meanfun)
    meanfun = @nanmedian;
end

dat = get(O,'data');

ind = find(sum(~isnan(dat))>2);  % columns with at least two data-points
if length(ind)<size(dat,2)
    disp('OmicsDataRobustQuantilenorm.m: Columns with less than two data points are not considered.')
end

datnorm = dat;
rowmedians = feval(meanfun,dat(:,ind),2)*ones(1,size(dat(:,ind),2));

datnorm(:,ind) = quantilenorm(dat(:,ind)-rowmedians) + rowmedians;

O = set(O,'data',datnorm,['robust quantile-normalization with @',char(meanfun)]);

