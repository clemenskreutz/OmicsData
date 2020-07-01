% sorts O for mean value and for #MV
% works for input O AND data matrix

function [O,idx] = sortO(O)

 [~,idx1] = sort(nanmean(O,2));
 O = O(idx1,:);
 [~,idx2] = sort(sum(isnan(O),2));
 O = O(idx2,:);
 idx = idx1(idx2);