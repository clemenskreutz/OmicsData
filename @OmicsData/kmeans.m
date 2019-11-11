function idx = kmeans(O,k)

if ~exist('k','var')
    k = 2;
end

if size(O,3)>1
    dat = get(O,'data');
    for i=1:size(O,3)
        idx = kmeans(dat(:,:,i)',k);
    end
else
    idx = kmeans(get(O,'data'),k);
end
 