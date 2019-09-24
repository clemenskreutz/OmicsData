function lib = GetLib(algo)
if strcmp(algo,'midastouch') || strcmp(algo,'rf') || strcmp(algo,'mean') || strcmp(algo,'norm') || strcmp(algo,'ri') || strcmp(algo,'pmm') || strcmp(algo,'sample') || strcmp(algo,'cart')
    lib= 'mice';
end
if strcmp(algo,'knn') || strcmp(algo,'impute.knn')
    lib= 'impute';
end
if strcmp(algo,'impnorm') || strcmp(algo,'imp.norm')
    lib= 'norm';
end
if strcmp(algo,'Amelia')
    lib = 'Amelia';
end
if strcmp(algo,'regression') || strcmp(algo,'aregImpute')
    lib= 'Hmisc';
end
if strcmp(algo,'ppca') || strcmp(algo,'bpca') || strcmp(algo,'nipals') || strcmp(algo,'nlpca') || strcmp(algo,'svd') || strcmp(algo,'svdImpute')
    lib= 'pcaMethods';
end
if strcmp(algo,'MinDet') || strcmp(algo,'KNN') || strcmp(algo,'MinProb') || strcmp(algo,'QRILC')
    lib= 'imputeLCMD';
end
if strcmp(algo,'SVTApproxImpute') || strcmp(algo,'SVTImpute') || strcmp(algo,'SVDImpute') || strcmp(algo,'kNNImpute') || strcmp(algo,'lmImpute')
    lib= 'imputation';
    %path = 'C://Users/Janine/Documents/Repositories/imputation';
end
if strcmp(algo,'missForest')
    lib= 'missForest';
end
if strcmp(algo,'softImpute')
    lib= 'softImpute';
end
if strcmp(algo,'irmi')
    lib= 'VIM';
end
if strcmp(algo,'Norm') || strcmp(algo,'Seq') || strcmp(algo,'SeqRob') || strcmp(algo,'impNorm') || strcmp(algo,'impSeq') || strcmp(algo,'impSeqRob')
    lib= 'rrcovNA';
end
if strcmp(algo,'MIPCA') || strcmp(algo,'imputePCA')
    lib= 'missMDA';
end
if strcmp(algo,'mi')
    lib= 'mi';
end
if strcmp(algo,'knnImputation')
    lib= 'DMwR';
end