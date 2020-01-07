
function q = quantile(O,varargin)

dat = get(O,'data');

q = quantile(dat,varargin{:});