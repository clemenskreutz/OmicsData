% O = OmicsDataRobustQuantilenorm(O)
%
% O = OmicsDataRobustQuantilenorm(O,meanfun)
% 
%   meanfun     @nanmedian (Default)
%               @nanmean
% 
%   NRI_thresh  NRI stands for nearly rank-invariance. It denotes the fraction of
%               samples, where a protein has the same rank.
%               The robust version of the quantile normalization is applied
%               for all proteins with RI>=RI_thresh
%               For the remaining ones, traditional quantilenorm is applied.
%
%   Robust quantile-normalization of the samples.

function O = OmicsRobustQuantilenorm(O,meanfun,NRI_thresh)
if ~exist('meanfun','var') || isempty(meanfun)
    meanfun = @nanmedian;
end
if ~exist('NRI_thresh','var') || isempty(NRI_thresh)
    NRI_thresh = 0.5;
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

