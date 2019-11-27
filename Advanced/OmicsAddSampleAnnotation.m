% O = OmicsAddSampleAnnotation(O,raw,snamesCol)
% 
%   Adding annotation for sample, e.g. clinical annotation from an Excel
%   sheet.
% 
%   O           @OmicsData object
%   raw         sample annotation as read by xlsread (and processed by cell2cell.m)
%   snamesCol   index or name indicating the columns containing sample
%               names
% 
% Example:
% [num,txt,raw] = xlsread('../Daten/Klinische Infos f OS_ck.xlsx');
% raw = cell2cell(raw,1);
% O = OmicsAddSampleAnnotation(O,raw,1)

function O = OmicsAddSampleAnnotation(O,raw,snamesCol)
if ~isnumeric(snamesCol)
    snamesCol = strmatch(snamesCol,raw(1,:),'exact');
    if length(snamesCol)~=1
        error('%s not found in raw(1,:)',snamesCol)
    end
end

sn = get(O,'snames');
snraw = raw(:,snamesCol);

[inter,ia,ib] = intersect(sn,snraw);
if length(inter)<length(sn)
    setdiff(snraw,sn)
    error('Not all sampleNames of O are found.')
end

for i=1:size(raw,2)
    if isempty(raw{1,i})
        error('Column name empty. This might originate from calling cell2cell without 2nd argument specifying the number of column headers.');
    end
end

annoNames = str2fieldname(raw(1,:));
for i=setdiff(1:size(raw,2),snamesCol)
%     add(O,'FeatureNames',ids,'col');
    annoTmp = cell(0);
    annoTmp(ia) = raw(ib,i)';
    if sum(~cellfun(@isnumeric,annoTmp))==0
        annoTmp = cell2array(annoTmp);
    end
    fprintf('--Annotation ''%s'' added as row ...\n',annoNames{i});
    O = add(O,annoNames{i},annoTmp,'row');
end



