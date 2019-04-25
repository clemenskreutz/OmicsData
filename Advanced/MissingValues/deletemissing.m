
%  deletemissing
%  delete all lines with at least one missing value

function deletemissing

global O

if ~exist('O','var')
    error('MissingValues/LogisticNanModel.m requires class O as global variable or input argument.')
end

dat = get(O,'data');

%% Remember original dataset
O = set(O,'data_original',[]);          % Put in container so it stays original (always same size)  
O = set(O,'data_original',dat,'Original dataset.');

%% Delete all nan elements
[idx,~] = find(isnan(dat));                               
idx = unique(idx);
rows = 1:size(dat,1);
comp = setdiff(rows,idx);


%% Output message
if isempty(idx)
    warning('Data is not changed. There is no line without a missing and/or zero value.\n');
elseif isempty(comp)
    warning('Data is not changed. All lines have a missing and/or zero value.\n')
else
    O = O(comp,:);
    warning('All lines with missing values deleted.\n')   
end

