
% O = deletemissing(O)
% 
%  Just data without missing values is used
%  delete all lines with at least one missing value

function O = deletemissing(O,missing)

if ~exist('missing','var')
    missing = [];
end

dat = get(O,'data');

if missing == 0                          % delete all zero elements
    [idx,~] = find(~dat);              % find looks for nonzero elements
elseif strcmp(missing,'mix')
    [idx,~] = find(isnan(dat));        % delete all zero elements AND all nan elements
    [idx2,~] = find(~dat);               % in example dataset02 really a mixture exists
    idx = [idx idx2];
else
    [idx,~] = find(isnan(dat));       % delete all nan elements
end                                     
idx = unique(idx);
rows = 1:size(dat,1);
comp = setdiff(rows,idx);

if isempty(idx)
    warning('Data is not changed. There is no line without a missing and/or zero value.\n');
elseif isempty(comp)
    warning('Data is not changed. All lines have a missing and/or zero value.\n')
else
    O = set(O,'data_original',dat,'Original dataset.');
    O = O(comp,:); 
    warning('All lines with missing values deleted.\n')   

end

