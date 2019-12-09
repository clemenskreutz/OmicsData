%   varargout = get(O,prop)
%
%   This function has to be used if data properties are requested.
%
% Examples:
% dat           = get(O,'data')
% nsamples      = get(O,'ns')
% nfeatures     = get(O,'nf')
% get(O)            show fieldnames
% get(O,'mean')     mean over samples
% get(O,'median')   median over samples
% get(O,'sd')       SD over samples
% get(O,'nna')      Number of NaN for each feature, summed over the samples
% get(O,'propna')   Proportion of NaN for each feature, summed over the samples

function [varargout, structfield] = get(O,prop,silent)

if ~exist('silent','var') || isempty(silent)
    silent = false;
end

if nargin==1
    fn = fieldnames(O);
    for f=1:length(fn)
        fprintf('O.%s\n',fn{f});
        if isstruct(O.(fn{f}))
            fn2 = fieldnames(O.(fn{f}));
            for f2=1:length(fn2)
                fprintf('O.%s.%s\n',fn{f},fn2{f2});
            end
        end
    end
    
else
    switch lower(prop)  % misspecification of upper/lower cases is allowed in get (but not in set)
        case {'nna','nnan'}
            varargout = sum(isnan(get(O,'data')),2);
        case {'propna','propnan','freqna','freqnan','antna'}
            varargout = sum(isnan(get(O,'data')),2)/size(get(O,'data'),2);
            
        case 'data'
            try
                varargout = O.data.(O.config.default_data);
            catch ERR
                warning('Default data field specified by O.config.default_data does not exist in O.data. May be the respecitive columns are differently named in the raw data file.')
                rethrow(ERR)
            end
        case 'name'
            varargout = O.name;
            
        case {'samplenames','snames','hy'}  % hy is accepted because of historic reasons
            try
                varargout = O.rows.(O.config.default_row);
            catch ERR
                warning('Default row specified by O.config.default_row does not exist in O.rows. Did you change this property?')
                rethrow(ERR)
            end
            
        case 'ids'
            if isfield(O.cols,'IDs')
                varargout = O.cols.IDs;
            else
                varargout = get(O,'MajorityproteinIDs');
            end
            
        case {'featurenames','fnames'}
            try
                varargout = O.cols.(O.config.default_col);
            catch ERR
                warning('Default toe specified by O.config.default_col does not exist in O.cols. Did you change this property?')
                rethrow(ERR)
            end
            
        case {'nf','nfeatures','nprot','ngene','ngenes'}
            varargout = size(get(O,'data'),1);
        case {'n','ndata'} 
            varargout = prod(size(get(O,'data'),1)); % the result of numel is wrong for empty data
        case {'ns','nsamples','na','narrays'}
            varargout = size(get(O,'data'),2);
            
        otherwise  % search field recursively
            
            fn = fieldnames(O);
            [~,ia] = intersect(fn,prop);
            if length(ia)==1
                varargout = O.(prop);
            elseif length(ia)>1
                error('This case should not occur')
            else
                found = 0;
                for f=1:length(fn)
                    if isstruct(O.(fn{f}))
                        fn2 = fieldnames(O.(fn{f}));
                        [~,ia] = intersect(fn2,prop);
                        if length(ia)==1
                            varargout = O.(fn{f}).(prop);
                            structfield = fn{f};
                            found = 1;
                            break
                        end
                    end
                end
                if found==0
                    if ~silent
                        warning('Property ''%s'' not found in the @OmicsData object.',prop);
                    end
                    varargout = [];
                end
            end
    end
    
end
    
    
