function plot(O,varargin)

dat = get(O,'data');
plot(dat',varargin{:});
