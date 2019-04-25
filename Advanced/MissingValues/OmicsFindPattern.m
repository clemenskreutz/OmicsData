% ind = OmicsFindPattern(data,[pattern])
%
% ind - column index which includes pattern in column name

function ind = OmicsFindPattern(raw,pattern)

%% go for pattern search in fieldnames
%raw{1,:} = fieldnames(data)';  % should be a row

if ~exist('pattern','var') || isempty(pattern)
    pattern = 'LFQIntensity';
end
ind = find(contains(raw(1,:),pattern,'IgnoreCase',true));

if isempty(ind)
    pattern = 'LFQ Intensity';
    ind = find(contains(raw(1,:),pattern,'IgnoreCase',true));
end
if isempty(ind)
    pattern = 'IntensityLFQ';
    ind = find(contains(raw(1,:),pattern,'IgnoreCase',true));
end
if isempty(ind)
    pattern = 'Intensity';
    ind = find(contains(raw(1,:),pattern,'IgnoreCase',true));
end
while isempty(ind)
    warning('Cannot determine sample names be replacing pattern ''%s''. The data might be SILAC. Alter code be introducing a new pattern.',pattern);
    fprintf('Column names in the file:\n');
    fprintf('  %s\n',raw{1,:});
    pattern = [];
    while isempty(pattern)
        pattern = input('>Please specify a search pattern used by regexp(...,''ignorecase''): ','s');
    end
    ind = find(contains(raw(1,:),pattern,'IgnoreCase',true));
end
if any(strcmp(raw(1,:),pattern))
    ind(ind==find(strcmp(raw(1,:),pattern))) = []; %{[fndata{strcmp(fndata,pattern)} '_0']};
end