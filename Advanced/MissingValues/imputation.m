function [T,p] = imputation(clear)

if nargin < 2
    clear = false;
end
if clear
    imputation_clear;
end

%  impute('pcambda');
%  impute('pcambia');
%  impute('pcambkdr');
impute('pcambtsr');
impute('pcambnipals');
impute('previous');
%  impute('next');
impute('nearest');
impute('linear');
%  impute('spline');
%  impute('pchip');
impute('movmean');

[T,p] = imputation_analysis;    % Boxplot/Table/anova imputation comparison