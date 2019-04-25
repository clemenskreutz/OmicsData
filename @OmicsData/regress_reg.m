% p = regress_reg(O,X,varprior,priorw)
% 
%   X       design matrix [nsamples x nEffects]
% 
%   Regression function for design matrix X applied to each row (feature)
%   of the data.
%   Features with too many NaNs are not analyzed (result=NaN).
%
%   Attention:
%   The analysis is always performed with an intercept term.
%   If the intercept columns is missing, it is added.
% 
%   varprior    [1 x 1] or [nfeature x 1]
%               vector of variance priors
% 
%   priorw      [1 x 1] or [nfeature x 1]
%               weights for averaging beteen observed variance and
%               variance prior.
%               priorweight=0 coincides with unregularized regression

function [p,t,fold,varest] = regress_reg(O,X,varprior,priorw)
% varprior = median(varprior);
if ~exist('priorw','var') || isempty(priorw)
    priorw = 0;
    if ~exist('varprior','var') || isempty(varprior)
        varprior = 0; % in this case, the varprior does not matter
    end    
elseif sum(priorw<0)>0 || sum(priorw>1)>0
    error('Only weights between 0 and 1 are meaningful.')
end
    
if ~exist('priorw','var') || isempty(priorw)
    error('For regularized regression (weight>0), a variance prior has to be specified.')
elseif length(varprior)==1
    varprior = ones(get(O,'ngene'),1)*varprior;
end

if length(priorw)==1
    priorw = ones(get(O,'ngene'),1)*priorw;
end

y = get(O,'data');

if(sum(sum(abs(X),1)==size(X,1))==0)
    disp('regress.m: Intercept is added.');
    interAdded = 1;
    XwInter = [ones(size(X,1),1),X]; % 1st column Intercept hinzufuegen
else
    XwInter = X;
    interAdded = 0;
end

try
    [fold,bSE,p,dummy,t,varest] = regress_reg(y',XwInter,varprior,priorw);
    
catch ERR
    save error
    rethrow(ERR)
end
if interAdded==1
    varest = varest';
    p = p(2:end,:)';
    t = t(2:end,:)';
    fold = fold(2:end,:)';
else
    p = p';
    t = t';
    fold = fold';
    varest = varest';
end


