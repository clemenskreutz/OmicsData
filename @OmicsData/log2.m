% O = log2(O)
% 
%   Applies a log2-transformation to the data (which should always be done
%   after loading raw data)

function O = log2(O)

dat = get(O,'data');
dat = log2(dat);
dat(isinf(dat)) = NaN;

O = set(O,'data',dat,'log2-transformation');