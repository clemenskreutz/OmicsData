% val = isfield(O,fieldname)
%       
%   Check existence of field
%
% Examples:
% isfield(O,'info')
% isfield(O,'info.date')

function val = isfield(O,prop,silent)

prop = strsplit(prop,'.');
if ischar(prop)
    prop = {prop};
end
if ~exist('silent','var') || isempty(silent)
    silent = false;
end

if nargin==1
    error('OmicsData/isfield.m specify fieldname to be searched.') 
else
    val = false;
    fn = fieldnames(O);
    [~,ia] = intersect(fn,prop);
    if length(ia)==1
        if ~silent
            fprintf([ prop{:} ' is a fieldname in O.\n']);end
        val = true;
    elseif length(ia)>1
        error('This case should not occur')
    else
        for f=1:length(fn)
            if isstruct(O.(fn{f}))
                fn2 = fieldnames(O.(fn{f}));
                [~,ia] = intersect(fn2,prop);
                if length(ia)==1
                    if ~silent
                        fprintf([prop{:} ' is field in O.' fn{f} '\n']);
                    end
                    val = true;
                    break
                end
            end
        end
    end
end
