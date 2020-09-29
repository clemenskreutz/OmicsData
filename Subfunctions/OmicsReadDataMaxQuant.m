% 
%   data            struct with different data fields
%   rownames        struct with different rownames
%   colnames        struct with different column-names

function [data, rownames, colnames] = OmicsReadDataMaxQuant(file)
%%
[pfad,name,ext] = fileparts(file);
if isempty(ext)
    fprintf('No file extension specified, assuming xls/xlsx ...\n');
end

%% This block reads the file and produces depending on the file structure the variables
% dat, labels1 (row names), labels2 (column names)
switch ext
    case {'','.xls','.xlsx'}
%         ssds = spreadsheetDatastore(file)        
        fprintf('Reading excel file %s ... \n',file);
        [~,sheets] = xlsfinfo(file);
        if iscell(sheets) && length(sheets)>1
            fprintf('The data contains several sheets. Please select the right sheet [Type in a number]!\n');
            isheet = OmicsInputSelection(sheets, 'Which sheet contains the data? ', 'int');
            sheet = sheets{isheet};
        else 
            sheet = sheets{1};
        end
        [~,~,raw] = xlsread(file,sheet);  % NaN are returned as numeric
        
        raw = xlsProcessRaw(raw);
    case '.txt'
        fprintf('Reading txt file %s ... \n',file)
        warning('off','MATLAB:table:ModifiedVarnames');
        try
            ds = tabularTextDatastore(file,'TreatAsMissing','','Delimiter','\t','CommentStyle','#');%,'MissingValue',0);
        catch
            ds = tabularTextDatastore(file,'TreatAsMissing','','Delimiter','\t');
        end
        warning('on','MATLAB:table:ModifiedVarnames');

        ds.SelectedFormats(1:end)={'%q'}; % read everything as character
        tab = readall(ds);
        ismis = ismissing(tab,{'' '.' 'NA' 'NaN','na'});
        
        raw = table2cell(tab);
        raw(ismis) = {'NaN'};
        
        fprintf('Conversion into numbers ')
        for i2=1:size(raw,2)
            try
                fprintf('.')
                raw(:,i2) = str2num_Cell(raw(:,i2));
            end
        end
        fprintf('\n');
        raw = [ds.VariableNames;raw];
        
    otherwise
        error('The function is not yet implemented for filetype %s.',ext)
end

% at this point, the variable "raw" is a cell matrix containing numbers or
% text.b

% Now checkt, which columns contain only numbers:
isnum = cellfun(@isnumeric,raw);
isdat1 = sum(isnum,2)>1;      % which rows (for filtering 1st dimension) are data (not only text)?
istxt2 = sum(isnum,1)==0;     % which columns (for filtering 2nd dimension) is text (no data)?
isdat2 = false(1,size(raw,2));% which columns (for filtering 2nd dimension) are data (conversion feasible)?
fprintf('Check into column of numbers ')
for i=1:size(raw,2)
    fprintf('.')
    try
        tmp = cell2mat(raw(isdat1,i));  % check whether conversion to numbers is feasible
        if isnumeric(tmp)
            isdat2(i) = true;
        end
    end
end

dat = cell2mat(raw(isdat1,isdat2));
labels1 = raw(isdat1,istxt2);       % rownames
labels2 = raw(1,isdat2);            % colnames
txtlabels = raw(1,istxt2);

data = struct;
rownames = struct;
colnames = struct;

for i=1:size(dat,2)
    fn = str2fieldname(labels2{i});
    data.(fn) = dat(:,i);
    colnames.(fn) = labels2{i};
end

for i=1:size(labels1,2)
    if ~isempty(txtlabels{i})
        fn = str2fieldname(txtlabels{i});
        rownames.(fn) = labels1(:,i);   
    end
end



% This function tries to convert strings to numbers,
% but stops conversion if one cell contains a string consisting of several
% numbers.
function s = str2num_Cell(n)
s = cell(size(n));
for i=1:length(n)
    tmp = str2num(n{i});
    if length(tmp)==1
        s{i} = tmp;
    else  % several number
        s = n;
        return
    end
end

