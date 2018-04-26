function imputation_clear

global O

if ~exist('O','var')
    error('MissingValues/imputation_clear.m requires class O as global variable.')
end

Y = [];
method = {};
dataset = {};
O = set(O,'data_imput',Y);
O = set(O,'method_imput',method);
O = set(O,'dataset',dataset);