
% O = deletemissing(O)
% 
%  Just data without missing values is used
%  delete all lines with at least one missing value

function O = deletemissing(O,missing)

if ~exist('missing','var')
    missing = [];
end

dat = get(O,'data');
O = set(O,'data_original',dat,'Save original dataset');

if missing == 0
    dat = dat(all(dat,2),:);                % delete all zero elements
elseif strcmp(missing,'nan') || strcmp(missing,'na') || strcmp(missing,'NaN') || strcmp(missing,'Na') || strcmp(missing,'NA')
    dat = dat(all(~isnan(dat),2),:);        % delete all nan elements
else
    dat = dat(all(~isnan(dat),2),:);        % delete all zero elements AND all nan elements
    dat = dat(all(dat,2),:);                % because often intensitys are zero, meaning not detected
end                                         % in example data files, no nans, just zero intensities in 30%
    
if isempty(dat)
    warning('Data is not changed. There is no line without a missing and/or zero value.');
else
    O = set(O,'data',dat,'Delete all lines with missing values');
    O = set(O,'data_full',dat,'Full dataset without missing values.');
    fprintf('All lines with missing values deleted.\n')
end

