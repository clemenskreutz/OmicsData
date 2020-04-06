function WriteinR(lib,method,nsamples)

if iscell(method)
    method = method{:};
end

% pcaMethods
if strcmp(lib,'pcaMethods')
    evalR('dat[is.na(dat)] <- NA') 
    evalR('if (sum(rowSums(is.na(dat))>=ncol(dat))>0) { ImpR <- {} } else {')
    if strcmp(method,'nlpca')
        evalR(['I <- pca(t(dat),method="' method '",maxSteps=max(dim(dat)))']) % transpose
        evalR('ImpR <- t(completeObs(I)) }') 
    else
        evalR(['I <- pca(dat,method="' method '")'])
        evalR('ImpR <- completeObs(I) }')  
    end       

% knn
elseif strcmp(lib,'impute')
    evalR(' I <- impute.knn(as.matrix(dat))')
    evalR(' ImpR <- I$data')

% norm
elseif strcmp(lib,'norm')
    evalR(' s <- prelim.norm(dat)')
    evalR(' thetahat <- em.norm(s)')
    evalR('  rngseed(1)')
    evalR(' ImpR <- imp.norm(s,thetahat,dat)')
    %evalR(' ImpR <- t(ImpR)')

% missMDA
elseif strcmp(lib,'missMDA')
    evalR('dat <- data.frame(dat)') 
    if strcmp(method,'MIPCA')
        evalR(['imp <- ' method '(dat,nboot=1)']) 
        evalR('ImpR <- imp$res.imputePCA')
    else
        evalR(['imp <- ' method '(dat)']) 
        evalR('ImpR <- imp$completeObs')
    end              

% rrcovNA
elseif strcmp(lib,'rrcovNA')
    if contains(method,'imp')
        evalR(['ImpR <- ' method '(dat)'])
    else
        evalR(['ImpR <- imp' method '(dat)'])
    end
    if contains(method,'SeqRob')
        evalR('ImpR <- ImpR$x')
    end

% VIM
elseif strcmp(lib,'VIM')
    evalR('dat<-as.matrix(dat)')
    evalR(['ImpR <- ' method '(dat)'])

% softImpute
elseif strcmp(lib,'softImpute')
    evalR('dat <- as.matrix(dat)') 
    evalR('f <- softImpute(dat)')
    evalR('ImpR <- complete(dat,f)')

% LCMD
elseif strcmp(lib,'imputeLCMD')   
    evalR('dat <- data.matrix(dat)')
    if strcmp(method,'QRILC')
        evalR('ImpR <- impute.QRILC(dat)[[1]]')
    else
        evalR(['ImpR <- impute.' method '(dat)'])
    end

% jeffwong
elseif strcmp(lib,'imputation')               
    if contains(method,'SVD')
        evalR(['ImpR <- ' method '(dat, k=3)$x'])
    elseif contains(method,'kNN')
        evalR(['ImpR <- ' method '(dat, k=3)$x'])
    elseif contains(method,'SVT')
        evalR(['ImpR <- ' method '(dat,lambda=3)$x'])
    else
        evalR(['I <- ' method '(dat)'])
        evalR('ImpR <- I$x')
    end   

% MICE
elseif strcmp(lib,'mice')                
    evalR(['I <- mice(dat, m=1, method = "' method '")'])
    evalR('ImpR <- complete(I)')
    % if too many missing values, not all are capture due to multicollinearity, run a second time then
    %evalR(['if (sum(is.na(ImpR))>0) { I' num2str(i) ' <- mice(ImpR, m=1, method = "' method '")']);
    %evalR(['ImpR <- complete(I' num2str(i) ')}']);
    % if it still has missing values, ignore this method
%    evalR('if (sum(is.na(ImpR))>0) { ImpR <- {} }')

% Amelia (Expectation maximization with bootstrap)
elseif strcmp(lib,'Amelia')
    evalR('f <- amelia(dat, m=1)')
    evalR('ImpR <- f$imputations[[1]]')
 %s   evalR('if (sum(is.na(ImpR))>0) { ImpR <- {} }')

% missForest
elseif strcmp(lib,'missForest')
    evalR('f <- missForest(dat)')
    evalR('ImpR <- f$ximp')

% Hmisc
elseif strcmp(lib,'Hmisc')
    if exist('nsamples','var') && ~isempty(nsamples)
        evalR('dat <- data.frame(dat)')
        formula = '~ X1';
        for j=2:nsamples
            formula = [formula ' + X' num2str(j)];
        end
        if strcmp(method,'aregImpute')
            evalR(['f <- aregImpute(' formula ', data=dat, n.impute=1, type="pmm")'])
        else
            evalR(['f <- aregImpute(' formula ', data=dat, n.impute=1, type="' method '")'])
        end
        evalR('ImpR <- impute.transcan(f, imputation=TRUE, data=dat, list.out = TRUE)')
    else
        warning('WriteinR.m: Imputation with package Hmisc could not be performed because input argument nsamples is not given. Try again by calling WriteinR(lib,method,nsamples).')
    end

% DMwR
elseif strcmp(lib,'DMwR')
    evalR('ImpR <- knnImputation(dat)')
    
% mi
elseif strcmp(lib,'mi')
    evalR('dat <- data.frame(dat)')
    evalR('I <- mi(dat, n.chains=1)')
    evalR('ImpR <- complete(I)[1:length(dat)]')
    
% GMSimpute
elseif strcmp(lib,'GMSimpute')
    evalR(' ImpR <- GMS.Lasso(dat,log.scale=T,TS.Lasso=T)')

% other    
else
    error(['WriteinR.m: library ' lib ' is not recognized. Expand code here.'])
end