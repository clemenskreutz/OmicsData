
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

til = size(X,2)-sum(X(:,end)==1)-size(X,1)/sum(X(:,end)==1);  % predictors which are no ID
xreg(:,1:til) = nanmedian(X(:,1:til)).*ones(size(xreg,1),1);  % set column to median

for i=til+1:size(X,2)
    xreg(ind:(ind+1),i) = 1;
    yreg(ind+1) = 1;
    ind = ind+2;
end
X = [X;xreg];

if exist('y','var') && ~isempty(y)
    y = [y;yreg];
else
    y = [];
end