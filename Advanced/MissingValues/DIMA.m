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

function [O,out] = DIMA(O,methods,bio)

out = LearnPattern(O,bio);
Os = GetComplete(O);
Os = AssignPattern(Os,out);

Os = impute(Os,methods);
[~,algo] = GetRankTable(Os);

O = imputation_original(O,algo); 
