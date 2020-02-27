
function out = GetSignificance(out)

for i=1:size(out.stats,2)
    p(:,i) = out.stats(i).p(out.type~=2 & out.type~=3);
end

out.pmin = nanmin(p,[],2);

idxrem = [find(isnan(out.pmin))];    
idxrem(idxrem<4) = []; % keep offset/mean/linmean

out.idxrem = idxrem;
out.typesig = out.typenames(setdiff(1:length(out.type),idxrem));