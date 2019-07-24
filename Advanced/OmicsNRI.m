% nri = OmicsNRI(O)
% 
%   Calculates the frequency of having the same rank

function nri = OmicsNRI(O)

d = get(O,'data');

nri = NaN(1,size(d,2));
r = NaN(size(d));

for i=1:size(d,2)
    r(:,i) = rankasgn_fast(d(:,i));
end

for i=1:size(r,1)
    [l,anz] = levels(r(i,:));
    nri(i) = max(anz)/size(r,2);
end


