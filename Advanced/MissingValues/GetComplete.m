
%  O = GetComplete(O)
%
%  delete all lines with at least one/two missing value
%  if th

function O = GetComplete(O)

if ~exist('O','var')
    error('MissingValues/GetComplete.m requires class O as input argument.')
end

%% Remember original dataset
O = set(O,'data_original',[]);          % Put in container so it stays original (always same size)  
dat = get(O,'data');
O = set(O,'data_original',dat,'Original dataset');

%% Delete all nan elements
if sum(~any(isnan(O),2))>50
    O = O(~any(isnan(O),2),:);
    fprintf('All lines with missing values deleted.\n')  
elseif sum(sum(isnan(O),2)<2)>50
    O = O(sum(isnan(O),2)<2,:);
    fprintf('All lines with more than one missing values deleted.\n') 
else
    O = O(sum(isnan(O),2)<3,:);
    fprintf('All lines with more than two missing values deleted.\n')        
end

%% Remember complete dataset
O = set(O,'data_complete',[]);          % Put in container so it stays same 
dat = get(O,'data');
O = set(O,'data_complete',dat,'Complete dataset');
