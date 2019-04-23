%  O = add(O, prop, val, [type])
% 
%   Adding of data, rows, columns, or configs to @OmicsData object.
% 
%   prop    fieldname, property name
% 
%   val     data, row, column, config, ...
% 
%   type    If empty, the type is automatically determined based on the
%           dimensions of val and assigned to type data, row, or col.
%           'data'  Data matrix [nf x ns]
%           'row'   Row [1 x ns]
%           'col'   Column [nf x 1]

function O = add(O, prop, val, type)
if ~exist('type','var') || isempty(type)
    s1 = size(val,1);
    s2 = size(val,2);
    ns = get(O,'ns');
    nf = get(O,'nf');
    if s1==nf && s2==ns
        type = 'data';
    elseif s1==1 && s2==ns
        type = 'row';
    elseif s1==nf && s2==1
        type = 'col';
    else
        type = '';
    end
end

switch lower(type)
    case 'data'
        if size(val,2)==get(O,'ns') && size(val,1)==get(O,'nf')
            O.data.(prop) = val;
        else
            size(val)
            error('Format of argument ''val'' does not match.')
        end
        
    case 'row'
        if size(val,1)==1 && size(val,2)==get(O,'ns')
            O.rows.(prop) = val;
        else
            size(val)
            error('Format of argument ''val'' does not match.')
        end
    case {'col','column'}
        if size(val,2)==1 && size(val,1)==get(O,'nf')
            O.cols.(prop) = val;
        else
            size(val)
            error('Format of argument ''val'' does not match.')
        end
        
    case 'config'
        
    otherwise
        error('Type ''%s'' unknown.',type);
end

