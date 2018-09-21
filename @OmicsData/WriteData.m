% status = WriteData(O,file)
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

function status = WriteData(O,file,decsep)
if(~exist('decsep','var') | isempty(decsep))
    decsep = '.';
end

data       = get(O,'data');
snames   = get(O,'snames');

%% Annotation of the rows (i.e. all columns O.cols of @OmicsData)
[colval,colnames] = getColumns(O,'char');
titel = '';
for i=1:length(colnames)
    titel = [titel,'\t',colnames{i}];
end
for i=1:length(snames)
    titel = [titel,'\t',snames{i}];
end
titel = [titel(3:end),'\n'];

%% Writing
fid = fopen(file,'w');
fprintf(fid,titel);
for ig=1:size(colval,1)
    fprintf(fid,'%s',colval{ig,1});
    for c=2:size(colval,2)
        fprintf(fid,'\t%s',colval{ig,c});
    end
    
    for ih = 1:length(snames)
        fprintf(fid,'\t%s',strrep(sprintf('%f',data(ig,ih)),'.',decsep));
    end
    fprintf(fid,'\n');
end

status = fclose(fid);




