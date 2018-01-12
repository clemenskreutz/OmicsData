% setConfig(O,varargin)
% 
%   This function can handle several pairs of property and value.
%   If directly sets config fields and can thereby introduce new config
%   fields.
% 
%   In contrast, the standard OmicsData/set.m function would put the
%   unknown property into the containter-struct O.container.
% 
%  Example:
%   O = setConfig(O,'default_data','evi')
function O = setConfig(O,varargin)

property_argin=varargin;
while length(property_argin) >=2
    prop = property_argin{1};    
    val  = property_argin{2};

    if ~OmicsCheckFieldname(prop)
        error('%s does not exist as poperty and is not a valid fieldname');
    end
    
    property_argin=property_argin(4:end);
    
    if isfield(O.config,prop)
        if isnumeric(val)
            valstr = num2str(val);
            valstr0 = num2str(O.config.(prop));
        elseif ischar(val)
            valstr = val;
            valstr0 = O.config.(prop);
        else
            val = 'new value (class ~isnumeric & ~ischar)';
            val0 = 'previous value ';
        end
        
        if compare(O.config.(prop),val)~=1
            O = OmicsAddAnalysis(O,sprintf('config.%s set from ''%s'' to ''%s''.',prop,valstr0,valstr));
        end
        O.config.(prop) = val;
    else
        warning('Config %s does not yet exist, create new field O.config.%s',prop,prop);
        O.config.(prop) = val;
    end
end


