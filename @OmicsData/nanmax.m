% m = nanmax(O)
% 
% m = nanmax(O,value,dim) 
% 
%   Maximum after removing NaN, arguments are the same as for nanmax.m

function m = nanmax(O,varargin)

m = nanmax(get(O,'data'),varargin{:});

