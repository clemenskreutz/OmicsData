% s = size(O)
% 
%   This function makes the same as size.m for the data in the object.

function out = size(O,n)

if exist('n','var') && ~isempty(n)
    s = size(get(O,'data'));
    if length(s)>=n
        out = s(n);
    else
        warning('OmicsData/size.m: Dimension of O is smaller than dimension you entered as argument.')
        out = [];
    end  
else    
    out = size(get(O,'data'));
end