% O = plus(O,summand)
% 

<<<<<<< HEAD
function O = plus(O,dat2)

dat = get(O,'data');
if isa(dat2,'OmicsData')
    dat2 = get(dat2,'data');
end
dat = dat + dat2;
=======
function O = plus(O,summand)

dat = get(O,'data');
dat = dat + summand;
>>>>>>> d8671062bf0008d5dc457cee80560c43597f1bec
O = set(O,'data',dat,'summation');

