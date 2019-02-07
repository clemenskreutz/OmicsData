% raw = OmicsReadData(file)
%
% This is a general function to read in a specified file (.xls or .txt)
% returns matrix with strings and numbers
% to filter for data and rownames use OmicsData2Struct
%
% SEE ALSO xlsread, tabularTextDatastore

function raw = OmicsReadData(file)

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
                
    case '.txt'
        fprintf('Reading txt file %s ... \n',file)
        warning('off','MATLAB:table:ModifiedVarnames');
        ds = tabularTextDatastore(file,'TreatAsMissing','','Delimiter','\t','CommentStyle','#');%,'MissingValue',0);
        warning('on','MATLAB:table:ModifiedVarnames');

        ds.SelectedFormats(1:end)={'%q'}; % read everything as character
        tab = readall(ds);
        ismis = ismissing(tab,{'' '.' 'NA' 'NaN','na'});
        
        raw = table2cell(tab);
        raw(ismis) = {'NaN'};
        
        % for ImpToTxt not necessary to convert to numbers, takes long
%         fprintf('Conversion into numbers ')
%         for i2=1:size(raw,2)
%             try
%                 fprintf('.')
%                 raw(:,i2) = str2num_Cell(raw(:,i2));
%             end
%         end
%         fprintf('\n');
         raw = [ds.VariableNames;raw];
        
    otherwise
        error('The function is not yet implemented for filetype %s.',ext)
end