% O = mtimes(O,summand)
% 

function O = dot(O,summand)

dat = get(O,'data');
dat = dat .* summand;
O = set(O,'data',dat,'multiplication');

