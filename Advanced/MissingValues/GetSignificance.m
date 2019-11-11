
function out = GetSignificance(out)

for i=1:size(out.stats,2)
    p(:,i) = out.stats(i).p(out.type~=2 & out.type~=3);
end

out.p = p;
out.pmax = nanmax(p,[],2);
out.pmin = nanmin(p,[],2);
out.ptype = out.typenames(out.type~=2 & out.type~=3);

pmax = out.pmax(2:end); % offset stays predictor independent of significance
pmin = out.pmin(2:end);

idxrem = [find(isnan(pmin)) find(pmin>0.01)];     % indices of not significant

if length(pmin)-length(idxrem)<2
    idxrem = [find(isnan(pmin)) find(pmin>0.1)];  % if just one predictor, take 0.1% significance
    if length(pmin)-length(idxrem)<2      % if still just 0 or 1 predictor
        if p(1)<p(2)                  
            idxrem = 2:length(pmin);      % take mean
        else
            idxrem = [1 3:length(pmin)];  % or linearized mean
        end
    end
end
out.idxrem = idxrem;
