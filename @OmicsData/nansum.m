% s = nansum(O)
% 
% s = nansum(O,value,dim) 
% 
%   Sum of the data after removing NaN, arguments are the same as for nansum.m

function s = nansum(O,varargin)

s = nansum(get(O,'data'),varargin{:});

