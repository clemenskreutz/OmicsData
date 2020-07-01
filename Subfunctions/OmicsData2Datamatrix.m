% [dataMat, rownames,colnames,default_data] = OmicsData2Datamatrix(data,rownames,pattern)
%
% This function reshapes the data according to sample names:
% Sample names are determined by replacing a pattern, e.g. 'LFQintensity', and the
% related columns, and prefix/suffixes of these columns
%
%   pattern     for searching data-type names, e.g. 'LFQintensity'
%               This pattern should contain everything which does not name
%               the individual samples


function [dataMat, rownames,colnames,default_data] = OmicsData2Datamatrix(data,rownames,pattern)


%% go for pattern search in fieldnames
fndata = fieldnames(data)';  % should be a row

if ~exist('pattern','var') || isempty(pattern)
    pattern = 'LFQIntensity';
end
ind = find(~cellfun(@isempty,regexp(fndata,pattern,'Match','ignorecase')));

if isempty(ind)
    pattern = 'LFQ';
    ind = find(~cellfun(@isempty,regexp(fndata,pattern,'Match','ignorecase')));
end
if isempty(ind)
    pattern = 'Intensity';
    ind = find(~cellfun(@isempty,regexp(fndata,pattern,'Match','ignorecase')));
end
if isempty(ind)
    pattern = 'Abundance';
    ind = find(~cellfun(@isempty,regexp(fndata,pattern,'Match','ignorecase')));
end
if any(strcmp(fndata,pattern)) % remove column Intensity because it has other meaning in MaxQuant
    ind(ind==find(strcmp(fndata,pattern))) = []; %{[fndata{strcmp(fndata,pattern)} '_0']};
end
while isempty(ind)
    warning('Cannot determine sample names be replacing pattern ''%s''. The data might be SILAC. Alter code be introducing a new pattern.',pattern);
    fprintf('Column names in the file:\n');
    fprintf('  %s\n',fndata{:});
    pattern = [];
    while isempty(pattern)
        pattern = input('>Please specify a search pattern used by regexp(...,''ignorecase''): ','s');
    end
    ind = find(~cellfun(@isempty,regexp(fndata,pattern,'Match','ignorecase')));
    if any(strcmp(fndata,pattern)) % remove column Intensity because it has other meaning in MaxQuant
        ind(ind==find(strcmp(fndata,pattern))) = []; %{[fndata{strcmp(fndata,pattern)} '_0']};
    end
end
 
% Some later operations work only, if the data-type label is not in between
% samples-specific names. I therefore resort each string in fn_data
% accordingly
fndata_resort = fndata; 
snames = cell(size(ind));
related = cell(size(ind)); % indices belonging to one sample
relatedNames = cell(size(ind)); % column names belonging to one sample
for i=1:length(ind)
    snames{i} = regexprep(fndata{ind(i)},pattern,'','ignorecase');
    pattern2 = ['(',regexprep(fndata{ind(i)},pattern,')(.*?)(','ignorecase'),')'];
    ind2 = find(~cellfun(@isempty,regexp(fndata,pattern2,'Match')));
    
    for j=1:length(ind2)
        parts = regexp(fndata{ind2(j)},pattern2,'tokens');
        if length(parts{1})==3
            fndata_resort{ind2(j)} = [parts{1}{2},parts{1}{1},parts{1}{3}];% patter-mach first, then the rest
        end
    end
end

% sort according to length
slen = cellfun(@length,snames);
[~,rf] = sort(-slen);
snames = snames(rf);
clear ind % since the order does not fit to snames any more

for i=1:length(snames)
    related{i} = find(~cellfun(@isempty,strfind(fndata_resort,snames{i})));
    if i>1
        % if shorter sample names fit to the fieldnames, don't assing it again:
        related{i} = setdiff(related{i},[related{1:(i-1)}]); % only chosing once, first match
    end
    relatedNames{i} = fndata_resort(related{i});
    relatedNames{i} = strrep(fndata_resort(related{i}),snames{i},'');  %
%    did not work when Intensity is numbered by letters: IntensityA,
%    IntensityB, ... then I is replaced by: ntensityA
end
tmp = [relatedNames{:}];
uniDatNames = unique({tmp{:}});  % the fieldnames of the struct with data matrices
idxempty = find(cellfun(@isempty,uniDatNames));
if ~isempty(idxempty)
    uniDatNames(idxempty) = [];
end
dataMat = struct;


% initialized Matrix
nrows = size(data.(fndata{1}),1);
for j=1:length(uniDatNames)
%     if ~isletter(uniDatNames{j}(1))
%         uniDatNames{j} = uniDatNames{j}(2:end);
%     end
    dataMat.(str2fieldname(uniDatNames{j})) = NaN(nrows,length(relatedNames));
end

removeFromData = cell(0);
for i=1:length(relatedNames)
    % Find data fields which match to samplenames
    [~,ia,ib] = intersect(relatedNames{i},uniDatNames);
    for ii=1:length(ia)
        removeFromData = [removeFromData,{fndata{related{i}(ia(ii))}}];
        dataMat.(str2fieldname(uniDatNames{ib(ii)}))(:,i) = data.(fndata{related{i}(ia(ii))});
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

colnames = cellfun(@(c)[pattern c],snames,'uni',false);   % sample names are the column names

fnMat = fieldnames(dataMat);
default_data = fnMat{~cellfun(@isempty,regexp(fnMat,pattern,'ignorecase'))};



