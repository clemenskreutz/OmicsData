% OmicsMice(O,[method],[seed])
%
%   This function generates a single realization of the mice imputation
%   algorithm.
% 
%   method  arguement specifying the mice impuation algorithm. 
%         Default:    
%         pmm           any     Predictive mean matching
%                   see mice.m for further details
% 
%       seed is set by default to a fixed number in order ensure
%            reproducility
% 
% See also mice

function O = OmicsMice(O,method,seed)
if ~exist('method','var') || isempty(method)
    method = 'pmm';
end
if ~exist('seed','var') || isempty(seed)
    seed = 12345;
end

if min(sum(~isnan(O),2))==0
    find(sum(~isnan(O),2)==0)
    error('Some rows are only NaN. Remove them e.g. by OmicsRemoveEmptyFeatures.m');
end

dat = mice(get(O,'data'),method,seed);
O = set(O,'data',dat,sprintf('MICE imputation using %s.',method));
