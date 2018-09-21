% re = isempty(O,field)
%       
%   Check emptiness of field
%
% Examples:
% isempty(O,'info')
% isempty(O,'info.date')

function re = isempty(O,field)

a = get(O,field);
if isempty(a)
    re = true;
else 
    re = false;
end