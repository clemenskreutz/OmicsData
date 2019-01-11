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
    O.cols.(O.config.default_col) = strcat('Col',num2strArray(1:size(data,2))); % row-names is a column
end

if ~isfield(O.rows,O.config.default_row)
    O.rows.(O.config.default_row) = strcat('Row',num2strArray(1:size(data,1)))';  % column-names is a row
end

