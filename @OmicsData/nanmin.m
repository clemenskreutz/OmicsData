% m = nanmin(O)
% 
% m = nanmin(O,value,dim) 
% 
%   Minimum after removing NaN, arguments are the same as for nanmin.m

function m = nanmin(O,varargin)

m = nanmin(get(O,'data'),varargin{:});

