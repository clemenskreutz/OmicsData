% O = OmicsAddSamplenames(O,option,[newname],[asDefault])
% 
%   This function sets new samplenames.
% 
%   option  Either a cell of new sample names 
%               OR 
%           the type of change, e.g.
%           'na'    The fraction of missing values is added
% 
%   newname     the new colname (used as fieldname)
%               Default: 
%               [get(O,'default_row'),'_user']  OR
%               [get(O,'default_row'),'_NA'] 
% 
%   asDefault   [true]
%               Flag indicating whether the new samplenames should be set
%               as default samplenames.



function O = OmicsAddSamplenames(O,option,newname,asDefault)
if ~exist('option','var') || isempty(option)
    option = '';
end
if ~exist('asDefault','var') || isempty(asDefault)
    asDefault = 1;
end
if ~exist('newname','var') || isempty(newname)
    newname = '';
end

if iscell(option)  % the additional samplenames are provided as a cell of strings
    if size(option,2)==get(O,'ns') && size(option,1)==1
        new = option;
    else
        error('The number of new samplenames does not coindice with #samples');
    end
    if isempty(newname)
        newname = [get(O,'default_row'),'_user'];
    end
    
elseif ischar(option) % a string indicating an option
    switch lower(option)
        case {'na','nan'}
            new = get(O,'snames');
            antna = sum(isnan(O),1)/get(O,'nf');
            for i=1:length(new)
                new{i} = [new{i},' ',sprintf('%.0f%s NA',100*antna(i)),'%'];
            end
            if isempty(newname)
                newname = [get(O,'default_row'),'_NA'];
            end
        otherwise
            error('option "%s" not implemented',option)
            
    end
end

O = add(O, newname, new, 'row');

if asDefault
    O.config.default_row = newname;
end
