% O = range(O)
% 
% O = range(O,dim)
% 
%   range of the data, i.e. max - min along dimension dim

function m = range(O,varargin)

m = range(get(O,'data'),varargin{:});

