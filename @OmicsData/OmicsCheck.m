% O = OmicsCheck(O)
% 
%   Checking the class fields and structure and add missing properties.
% 
%   Programming hing: Add all desired checks here.
% 
%       O.rows  should have a field specified by O.config.default_row
%       O.cols  should have a field specified by O.config.default_col

function O = OmicsCheck(O)

if ~isfield(O.data,O.config.default_data)
    O.data.(O.config.default_data) = [];
end
data = get(O,'data');

if ~isfield(O.cols,O.config.default_col)
    O.cols.(O.config.default_col) = strcat('Row',num2strArray(1:size(data,1)))'; % default column (e.g. default rownames)
end

if ~isfield(O.rows,O.config.default_row)
    O.rows.(O.config.default_row) = strcat('Col',num2strArray(1:size(data,2)));  % default row, e.g. the default column-names
end

%% check whether all columns, rows, and data-matrices have correct size:
fnrow = fieldnames(O.rows);
fncol = fieldnames(O.cols);
fndat = fieldnames(O.data);

dim1 = []; % size(data,1) and size(col,1) and length(col)
dim2 = []; % size(data,2) and size(row,2) and length(row)
for i=1:length(fndat)
    if ~isempty(O.data.(fndat{i}))
        if isempty(dim1) && isempty(dim2)
            dim1 = size(O.data.(fndat{i}),1);
            dim2 = size(O.data.(fndat{i}),2);
        else
            if size(O.data.(fndat{i}),1)~=dim1
                error('size(O.data.%s,1)~=dim1',fndat{i})
            end
            if size(O.data.(fndat{i}),2)~=dim2
                error('size(O.data.%s,2)~=dim2',fndat{i})
            end
        end
    end
end

for i=1:length(fnrow)
    if ~isempty(O.rows.(fnrow{i}))
        if size(O.rows.(fnrow{i}),1)~=1
            error('size(O.rows.%s,1)~=1',fnrow{i})
        end
        if size(O.rows.(fnrow{i}),2)~=dim2
            error('size(O.rows.%s,2)~=dim2',fnrow{i})
        end
    end
end
for i=1:length(fncol)
    if ~isempty(O.cols.(fncol{i}))
        if size(O.cols.(fncol{i}),1)~=dim1
            error('size(O.cols.%s,1)~=dim1',fncol{i})
        end
        if size(O.cols.(fncol{i}),2)~=1
            error('size(O.cols.%s,2)~=1',fncol{i})
        end
    end
end
