% O = quantilenorm(O)
%
%   Quantile-normalization of the data in the @OmicsData object.

function O = quantilenorm(O,varargin)

dat = get(O,'data');

ind = find(sum(~isnan(dat))>2);
datnorm = dat;
datnorm(:,ind) = quantilenorm(dat(:,ind));

O = set(O,'data',datnorm,'quantile-normalization');

