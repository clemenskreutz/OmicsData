% OmicsMice(O,[method])
%
%   This function generates a single realization of the mice imputation
%   algorithm.
% 
%   method  arguement specifying the mice impuation algorithm. 
%         Default:    
%         pmm           any     Predictive mean matching
%                   see mice.m for further details
% 
% See also mice

function O = OmicsMice(O,method)
if ~exist('method','var') || isempty(method)
    method = 'pmm';
end

if min(sum(~isnan(O),2))==0
    find(sum(~isnan(O),2)==0)
    error('Some rows are only NaN. Remove them e.g. by OmicsRemoveEmptyFeatures.m');
end

dat = mice(get(O,'data'),method);
O = set(O,'data',dat,sprintf('MICE imputation using %s.',method));
