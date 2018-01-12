% [fdr,q,fdrBH] = fdr_calculations(p)
% 
%   Calculates different FDRs based on an array of p-values using matlab's
%   function mafdr.m
% 
% [fdr,q,fdrBH] = fdr_calculations(p,groupvar)
% 
%   If a grouping variable is provided, FDRs are calculated for each set of
%   group-levels independently. groupvar is processed as done by grp2idx.m
% 
% Output:
% 
%   fdr         FDR according to Storey2002
%   fdrBH       FDR according to Benjamini-Hochberg1995
%   q           q-value
% 
% 
%   Examples:
% fdr0 = fdr_calculations(res.p);
% [fdr,fdrBH,q] = fdr_calculations(res.p,sum(isnan(O),2));

function [fdr,q,fdrBH] = fdr_calculations(p,groupvar)
if ~exist('groupvar','var')
    groupvar = [];
end

notnan = find(~isnan(p));

fdr = NaN(size(p));
fdrBH = NaN(size(p));
q   = NaN(size(p));

if ~isempty(groupvar)
    ind = grp2idx(groupvar(notnan));
    indlev = nanunique(ind);
else
    ind = ones(size(notnan));
    indlev = 1;
end

for i=1:length(indlev)
    indtmp = ind==indlev(i);

    [fdr(notnan(indtmp)),q(notnan(indtmp))] = mafdr(p(notnan(indtmp)));
    [fdrBH(notnan(indtmp))] = mafdr(p(notnan(indtmp)),'BHFDR',true);
end
        
        
