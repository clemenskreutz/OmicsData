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

function [b,dev,stats,p] = glmfit_janine(O,varargin)
if nargin<1
    error('OmicsData/glmfit.m requires at least one arguments. glmfit_janine(O,varargin).')
end

% Set predictor
[X,dat] = ReducebyName(O,1);    % Check for equal strings in SampleNames
if isempty(X) && isempty(dat)
    dat = get(O,'data');
    X = get(O,'X');
end

if all(all(all(isnan(dat))))==0
    dat(dat==0) = nan;  % if missing values are not NaN but 0 in data matrix
    dat = isnan(dat);
else
    dat = isnan(dat); 
end

% SORT! Just for looking at the p-values. In the end delete these lines.
dat = horzcat(dat,sum(dat,2));
dat = sortrows(dat,size(dat,2));
A = dat(:,end);
dat = dat(:,1:end-1);

% Check design matrix
if size(X,1)~=size(dat,1)
    if size(X,2)==size(dat,1)
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
p = NaN(nf,size(X,2));
dev = NaN(nf,1);

% GlmFit
for i=1:size(dat,2)
    if isempty(varargin)
        [b(i,:),dev(i),stats(i)] = glmfit(X,dat(:,i),'binomial','link','logit','constant','off');
    else
        [b(i,:),dev(i),stats(i)] = glmfit(X,dat(:,i),varargin);
    end
    p(i,:) = stats(i).p;
    % if perfectly separated
    % if warning message ? Existiert sowas ? 
    if all( round(p(i,:),5) == 1 ) && all(all( round( abs( stats(i).coeffcorr ) ,5) ==1 ))
        p(i,:) = nan;
        [B, FitInfo] = lassoglm(X,dat(:,i),'binomial');
        warning('The estimated coefficients perfectly separate failures from successes. Using lassoglm instead of glmfit.');
        % p = B/SE; SE nicht gegeben. Hier noch was einfallen lassen!
    end
end
