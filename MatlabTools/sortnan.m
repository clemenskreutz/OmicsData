function O = sortnan(O,dim,which)

% %   B = SORTNAN(A) sorts in ascending order.
%   The sorted output B has the same type and size as A:
%   - For vectors, SORTNAN(A) sorts the elements of A in ascending order.
%   - For matrices, SORTNAN(A) sorts each column of A in ascending order.
%   - For N-D arrays, SORTNAN(A) sorts along the first non-singleton dimension.
%
%   B = SORTNAN(A,DIM) also specifies a dimension DIM to sort along.
%
%   B = SORTNAN(A,DIM,WHICH) also specifies number of nans in dim, which
%   gives the sorting index.
%
% %   Examples:
% O = sortnan(O);
% O = sortnan(O,2);
% O = sortnan(O,2,ncol);

if nargin<1
    error('sortnan.m requires class O as input argument.')
end
if ~exist('dim','var') || isempty(dim)
    dim = 1;
end

% get data
dat = get(O,'data');
dat(dat==0) = nan;                              % Watch out! In most cases 0 = nan, if not 'Comment out (%)' this line
dat = double(isnan(dat));

if dim==1
    if exist('which','var') && ~isempty(which)
        dat(:,end+1) = which;
    else
        dat(:,end+1) = sum(dat,2);  
    end
    [~,idx] = sortrows(dat,size(dat,2));
    O = O(idx,:);    
    fprintf('sortnan.m: Rows are sorted by number of missing values.\n');
elseif dim ==2
    if exist('which','var') && ~isempty(which)
        dat(end+1,:) = which;
    else
        dat(end+1,:) = sum(dat);
    end
    [~,idx] = sortrows(dat',size(dat,1));
    O = O(:,idx);
    fprintf('sortnan.m: Columns are sorted by number of missing values.\n');
else
    error('sortnan.m: Function does not work if dim~=[1,2]')
end

 
