% setConfig(O,varargin)
% 
%   This function can handle several pairs of property and value.
%   If directly sets config fields and can thereby introduce new config
%   fields.
% 
%   In contrast, the standard OmicsData/set.m function would put the
%   unknown property into the containter-struct O.container.
% 
%  Exampmle:
%  
function setConfig(O,varargin)

property_argin=varargin;
while length(property_argin) >=2
    prop = property_argin{1};    
    val  = property_argin{2};

    if ~OmicsCheckFieldname(prop)
        error('%s does not exist as poperty and is not a valid fieldname');
    end
    
    property_argin=property_argin(4:end);
    
    if isfield(O.config,prop)
        O.config.(prop) = val;
        
    else
        warning('Config %s does not yet exist, create new field O.config.%s',prop,prop);
        O.config.(prop) = val;
    end
end


