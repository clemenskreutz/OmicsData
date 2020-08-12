%   O = horzcat(O,O2)
% 
%   O = horzcat(O,O2,O3, ...)
%   O = horzcat(O,O2,O3, ..., 'force')
%
%   Horizontal catenation, i.e. lumping column-wise.
% 
%   The order of the rows is adjusted to each other and is compared using
%   OmicsData.config.default_col (e.g. by comparing feature names)
% 
%   The order of the first argument is maintained.
%
% Example:
% [O,O2]
%

function O = horzcat(O,varargin)

anastr = sprintf('@OmicsData horzcat: [%ix%i',get(O,'nf'),get(O,'ns'));

c1 = O.cols.(O.config.default_col);
if length(unique(c1)) < length(c1)
    error('Default-rowumn of O is not unique and cannot be used for horzcat. Generate a unique default-row first.')
end

doforce = 0;

Os = cell(0);
for v=1:length(varargin)
    arg = varargin{v};
    
    if isa(arg,'OmicsData')
        Os{end+1} = arg;
    elseif ischar(arg)
        switch(arg)
            case 'force'
                doforce = 1;
            otherwise 
                error('Option/flag %s unknown.',arg);
        end
    else
        v,arg
        error('Only objects of type @OmicsData can be catenated.')
    end
end

for v=1:length(Os)
    O2 = Os{v};
    
    fn1 = fieldnames(O.data);
    fn2 = fieldnames(O2.data);
    fn = intersect(fn1,fn2);
    if max(length(fn1),length(fn2)) < length(fn)
        warning('Some data fields only occur in a subset of objects. Only common fields are maintained.');
    end    
    
    if doforce==0
        c2 = O2.cols.(O2.config.default_col);
        if length(unique(c2)) < length(c2)
            error('Default-columns of O%i is not unique and cannot be used for horzcat. Generate a unique default-column first.',v)
        end
        
        [inb,locb] = ismember(c1,c2);
        if sum(inb==0)>0
            error('Some default-rows do not occur in all objects.')
        else
            % reorder 2nd object
            S.type = '()';
            S.subs = {locb,':'};
            O2 = subsref(O2,S);
            %         O2 = O2(locb,:); % does not work, why?
        end
    end
    
    for i=1:length(fn)
        O.data.(fn{i}) = horzcat(O.data.(fn{i}),O2.data.(fn{i}));
    end
    
    fn1 = fieldnames(O.rows);
    fn2 = fieldnames(O2.rows);
    fn = intersect(fn1,fn2);
    if max(length(fn1),length(fn2)) < length(fn)
        warning('Some rows fields only occur in a subset of objects. Only common fields are maintained.');
    end    
    
    for i=1:length(fn)
        O.rows.(fn{i}) = horzcat(O.rows.(fn{i}),O2.rows.(fn{i}));
    end
    
    anastr = sprintf('%s, %ix%i',anastr,get(O2,'nf'),get(O2,'ns'));
end

anastr = sprintf('%s ] = %ix%i',anastr,get(O,'nf'),get(O,'ns'));

O = OmicsAddAnalysis(O,anastr);




