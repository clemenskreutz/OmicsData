% OmicsVolcanoPlot(O,p,fold)
% 
%   p       p-values
% 
%   fold    fold-changes, usually at the log2 scale

function OmicsVolcanoPlot(O,p,fold)

y = -log10(p);
plot(fold,y,'.');
xlabel('fold-change [log2]')
ylabel('-log_{10}(p)');
title(get(O,'name'));

