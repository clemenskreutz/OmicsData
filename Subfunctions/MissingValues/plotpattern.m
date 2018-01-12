
function plotpattern(O)

data_original = get(O,'data_original');
data_original(data_original==0) = nan;
data_full = get(O,'data_full');
data = get(O,'data');
mispat = get(O,'mis_pat');
Imp = get(O,'data_imput');

% Log
data_full(data_full<=0) = nan;
data(data<=0) = nan;
Imp(Imp<=0) = nan;
data_full = log10(data_full(:,:,1));
data = log10(data(:,:,1));
Imp = log10(Imp(:,:,1,1));

figure(1)
imagesc(isnan(data_original))
title('Missing pattern of original dataset')
colorbar
figure(2)
imagesc(mispat(:,:,1))
title('New created missing pattern')
colorbar
figure(3)
imagesc(data_full(:,:,1))
title('All known data')
colorbar
figure(4)
imagesc(data(:,:,1))
title('Data with filled missing values')
colorbar
figure(5)
imagesc(Imp(:,:,1,1))
title('Imputed data')
colorbar
figure(6)
diff = (data_full(:,:,1)-Imp(:,:,1,1));
clims = [ 0 1];
imagesc(diff,clims)
title('Difference of real dataset and imputed dataset')
colorbar