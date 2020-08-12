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

function [O,out] = DIMA(O,compcut,regw,logflag,methods,npat,bio)

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
out = LearnPattern(O,bio,regw,logflag);
O = GetComplete(O,compcut);
O = AssignPattern(O,out,npat,logflag);

O = set(O,'out',out);

%Os = impute(Os,methods);
%[~,algo] = GetRankTable(Os);
%saveO(Os,[],'O_imputations');

%O = imputation_original(O,algo); 
