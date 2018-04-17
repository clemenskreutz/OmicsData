% same = cellcmp(c1,c2)
% 
%   Vergleich zwei cell Objekte.
function same = cellcmp(c1,c2)
same = true;
if(sum(abs(size(c1)-size(c2)))~=0)
    same = false;
    return;
elseif(sum(abs(celllength(c1)-celllength(c2)))>0)
    same = false;
    return;
elseif(isempty(c1) & isempty(c2))
elseif(isnumeric(c1{1}))
    c1 = cell2array(c1);
    c2 = cell2array(c2);
    if(sum(abs(c1-c2))~=0)
        same = false
        return;
    end
elseif(ischar(c1{1}))
    same = strcmpCell(c1,c2);
elseif(iscell(c1{1}))
    for i=1:length(c1)
        same = cellcmp(c1{i},c2{i});
        if(~same)
            return;
        end
    end
else
    save error
    class(c1)
    class(c2)
    error('cellcmp(c1,c2) not yet implemented for this class.')
end
