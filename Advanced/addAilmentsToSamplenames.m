% O = addAilmentsToSamplenames(O,whichOnes)
% 
% This function add a letter according to the values of logical properties
% (rows)
% 
% Example:
function O = addAilmentsToSamplenames(O,whichOnes)

if ~iscell(whichOnes)
    if ischar(whichOnes)
        whichOnes = {whichOnes};
    else
        error('whichOnes should be char or cell');
    end
end

snames = get(O,'snames');

for ix=1:length(whichOnes)
    x = get(O,whichOnes{ix});
    if size(x,2)==1 
        x = x'; % make a row
    end
    if size(x,1)~=1 || size(x,2)~=size(O,2)
        error('Property %s is not a row',whichOnes{ix});
    end
    
    ind = find(x==1);
    for i=1:length(ind)
        snames{ind(i)} = [snames{ind(i)},' ',whichOnes{ix}(1)];
    end

end
O = set(O,'snames',snames);