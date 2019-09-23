
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
else
    for i=2:50
        if sum(sum(isnan(O),2)<i)>50
            O = O(sum(isnan(O),2)<i,:);
            fprintf(['All lines with <' num2str(i-1) ' MV deleted.\n']) 
            break
        end
    end
end
if size(O,1)==size(dat,1)
    for i=2:50
        if sum(sum(isnan(O),2)<i)>30
            O = O(sum(isnan(O),2)<i,:);
            fprintf(['All lines with <' num2str(i-1) ' MV deleted.\n']) 
            break
        end
    end
    warning('Too many MVs. Does imputation make sense here?')
end
if size(O,1)==size(dat,1)
    warning('Too many MVs. Does imputation make sense here?')
end

