% med = nanmedian(O)
% 
%   average after removing NaN

function med = nanmedian(O,varargin)

med = nanmedian(get(O,'data'),varargin{:});

