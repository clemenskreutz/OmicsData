% [p,dev,stats] = glmfit_indg(O,indg1,indg2,varargin)
% 
%   GLMFIT Fits a generalized linear model.
%   The function calls glmfit.m(X,dat(i,:)',varargin);
%   with X(indg1) = 1, X(indg2) = 0 and X(~indg1 && ~indg2) = nan
% 
%   glmfit_indg just works for one column in the design matrix
%   if you want to use more predictors, use glmfit(O,X,varargin)
%   is also programmed in @OmicsData
%
%   O       @OmicsData
% 
%   indg1   indices indication samples of group1
% 
%   indg2   indices indication samples of group2
% 
%   p       p-values (indicating significance of having different means)
% 
%   dev     returns the deviance of the fit.
% 
%   stats   more details statistics (see doc glmfit)
%               stats.p


function [b,dev,stats] = glmfit_indg(O,indg1,indg2,varargin)

if nargin<3
    error('OmicsData/glmfit_indg.m requires at least three arguments.')
end

if ~isempty(intersect(indg1,indg2))
    error('OmicsData/glmfit_indg.m: Both groups should not contain the same samples.')
end
if strcmp(varargin,'indg3')
    error('OmicsData/glmfit_indg.m: just works for one column in design matrix and just two groups.\n If you want to use more predictors, use glmfit(O,X,varargin) and create your own design matrix X.\n')
end

dat = get(O,'data');

mis = setdiff(1:max([indg1,indg2]),[indg1,indg2]);
if ~isempty(mis)
    dat(:,mis) = NaN;
    warning(['Column ' num2str(mis) ' is missing in group comparison, so it is filled with NaNs before logistic regression.\n']);
end    
    
X = nan(size(dat,2),1);
X(indg1) = 1;
X(indg2) = 0;

nf  = size(dat,1);  % number of features, e.g. number of proteins
b= NaN(nf,size(X,2));
dev = NaN(nf,1);

for i=1:size(dat,1)
    if isempty(varargin)
        [b(i,:),dev(i),stats(i)] = glmfit(X,dat(i,:)','binomial','link','logit','constant','off');
    else
        [b(i,:),dev(i),stats(i)] = glmfit(X,dat(i,:)',varargin);
    end
end
