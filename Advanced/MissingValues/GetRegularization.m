% GetRegularization(X,m,y)
%
% Expand the design matrix X so each predictor has at least one positive
% entry, this exhibits the regression coefficients to get infinite
%
% X - Design matrix
% m - First column of design matrix if you wish to differ (for DIMA: mean protein intensity)
% y - response vector
%
% Example:
% dat = get(O,'data');
% isna = isnan(O);
% m = nanmean(O,2);
% X = GetDesign(isna,m);
% X = GetRegularization(X);
%
% Example 2:
% [X,y,type,typenames] = GetDesign(isna,m);
% [X,y] = GetRegularization(X,m,y);


function [X,y] = GetRegularization(X,y)

%% regularization: add a 0 and a 1 for each parameter (-> regularization towards estimate 0 == probability 0.5)
ind = 1;
yreg = zeros(2*(size(X,2)-1),1);
xreg = zeros(2*(size(X,2)-1),size(X,2));

nrowcol = size(X,1)/sum(X(:,end))+sum(X(:,end));
idx = size(X,2)-nrowcol+1 : size(X,2);
for i=1:size(X,2)-nrowcol % row/col anyway
    N = histcounts(X(:,i),20);
    if any(N>size(X,1)/2)
        idx = [idx i];
    end
end
idx2 = setdiff(1:size(X,2),idx);
for i=1:length(idx2)
    xreg(:,idx2(i)) = nanmedian(X(:,idx2(i)))*ones(size(xreg,1),1);  % for regularization set first column to median(intensity)
end
for i=1:length(idx)
    j = idx(i);
    xreg(ind:(ind+1),j) = 1;
    yreg(ind+1) = 1;
    ind = ind+2;
end
X = [X;xreg];

if exist('y','var') && ~isempty(y)
    y = [y;yreg];
else
    y = [];
end