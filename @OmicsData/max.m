function ma = max(O)

dat = get(O,'data');

if length(size(dat))==1
    ma = nanmax(dat);
elseif length(size(dat))==2
    ma = nanmax(nanmax(dat));
elseif length(size(dat))==3
    ma = nanmax(nanmax(nanmax(dat)));
elseif length(size(dat))==4
    ma = nanmax(nanmax(nanmax(nanmax(dat))));
else 
    fprintf('Implement max(o) for data sizes larger than 4 if you need it.')
end
