% status = WriteWithColnames(O, file, data, colnames, sortcolumn, celldata, decsep)
% 
% Writing any kind of results (in array/matrix "data" and "celldata") into
% a file including the annotating columns
% 
%   O   	@OmicsData
% 
%   file    filename, character
% 
%   data 	numeric array or matrix [nfeatures x length(colnames)]
% 
%   colnames    the names of the columns of the matrix "data" used as
%               header in the written table.
% 
%   sortcolumn 	an optional array of length [nfeatures x 1] used to sort
%               the written rows. A frequent choice is using the (negative)
%               absolute fold-change or the p-value.
% 
%   celldata 	data to be written in the cell format (e.g. for strings)
% 
%   decsep      character used as seperator of decimal digits
%                   Default: ',' [using '' would be slightly faster]
% 
% 
%   status      the output of the fclose function. A value zero indicates
%               normal exit status.

function status = WriteWithColnames(O, file, data, colnames, sortcolumn, celldata, decsep)
if(~exist('celldata','var') || isempty(celldata))
    celldata = cell(0);
end
if(~exist('decsep','var') || isempty(decsep))
    decsep = ',';
end

if(~exist('data','var'))
    data = [];
    colnames = [];
elseif(length(colnames) ~= size(data,2)+size(celldata,2))
    size(colnames)
    size(data)
    size(celldata)
    error('colnames has wrong length.')   
end
if(~exist('colnames','var') || isempty(colnames))
    for i=1:size(data,2)
        colnames{i} = '';
    end
end
if(exist('sortcolumn','var') && ~isempty(sortcolumn))
    [~,rf] = sort(sortcolumn);
    s = struct;
    s.type = '()';
    s.subs = {rf,':'};
    O = subsref(O,s);
    
    data = data(rf,:);        
    if(size(celldata,1)==length(rf))
        celldata = celldata(rf,:);
    else
        celldata = cell(0);
    end
end


%% Annotation of the rows (i.e. all columns O.cols of @OmicsData)
[colval,cnames] = getColumns(O,'char');
titel = '';
for i=1:length(cnames)
    titel = [titel,'\t',cnames{i}];
end
for i=1:length(colnames)
    titel = [titel,'\t',colnames{i}];
end
titel = [titel(3:end),'\n'];

%% Writing
if(isnumeric(data))
    type = 1;
elseif(iscell(data))
    type = 2;
else
    type = 3;
end

fid = fopen(file,'w');
fprintf(fid,titel);
for ig=1:size(colval,1)
    fprintf(fid,'%s',colval{ig,1});
    for c=2:size(colval,2)
        fprintf(fid,'\t%s',colval{ig,c});
    end
    
    if(type==1)
        if(isempty(decsep))
            for ih = 1:size(data,2)
                fprintf(fid,'\t%f',data(ig,ih));
            end
        else
            for ih = 1:size(data,2)
                s = sprintf('\t%f',data(ig,ih));
                fprintf(fid,strrep(s,'.',decsep));
            end
        end
    elseif(type==2)
        for ih = 1:size(data,2)
            fprintf(fid,'\t%s',data{ig,ih});
        end
    else
        for ih = 1:size(data,2)
            fprintf(fid,'\t%s',data(ig,ih));
        end        
    end
    for ih = 1:size(celldata,2)
        if(isempty(celldata{ig,ih}))
            fprintf(fid,'\t%s','');            
        elseif(iscell(celldata{ig,ih}))
            tmp = strcat(celldata{ig,ih}{:},';');
            fprintf(fid,'\t%s',tmp);            
        else
            fprintf(fid,'\t%s',celldata{ig,ih});
        end
    end        
    fprintf(fid,'\n');
end

status = fclose(fid);




