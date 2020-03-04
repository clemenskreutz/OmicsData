function X = QuantileRescalingX(X,out)

idx = find(out.type~=2 & out.type~=3)-1;
idx(idx==0) = [];
for s=1:length(idx)
    nprot = sum(~isnan(X(:,s)));
    qs = linspace(0,1,nprot*2+1)';
    qs = qs(2:2:end-1);
    q = quantile(out.X(:,s),qs);   
    qNaN = [q; nan(size(X,1)-length(q),1)];
    [~,idx] = sort(X(:,s));
    idxr(idx) = 1:size(X,1);
    X(:,s) = qNaN(idxr);
end