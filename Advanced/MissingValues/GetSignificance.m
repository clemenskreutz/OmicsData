
function out = GetSignificance(out)

for i=1:size(out.stats,2)
    p(:,i) = out.stats(i).p(out.type~=2 & out.type~=3);
end

out.p = p;
out.pmax = nanmax(p,[],2);
out.pmin = nanmin(p,[],2);
out.ptype = out.typenames(out.type~=2 & out.type~=3);

% pmax = out.pmax(4:end); % offset/mean/linmean stay predictor independent of significance
% pmin = out.pmin(4:end);

idxrem = [find(isnan(out.pmin))];     % indices of not significant  ; find(pmin>0.1)
% if p(1)<p(2)                  
%     idxrem = [3; idxrem];      % take mean
% else
%     idxrem = [2; idxrem];  % or keep linearized mean
% end
out.idxrem = idxrem;
out.typesig = out.typenames(setdiff(1:length(out.type),idxrem));