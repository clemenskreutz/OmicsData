% O = OmicsRemoveEmptyFeatures(O,minN)
% 
%   This function eliminates rows/features which do not have a minimal
%   number of ~isnan && ~isinf data points.
% 
%   minN    the minmum number
%           [1] is the default value

function O = OmicsRemoveEmptyFeatures(O,minN)
if ~exist('minN','var') || isempty(minN)
    minN = 1;
end

dat = get(O,'data');
drin = find(sum(~isnan(dat) & ~isinf(dat),2)>=minN);

O = O(drin,:);
