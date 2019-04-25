% y = mice(x,method)
%
%   This function generates a single realization of the mice imputation
%   algorithm.
% 
%   method  arguement specifying the mice impuation algorithm. The
%           following methods are available:
% 
%         pmm           any     Predictive mean matching
%         midastouch	any     Weighted predictive mean matching
%         sample        any     Random sample from observed values
%         cart          any     Classification and regression trees
%         rf            any     Random forest imputations
%         mean          numeric	Unconditional mean imputation
%         norm          numeric	Bayesian linear regression
%         norm.nob      numeric	Linear regression ignoring model error
%         norm.boot     numeric	Linear regression using bootstrap
%         norm.predict	numeric	Linear regression, predicted values
%         quadratic     numeric	Imputation of quadratic terms
%         ri            numeric	Random indicator for nonignorable data
%         logreg        binary	Logistic regression
%         logreg.boot	binary	Logistic regression with bootstrap
%         polr          ordered	Proportional odds model
%         polyreg       unordered	Polytomous logistic regression
%         lda           unordered	Linear discriminant analysis
%         2l.norm       numeric	Level-1 normal heteroscedastic
%         2l.lmer       numeric	Level-1 normal homoscedastic, lmer
%         2l.pan        numeric	Level-1 normal homoscedastic, pan
%         2l.bin        binary	Level-1 logistic, glmer
%         2lonly.mean	numeric	Level-2 class mean
%         2lonly.norm	numeric	Level-2 class normal
%         2lonly.pmm	any     Level-2 class predictive mean matching

function y = mice(x, method)
if ~exist('method','var') || isempty(method)
    method = 'pmm';
end

if min(sum(~isnan(x),2))==0
    find(sum(~isnan(x),2)==0)
    error('Some rows are only NaN. Removing might be an option.');
end

global OPENR

openR
OPENR.libraries{end+1} = 'mice';
putRdata('x',x);
evalR(['x2 <- as.matrix(complete(mice(x, m=1, method = "' method '")))']);
y = getRdata('x2');
closeR
