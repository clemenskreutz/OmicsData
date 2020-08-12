% O = plus(O,summand)
% 

function O = rdivide(O,summand)

dat = get(O,'data');
dat = dat ./ summand;
O = set(O,'data',dat,'summation');

