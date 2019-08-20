function O = imputation(O,clean,ttest,indg1,indg2)

if ~exist('clean','var') || isempty(clean)
    clean = false;
end
if ~exist('ttest','var') || isempty(ttest)
    ttest=false;
end

if clean
    O = imputation_clear(O);  % clear previous imputations in O, optional
end

lib= 'mice';
methods = {'mean','norm','ri','pmm','sample','cart'};
O = impute_R(O,lib,methods);

lib= 'mice';
methods = {'midastouch','rf'};
O = impute_R(O,lib,methods);

lib= 'Amelia';
O = impute_R(O,lib,[]);

lib= 'Hmisc';
methods = {'regression'};
O = impute_R(O,lib,methods);

lib= 'pcaMethods';
methods = {'ppca','bpca','nipals','svd','svdImpute'};
O = impute_R(O,lib,methods);

lib= 'imputeLCMD';
methods = {'MinDet','KNN','MinProb','QRILC'};
O = impute_R(O,lib,methods);

lib= 'imputation';
methods = {'SVTImpute','SVDImpute','kNNImpute'};  %,'SVTApproxImpute','lmImpute'
O = impute_R(O,lib,methods);

lib= 'missForest';
O = impute_R(O,lib,[]);

lib= 'softImpute';
O = impute_R(O,lib,[]);

lib= 'VIM';
methods = {'irmi'}; %'kNN'
O = impute_R(O,lib,methods);

lib= 'rrcovNA';
methods = {'Norm','Seq','SeqRob'};
O = impute_R(O,lib,methods);

lib= 'missMDA';
methods = {'MIPCA','imputePCA'};
O = impute_R(O,lib,methods);

saveO(O);
if isfield(O,'data_imput') && ~isempty(get(O,'data_imput'))
    O = imputation_analysis(O);
    T = get(O,'Table');
    if ~all(isnan(T))
        if ttest
            O = RMSEttest(O,indg1,indg2);  
        end

        O = GetRankTable(O);
        saveO(O)
    else
        p = get(O,'path');
        delete([p(1:end-4) '.mat']);
        A = dir(p);
        for k = 1:length(A)
            delete([p filesep A(k).name])
        end
    end
else
    p = get(O,'path');
    delete([p(1:end-4) '.mat']);
    A = dir(p);
    for k = 1:length(A)
        delete([p filesep A(k).name])
    end
end

%Paper_plots(O);
