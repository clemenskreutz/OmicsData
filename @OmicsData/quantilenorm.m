% O = quantilenorm(O)
%
%   Quantile-normalization of the data in the @OmicsData object.
% 
%   Only samples (columns) with at least three data points (~isnan) are
%   considered (otherwise the remain unchanged).

function O = quantilenorm(O,varargin)

dat = get(O,'data');

ind = find(sum(~isnan(dat))>2);
datnorm = dat;
datnorm(:,ind) = quantilenorm(dat(:,ind), varargin{:});

O = set(O,'data',datnorm,'quantile-normalization');

