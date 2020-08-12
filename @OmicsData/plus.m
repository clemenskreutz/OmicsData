% O = plus(O,summand)
% 

function O = plus(O,dat2)

dat = get(O,'data');
if isa(dat2,'OmicsData')
    dat2 = get(dat2,'data');
end
dat = dat + dat2;
O = set(O,'data',dat,'summation');

