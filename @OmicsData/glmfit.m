% [b,dev,stats] = glmfit(O,X,varargin)
% 
%   GLMFIT Fit a generalized linear model.
%   The function calls glmfit.m(X,dat(i,:)',varargin);
% 
%   O       @OmicsData
% 
%   X       Design matrix
% 
%   p       p-values (indicating significance of having different means)
% 
%   dev     returns the deviance of the fit.
% 
%   stats   more details statistics (see doc glmfit)
%               stats.p

function [b,dev,stats] = glmfit(O,X,varargin)
if nargin<2
    error('OmicsData/glmfit.m requires at least two arguments. glmfit(O,X,varargin).')
end

% Set predictor
dat = get(O,'data');

if all(all(all(isnan(dat))))==0
    dat(dat==0) = nan;  % if missing values are not NaN but 0 in data matrix
    dat = isnan(dat);
else
    dat = isnan(dat); 
end

% Check design matrix
if size(X,1)~=size(dat,2)
    if size(X,2)==size(dat,2)
        X = X';
    else
        error('OmicsData/glmfit.m: Length of design matrix has to be the same size as data matrix. If a column should not be compared, fill in NaNs in design matrix.');
    end
end
if size(X,2) <=1
    X(:,2) = X(:,1);
    X(:,1) = ones(size(X,1),1);
end

% Set output variables nan
nf  = size(dat,1);  % number of features, e.g. number of proteins
b = NaN(nf,size(X,2));
dev = NaN(nf,1);

% GlmFit
for i=1:size(dat,1)
    if isempty(varargin)
        [b(i,:),dev(i),stats(i)] = glmfit(X,dat(i,:)','binomial','link','logit','constant','off');
    else
        [b(i,:),dev(i),stats(i)] = glmfit(X,dat(i,:)',varargin);
    end
end
