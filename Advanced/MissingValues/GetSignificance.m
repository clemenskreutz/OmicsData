
function [sig,rem] = GetSignificance(out)

p = out.stats.p;
sig = struct;
sig.p = p(out.type~=2 & out.type~=3);
sig.type = out.typenames(out.type~=2 & out.type~=3);

[~,idx] = max(sig.p);
rem = sig.type(idx);
