% raw = xlsProcessRaw(raw)
% 
% This function process the output "raw" of xlsread, i.e.
%   - replaces 'na' by 'NaN'
%   - replaces in numeric columns (more numeric than char) 
%       {'NaN'} into numeric {[NaN]}
%       {'ActiveX VT_ERROR: '} by {[NaN]};
%   - replaces in string columns (more strings than numeric ) 
%       TODO: {[]} into numeric {''}
%       {'NaN'} by {''};
%       {'ActiveX VT_ERROR: '} by {''};



function raw = xlsProcessRaw(raw)

for i=1:size(raw,2)
    raw(:,i) = xlsProcessRaw_array(raw(:,i));
end


function raw = xlsProcessRaw_array(raw)

ichar = find(cellfun(@ischar,raw));
inum  = find(cellfun(@isnumeric,raw));

indna = strmatch('na',lower(raw(ichar)),'exact');
for ii=1:length(indna) % replace na by NaN
    raw{ichar(indna(ii))} = 'NaN';
end


indnan = strmatch('NaN',raw(ichar),'exact');
indVT = strmatch('ActiveX VT_ERROR: ',raw(ichar),'exact');
indnanNum = find(cellfun(@isnan,raw(inum)));

if length(ichar)-length(indnan) < length(inum)-length(indnanNum) % if more numbers than strings
    for ii=1:length(indnan)
        raw{ichar(indnan(ii))} = NaN;
    end
    for ii=1:length(indVT)
        raw{ichar(indVT(ii))} = NaN;
    end    
else  % more strings than numeric
    for ii=1:length(indnanNum)
        raw{inum(indnanNum(ii))} = '';
    end
    for ii=1:length(indVT)
        raw{ichar(indVT(ii))} = '';
    end    
end    
