% status = WriteWithColnames(O, file, data, colnames, sortcolumn, appenddata, decsep)
% 
% Writing any kind of results (in array/matrix "data" and "appenddata") into
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
%   appenddata 	data to be written as last column(s), eg cell format for strings
% 
%   decsep      character used as seperator of decimal digits
%                   Default: ',' [using '' would be slightly faster]
% 
% 
%   status      the output of the fclose function. A value zero indicates
%               normal exit status.
% 
% Examples:
% WriteWithColnames(OmicsFilterColsSTY(O(1:100,:)),'Data.txt',get(O,'data'),get(O,'SampleNames'))

function status = WriteWithColnames(O, file, data, colnames, sortcolumn, appenddata, decsep)
if(~exist('appenddata','var') || isempty(appenddata))
    appenddata = cell(0);
end
if(~exist('decsep','var') || isempty(decsep))
    decsep = ',';
end

if(~exist('data','var'))
    data = [];
    colnames = [];
end
if(~exist('colnames','var') || isempty(colnames))
    for i=1:size(data,2)
        colnames{i} = '';
    end
elseif(length(colnames) ~= size(data,2)+size(appenddata,2))
    size(colnames)
    size(data)
    size(appenddata)
    error('colnames has wrong length.')   
end
if(exist('sortcolumn','var') && ~isempty(sortcolumn))
    if ~isnumeric(sortcolumn)
        idx = strcmp('p',colnames);
        if idx>size(data,2)
            sortcolumn = appenddata(:,idx-size(data,2));
        else
            sortcolumn = data(:,idx);
        end
    end
    [~,rf] = sort(sortcolumn);
    s = struct;
    s.type = '()';
    s.subs = {rf,':'};
    O = subsref(O,s);
    
    data = data(rf,:);        
    if(size(appenddata,1)==length(rf))
        appenddata = appenddata(rf,:);
    else
        appenddata = cell(0);
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
    for ih = 1:size(appenddata,2)
        if ~iscell(appenddata)
            fprintf(fid,'\t%f',appenddata(ig,ih));
        elseif(isempty(appenddata{ig,ih}))
            fprintf(fid,'\t%s','');            
        elseif(iscell(appenddata{ig,ih}))
            tmp = strcat(appenddata{ig,ih}{:},';');
            fprintf(fid,'\t%s',tmp);            
        else
            fprintf(fid,'\t%s',appenddata{ig,ih});
        end
    end        
    fprintf(fid,'\n');
end

status = fclose(fid);




