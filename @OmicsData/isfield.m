% val = isfield(O,fieldname)
%       
%   Check existence of field
%
% Examples:
% isfield(O,'info')
% isfield(O,'info.date')

function val = isfield(O,prop)

prop = strsplit(prop,'.');
if ischar(prop)
    prop = {prop};
end

if nargin==1
    error('OmicsData/isfield.m specify fieldname to be searched.') 
else
    val = false;
    fn = fieldnames(O);
    [~,ia] = intersect(fn,prop);
    if length(ia)==1
        fprintf([ prop{:} ' is a fieldname in O.\n']);
        val = true;
    elseif length(ia)>1
        error('This case should not occur')
    else
        for f=1:length(fn)
            if isstruct(O.(fn{f}))
                fn2 = fieldnames(O.(fn{f}));
                [~,ia] = intersect(fn2,prop);
                if length(ia)==1
                    fprintf([prop{:} ' is field in O.' fn{f} '\n']);
                    val = true;
                    break
                end
            end
        end
    end
end
