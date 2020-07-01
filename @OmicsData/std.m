% sd = std(O)
% 
% sd = std(O,flag, dim)

function sd = std(O,varargin)

sd = std(get(O,'data'),varargin{:});

