
% O = missingcol(O)
% 
%  Count number of missing values in columns
%  save in O.pattern

function O = missingcol(O,missing)

if ~exist('missing','var')
    missing = [];
end

dat = get(O,'data');

ncol = zeros(size(dat,2),1);
if missing == 0
    for i=1:size(dat,2)
        ncol(i) = sum(dat(:,i)==0);
    end                                        % count all zero elements in column
elseif strcmp(missing,'nan');
    ncol = sum(isnan(dat));                    % count all nan elements in column
else
    for i=1:size(dat,2)
        ncol(i) = sum(dat(:,i)==0)+sum(isnan(dat(:,i)));
    end                                         % count all zero AND nan elements in column
end                                             % in example data files, no nans, just zero intensities in 30%
    
if sum(ncol)==0
    warning('No missing and/or zero values detected (in missingcol.m)');
elseif any(isnan(ncol))
    warning('Something went wrong in counting missing values (in missingcol.m). Number of missing values is NaN.');
else
    O = set(O,'nmiscol',ncol);
end

