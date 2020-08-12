% O = mtimes(O,summand)
% 

function O = mtimes(O,summand)

dat = get(O,'data');
<<<<<<< HEAD
dat = dat .* summand;
=======
dat = dat * summand;
>>>>>>> d8671062bf0008d5dc457cee80560c43597f1bec
O = set(O,'data',dat,'multiplication');

