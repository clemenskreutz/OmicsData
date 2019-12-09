% set(O, property, value)
% set(O, property, value, argument)
% set(O, property1, value1, property2, value2, ...)
%
%

function O = set(O,prop, val, varargin)

if ~OmicsCheckFieldname(prop)
    error('%s does not exist as poperty and is not a valid fieldname');
end

fn = fieldnames(O);
fnconfig = fieldnames(O.config);
fncontainer = fieldnames(O.container);
fninfo = fieldnames(O.info);

switch prop
    case 'data'
        if isempty(varargin)
            error('Data can only be altered, if the change is annotated via a 3rd argument of this function (Example: set(O,''data'',d,''Data is divided by two.'').')
        end
        O.data.(O.config.default_data) = val;
        O = OmicsAddAnalysis(O,varargin{1});  % 3rd argument has
        O = OmicsNewID(O);
        
        case {'samplenames','snames','hy'}  % hy is accepted because of historic reasons
            if size(val,2)==get(O,'ns') && size(val,1)==1
                O.rows.(O.config.default_row) = val;
            else
                error('Dimension of val does not fit to the data.')
            end
            
        case {'featurenames','fnames'}
            if size(val,1)==get(O,'nf') && size(val,2)==1
                O.cols.(O.config.default_col) = val;
            else
                error('Dimension of val does not fit to the data.')
            end
    
    case fn  % if it match to an existing field in O
        O.(prop) = val;
    case fnconfig  % if it match to an existing field in O.config
        O.config.(prop) = val;
    case fncontainer  % if it match to an existing field in O.container
        O.container.(prop) = val;
    case fninfo  % if it match to an existing field in O.info
        O.info.(prop) = val;
        
    case 'ids'
        if size(val,1)==size(O,1) && size(val,2)==1
            O.cols.IDs = val;
        else
            error('size(val) does not fit.');
        end
        
    otherwise
        dims = size(val);
        nf = get(O,'nfeatures');
        ns = get(O,'nsamples');
        
        if isempty(get(O,prop,true))
            if isnumeric(val) && dims(1)==nf && dims(2)==ns
                O.data.(prop) = val;
            elseif dims(1)==nf && dims(2)==1
                O.cols.(prop) = val;
            elseif dims(1)==1 && dims(2)==ns
                O.rows.(prop) = val;
            else
                O.container.(prop) = val;  % unknown properties are put in the container
            end
        else
            [~,s] = get(O,prop,true);
            O.(s).(prop) = val;
        end
end
