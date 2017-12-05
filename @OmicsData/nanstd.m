% sd = nanstd(O)
% 
% sd = nanstd(O,flag, dim)
% 
%   SD after removing NaN along dimension dim. 
%   arguments are the same as for nanstd.m

function sd = nanstd(O,varargin)

sd = nanstd(get(O,'data'),varargin{:});

