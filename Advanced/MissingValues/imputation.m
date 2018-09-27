function imputation
imputation_clear

lib= 'pcaMethods';
methods = {'ppca','nipals','bpca','svd','svdImpute'};
impute_R(lib,methods);

lib= 'imputeLCMD';
methods = {'MinDet','MinProb','QRILC','KNN'};
impute_R(lib,methods);

lib= 'jeffwong';
path = 'C://Users/Janine/Documents/Repositories/imputation';
methods = {'SVDImpute','SVTImpute','SVTApproxImpute','kNNImpute','lmImpute'};  
impute_R(lib,methods,path);

lib= 'Hmisc';
methods = {'pmm','regression'};
impute_R(lib,methods);

lib= 'mice';
methods = {'pmm','midastouch','sample','cart','rf','mean','norm','ri'};
impute_R(lib,methods)

lib= 'Amelia';
impute_R(lib);

lib= 'missForest';
impute_R(lib);

imputation_analysis;