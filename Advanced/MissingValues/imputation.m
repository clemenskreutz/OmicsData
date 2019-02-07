function imputation(clean)

global O

if ~exist('clean','var') || clean
    imputation_clear  % clear previous imputations in O, optional
end

lib= 'mice';
methods = {'mean','norm','ri','pmm','sample','cart'};
impute_R(lib,methods)

lib= 'mice';
methods = {'midastouch','rf'};
impute_R(lib,methods)

lib= 'Amelia';
impute_R(lib,[],[]);

lib= 'Hmisc';
methods = {'regression'};
impute_R(lib,methods);

lib= 'pcaMethods';
methods = {'ppca','bpca','nipals','svd','svdImpute'};
impute_R(lib,methods);

lib= 'imputeLCMD';
methods = {'MinDet','KNN','MinProb','QRILC'};
impute_R(lib,methods);

lib= 'imputation';
methods = {'SVTImpute','SVDImpute','kNNImpute'};  %,'SVTApproxImpute','lmImpute'
impute_R(lib,methods);

lib= 'missForest';
impute_R(lib,[]);

lib= 'softImpute';
impute_R(lib,[]);

lib= 'VIM';
methods = {'irmi'}; %'kNN'
impute_R(lib,methods);

lib= 'rrcovNA';
methods = {'Norm','Seq','SeqRob'};
impute_R(lib,methods);

lib= 'missMDA';
methods = {'MIPCA','imputePCA'};
impute_R(lib,methods);

imputation_analysis;
saveO
%Paper_plots;
