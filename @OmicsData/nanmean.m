% m = nanmean(O)
% 
%   average after removing NaN

function m = nanmean(O,varargin)

m = nanmean(get(O,'data'),varargin{:});

