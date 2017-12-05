% O = log10(O)
% 
%   Applies a log10-transformation to the data.

function O = log10(O)

dat = get(O,'data');
if sum(dat(:)<0)>0
    warning('OmicsData/log10.m: Data has negative numbers, log10-transformation is refused.');
else
    
    dat = log10(dat);
    dat(isinf(dat)) = NaN;
    
    O = set(O,'data',dat,'log10-transformation');
end
