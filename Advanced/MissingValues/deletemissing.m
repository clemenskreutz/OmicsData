
%  deletemissing
%  delete all lines with at least one missing value

function O = deletemissing(O)

if ~exist('O','var')
    error('MissingValues/LogisticNanModel.m requires class O as input argument.')
end

%% Remember original dataset
O = set(O,'data_original',[]);          % Put in container so it stays original (always same size)  
dat = get(O,'data');
O = set(O,'data_original',dat,'Original dataset.');

%% Delete all nan elements
if sum(~any(isnan(O),2))<50
    if sum(sum(isnan(O),2)<2)<50
        O = O(sum(isnan(O),2)<3,:);
        warning('All lines with more than two missing values deleted.\n') 
    else
        O = O(sum(isnan(O),2)<2,:);
        warning('All lines with more than one missing values deleted.\n')   
    end
else
    O = O(~any(isnan(O),2),:);
     
    if size(O) == size(dat)
        warning('Data is not changed. There is no line without a missing and/or zero value.\n');
    else
        warning('All lines with missing values deleted.\n')  
    end
end

% [idx,~] = find(isnan(dat));                               
% idx = unique(idx);
% rows = 1:size(dat,1);
% comp = setdiff(rows,idx);

