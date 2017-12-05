%   O = vertcat(O,O2)
%
%   Vertical catenation, i.e. lumping row-wise.
%   The order of the columns is adjusted and is compared using
%   OmicsData.config.default_row (e.g. by comparing sample names)
% 
%   The order of the first argument is maintained.
%
% Example:
% [O;O2]
%

function O = vertcat(O,varargin)

anastr = sprintf('@OmicsData vertcat: [%ix%i',get(O,'nf'),get(O,'ns'));

r1 = O.rows.(O.config.default_row);
if length(unique(r1)) < length(r1)
    error('Default-row of O is not unique and cannot be used for horzcat. Generate a unique default-row first.')
end

for v=1:length(varargin)
    O2 = varargin{v};
    
    if strcmp(class(O2),'OmicsData')~=1
        v
        error('Only objects of type @OmicsData can be catenated.')
    end
    
    fn1 = fieldnames(O.data);
    fn2 = fieldnames(O2.data);
    fn = intersect(fn1,fn2);
    if max(length(fn1),length(fn2)) < length(fn)
        warning('Some data fields only occur in a subset of objects. Only common fields are maintained.');
    end    
    
    r2 = O2.rows.(O2.config.default_row);
    if length(unique(r2)) < length(r2)
        error('Default-rows of O%i is not unique and cannot be used for horzcat. Generate a unique default-row first.',v)
    end
    
    [inb,locb] = ismember(r1,r2);
    if sum(inb==0)>0
        error('Some default-rows does not occur in all objects.')
    else
        % reorder 2nd object
        S.type = '()';
        S.subs = {':',locb};
        O2 = subsref(O2,S)
%         O2 = O2(locb,:); % does not work, why?
    end
    
    for i=1:length(fn)
        O.data.(fn{i}) = vertcat(O.data.(fn{i}),O2.data.(fn{i}));
    end
    
    fn1 = fieldnames(O.cols);
    fn2 = fieldnames(O2.cols);
    fn = intersect(fn1,fn2);
    if max(length(fn1),length(fn2)) < length(fn)
        warning('Some cols fields only occur in a subset of objects. Only common fields are maintained.');
    end    
    
    for i=1:length(fn)
        O.cols.(fn{i}) = vertcat(O.cols.(fn{i}),O2.cols.(fn{i}));
    end
    
    anastr = sprintf('%s; %ix%i',anastr,get(O2,'nf'),get(O2,'ns'));
end

anastr = sprintf('%s ] = %ix%i',anastr,get(O,'nf'),get(O,'ns'));

O = OmicsAddAnalysis(O,anastr);




