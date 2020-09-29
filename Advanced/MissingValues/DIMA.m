% DIMA: Data-driven recommendation of an imputation algorithm (Egert et al.)
%
% - Learn pattern of missing values
% - Define known data K as subset of original data
% - Generate patterns of missing values to K
% - Apply multiple imputation algorithms
% - Impute original data with best-performing imp. algorithm
%
% Example:
% O = OmicsData(file);
% O = OmicsPre(O);
% O = DIMA(O);

function [O,out] = DIMA(O,methods,npat,bio)

if ~exist('methods','var')
    methods = [];
end
if ~exist('bio','var')
    bio = [];
end
if ~exist('npat','var')
    npat = [];
end

%% DIMA
out = LearnPattern(O,bio);
%O = set(O,'out',out);
O2 = GetComplete(O);
O2 = AssignPattern(O2,out,npat);

O2 = impute(O2,methods);
saveO(O2,[],'O_imputations');

[~,algo] = GetTable(O2);
O = imputation_original(O,algo(1)); 
