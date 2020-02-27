
% scales default data in O by quantiles of data C
function O = QuantileRescaling(O,C)

dat = nan(size(O));
for s=1:size(O,2)
    nprot = sum(~isnan(O(:,s)));
    qs = linspace(0,1,nprot*2+1)';
    qs = qs(2:2:end-1);
    q = quantile(C(:,s),qs);   
    qNaN = [q; nan(size(O,1)-length(q),1)];
    [~,idx] = sort(O(:,s));
    idxr(idx) = 1:size(O,1);
    dat(:,s) = qNaN(idxr);
end

O = set(O,'data',dat,'quantile rescaled');

fprintf('QuantileRescaling.m: O is scaled to quantiles of C.\n');

  