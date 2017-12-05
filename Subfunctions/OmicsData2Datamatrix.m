% This function reshapes the data according to sample names:
% Sample names are determined by replacing pattern LFQintensity, and the
% related columns, and prefix/suffixes of these columns  
% 
function [dataMat, rownames,colnames] = OmicsData2Datamatrix(data,rownames,pattern)
if ~exist('pattern','var') || isempty(pattern)
    pattern = 'LFQintensity';    
end

fndata = fieldnames(data)';  % should be a row
ind = find(~cellfun(@isempty,regexp(fndata,pattern,'Match','ignorecase')));
while isempty(ind)
    warning('Cannot determine sample names be replacing pattern ''%s''. The data might be SILAC. Alter code be introducing a new pattern.',pattern);    
    fprintf('Column names in the file:\n');
    fprintf('  %s\n',fndata{:});
    pattern = [];
    while isempty(pattern)
        pattern = input('>Please specify a search pattern used by regexp(...,''ignorecase''): ','s');
    end
    ind = find(~cellfun(@isempty,regexp(fndata,pattern,'Match','ignorecase')));
end
snames = cell(size(ind));
related = cell(size(ind)); % indices belonging to one sample
relatedNames = cell(size(ind)); % column names belonging to one sample
for i=1:length(ind)
    snames{i} = regexprep(fndata{ind(i)},pattern,'','ignorecase');
end

% sort according to length
slen = cellfun(@length,snames);
[~,rf] = sort(-slen);
snames = snames(rf);
clear ind % since the order does not fit to snames any more

for i=1:length(snames)
    related{i} = find(~cellfun(@isempty,strfind(fndata,snames{i})));
    if i>1
        % if shorter sample names fit to the fieldnames, don't assing it again:
        related{i} = setdiff(related{i},[related{1:(i-1)}]); % only chosing once, first match
    end
    relatedNames{i} = strrep(fndata(related{i}),snames{i},'');
end
tmp = [relatedNames{:}];
uniDatNames = unique({tmp{:}});  % the fieldnames of the struct with data matrices
dataMat = struct;


% initialized Matrix
nrows = size(data.(fndata{1}),1);
for j=1:length(uniDatNames)
    dataMat.(uniDatNames{j}) = NaN(nrows,length(relatedNames));
end

removeFromData = cell(0);
for i=1:length(relatedNames)
    % Find data fields which match to samplenames
    [~,ia,ib] = intersect(relatedNames{i},uniDatNames);
    for ii=1:length(ia)
        removeFromData = [removeFromData,{fndata{related{i}(ia(ii))}}];
        dataMat.(uniDatNames{ib(ii)})(:,i) = data.(fndata{related{i}(ia(ii))});
    end
        
end

%% Remove data fields which matched to sample data (sample-individual data):
for i=1:length(removeFromData)
    data = rmfield(data,removeFromData{i});
end

%% Shift remaing data vectors to rownames, since it is annotation for all samples
fn2 = fieldnames(data);
for i=1:length(fn2)
    rownames.(fn2{i}) = data.(fn2{i});
    data = rmfield(data,fn2{i});
end

colnames = snames;  % sample names are the column names
