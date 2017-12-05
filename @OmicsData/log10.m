% O = log10(O)
% 
%   Applies a log10-transformation to the data.

function O = log10(O)

dat = get(O,'data');
dat = log10(dat);
dat(isinf(dat)) = NaN;

O = set(O,'data',dat,'log10-transformation');