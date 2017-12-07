% val = getfield(O,fieldname)
%       
%   This function also allows recursive fieldnames.
% 
%   It should be used if get.m is not applicable because a property has a
%   special meaning, e.g. if O.data should be accessed which is not
%   feasible because property 'data' has a special meaning.
% 
%   Usage of get.m is strongly preferred, since usage of getfields is more
%   sensitive to changes of the class struct than usage of get.
%   
% Examples:
% getfield(O,'info')
% getfield(O,'info.date')

function val = getfield(O,fn)

fn = strsplit(fn,'.');
if ischar(fn)
    fn = {fn};
end
val = getfield(struct(O),fn{:});

