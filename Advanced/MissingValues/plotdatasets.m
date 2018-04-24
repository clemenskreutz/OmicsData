
function plotdatasets

global O

data_original = get(O,'data_original');
data_original(data_original==0) = nan;
data_full = get(O,'data_full');
data_mis = get(O,'data_mis');
mispat = get(O,'mis_pat');
Imp = get(O,'data_imput');

% Log
data_full(data_full<=0) = nan;
data_mis(data_mis<=0) = nan;
Imp(Imp<=0) = nan;
data_full = log10(data_full(:,:,1));
data_mis = log10(data_mis(:,:,1));
Imp = log10(Imp(:,:,1,1));

figure
subplot(3,2,1)
imagesc(isnan(data_original))
title('Missing pattern of original dataset')
colorbar
subplot(3,2,2)
imagesc(mispat(:,:,1))
title('New created missing pattern')
colorbar
subplot(3,2,3)
imagesc(data_full(:,:,1))
title('All known data')
colorbar
subplot(3,2,4)
imagesc(data_mis(:,:,1))
title('Data with assigned missing values')
colorbar
subplot(3,2,5)
imagesc(Imp(:,:,1,1))
title('Imputed data')
colorbar
subplot(3,2,6)
diff = (data_full(:,:,1)-Imp(:,:,1,1));
clims = [ 0 1];
imagesc(diff,clims)
title('Difference of real dataset and imputed dataset')
colorbar