% status = WriteMatrix(O,file,matrix,decsep)
% 
%   Writing the data to a file including the annotating columns.
% 
%   O           @OmicsData
%   
%   file        filename
% 
%   decsep      character used as seperator of decimal digits
%                   Default: '.'
% 
%   status      the output of the fclose function. A value zero indicates
%               normal exit status.
% 
% Example:
% WriteData(O, 'Data.xls', ',')

function status = WriteMatrix(O,file,matrix,colnames,decsep)
if ~exist('decsep','var') || isempty(decsep)
    decsep = '.';
end
if ~exist('colnames','var') || isempty(colnames)
    colnames = strcat('Column ',num2strArray(1:size(matrix,2)));
elseif length(colnames) ~= size(matrix,2)
    error('length(colnames) ~= size(matrix,2)')
end

fnames = get(O,'fnames');

%% Annotation of the rows (i.e. all columns O.cols of @OmicsData)
titel = get(O,'default_col');
for i=1:length(colnames)
    titel = [titel,'\t',colnames{i}];
end
titel = [titel,'\n'];

%% Writing
fid = fopen(file,'w');
fprintf(fid,titel);
for ig=1:size(matrix,1)
    fprintf(fid,'%s',fnames{ig});
    for ih = 1:size(matrix,2)
        fprintf(fid,'\t%s',strrep(sprintf('%f',matrix(ig,ih)),'.',decsep));
    end
    fprintf(fid,'\n');
end

status = fclose(fid);




