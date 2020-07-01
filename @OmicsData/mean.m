% m = mean(O)
% 
%   average

function m = mean(O,varargin)

m = mean(get(O,'data'),varargin{:});

