function bool = checknan(O)

dat = get(O,'data');

bool = any(any(isnan(dat)));