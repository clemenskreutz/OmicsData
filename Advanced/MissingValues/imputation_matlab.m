function [T,p] = imputation_mat(clear)

if nargin < 2
    clear = false;
end
if clear
    imputation_clear;
end

impute('pcakdr');
impute('pcatsr');

%impute('pchip');
impute('nearest');
impute('spline');

%impute('previous');   % first 3 rows still contain nans after matlabimputation 
%impute('next');       % first 3 rows still contain nans after matlabimputation 
%impute('linear');
%impute('movmean');
%impute('pcada');
%impute('pcaia');
%impute('pcanipals');

[T,p] = imputation_analysis;    % Boxplot/Table/anova imputation comparison
