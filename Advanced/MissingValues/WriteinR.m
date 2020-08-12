function var = WriteinR(lib,method,dim)

% if iscell(method{i})
%     method{i} = method{i}{:};
% end
if length(dim)>1
    nsamples = dim(2);
    if length(dim)>2
        nparallel = dim(3);
    end
end
    
% Parallelize, if multiple datasets in 3rd dimension
if exist('nparallel','var')
<<<<<<< HEAD
    Rrun('tryCatch( { require(doParallel) },')
    Rrun('warning=function(c) {install.packages("doParallel")')
    Rrun('require(doParallel) })')
    Rrun('tryCatch( { require(foreach) },')
    Rrun('warning=function(c) {install.packages("foreach")')
    Rrun('require(foreach) })')
    Rrun('tryCatch( { require(foreach) },')
    Rrun('warning=function(c) {install.packages("foreach")')
    Rrun('require(foreach) })')
    Rrun('registerDoParallel()')
=======
    evalR('tryCatch( { require(doParallel) },')
    evalR('warning=function(c) {install.packages("doParallel")')
    evalR('require(doParallel) })')
    evalR('tryCatch( { require(foreach) },')
    evalR('warning=function(c) {install.packages("foreach")')
    evalR('require(foreach) })')
>>>>>>> d8671062bf0008d5dc457cee80560c43597f1bec
    datstr = 'dat[,,i]';
else
    datstr = 'dat';
end

for i=1:length(method)
    var = ['Imp' method{i}];
    
    % Parallelize, if multiple datasets in 3rd dimension
    if exist('nparallel','var') && ~strcmp(method{i},'amelia')
<<<<<<< HEAD
        Rrun([var ' <- foreach(i=1:' num2str(nparallel) ', .combine=''cbind'', .packages=''' lib{i} ''') %dopar% {']);
    end
    
    % Catch warnings into Rwarn.txt
    Rrun('tryCatch({')
    
    % pcaMethods
    if strcmp(lib{i},'pcaMethods')
        Rrun(['data <- ' datstr])
        Rrun('data[is.na(data)] <- NA') 
        Rrun(['if (sum(rowSums(is.na(data))>=ncol(data))>0) { ' var ' <- {} } else {'])
        if strcmp(method{i},'nlpca')
            Rrun(['I <- pcaMethods::pca(t(data),method="' method{i} '",maxSteps=max(dim(data)))']) % transpose
            Rrun([var ' <- t(completeObs(I)) }']) 
        else
            Rrun(['I <- pcaMethods::pca(data,method="' method{i} '")'])
            Rrun([var ' <- completeObs(I) }'])  
=======
        evalR([var ' <- foreach(i=1:' num2str(nparallel) ') %dopar% {']);
    end
    
    % Catch warnings into Rwarn.txt
    evalR('tryCatch({')
    
    % pcaMethods
    if strcmp(lib{i},'pcaMethods')
        evalR(['data <- ' datstr])
        evalR('data[is.na(data)] <- NA') 
        evalR(['if (sum(rowSums(is.na(data))>=ncol(data))>0) { ' var ' <- {} } else {'])
        if strcmp(method{i},'nlpca')
            evalR(['I <- pcaMethods::pca(t(data),method="' method{i} '",maxSteps=max(dim(data)))']) % transpose
            evalR([var ' <- t(completeObs(I)) }']) 
        else
            evalR(['I <- pcaMethods::pca(data,method="' method{i} '")'])
            evalR([var ' <- completeObs(I) }'])  
>>>>>>> d8671062bf0008d5dc457cee80560c43597f1bec
        end       

    % knn
    elseif strcmp(lib{i},'impute')
<<<<<<< HEAD
        Rrun(['I <- impute.knn(as.matrix(' datstr '))'])
        Rrun([var ' <- I$data'])

    % norm
    elseif strcmp(lib{i},'norm')
        Rrun(['s <- prelim.norm(' datstr ')'])
        Rrun('thetahat <- em.norm(s)')
        Rrun(' rngseed(1)')
        Rrun([var ' <- imp.norm(s,thetahat,dat)'])

    % missMDA
    elseif strcmp(lib{i},'missMDA')
        %Rrun('datf <- data.frame(dat)') 
        if strcmp(method{i},'MIPCA')
            Rrun(['imp <- missMDA::' method{i} '(data.frame(' datstr '),nboot=1)']) 
            Rrun([var ' <- imp$res.imputePCA'])
        else
            Rrun(['imp <- missMDA::' method{i} '(data.frame(' datstr '))']) 
            Rrun([var ' <- imp$completeObs'])
=======
        evalR(['I <- impute.knn(as.matrix(' datstr '))'])
        evalR([var ' <- I$data'])

    % norm
    elseif strcmp(lib{i},'norm')
        evalR(['s <- prelim.norm(' datstr ')'])
        evalR('thetahat <- em.norm(s)')
        evalR(' rngseed(1)')
        evalR([var ' <- imp.norm(s,thetahat,dat)'])

    % missMDA
    elseif strcmp(lib{i},'missMDA')
        %evalR('datf <- data.frame(dat)') 
        if strcmp(method{i},'MIPCA')
            evalR(['imp <- missMDA::' method{i} '(data.frame(' datstr '),nboot=1)']) 
            evalR([var ' <- imp$res.imputePCA'])
        else
            evalR(['imp <- missMDA::' method{i} '(data.frame(' datstr '))']) 
            evalR([var ' <- imp$completeObs'])
>>>>>>> d8671062bf0008d5dc457cee80560c43597f1bec
        end              

    % rrcovNA
    elseif strcmp(lib{i},'rrcovNA')
        if contains(method{i},'imp')
<<<<<<< HEAD
            Rrun([var ' <- rrcovNA::' method{i} '(' datstr ')'])
        else
            Rrun([var ' <- rrcovNA::imp' method{i} '(' datstr ')'])
        end
        if contains(method{i},'SeqRob')
            Rrun([var ' <- ' var '$x'])
=======
            evalR([var ' <- rrcovNA::' method{i} '(' datstr ')'])
        else
            evalR([var ' <- rrcovNA::imp' method{i} '(' datstr ')'])
        end
        if contains(method{i},'SeqRob')
            evalR([var ' <- ' var '$x'])
>>>>>>> d8671062bf0008d5dc457cee80560c43597f1bec
        end

    % VIM
    elseif strcmp(lib{i},'VIM')
<<<<<<< HEAD
        %Rrun('if (~exists(datm)) { datm <- as.matrix(' datstr ') }')
        Rrun([var ' <- VIM::' method{i} '(as.matrix(' datstr '))'])

    % softImpute
    elseif strcmp(lib{i},'softImpute')
        %Rrun('if (~exists(datm)) { datm <- as.matrix(' datstr ') }')
        Rrun(['f <- softImpute(as.matrix(' datstr '))'])
        Rrun([var ' <- softImpute::complete(as.matrix(' datstr '),f)'])

    % LCMD
    elseif strcmp(lib{i},'imputeLCMD')   
        %Rrun('if (~exists(datm)) { datm <- as.matrix(' datstr ') }')
        if strcmp(method{i},'QRILC')
            Rrun([var ' <- imputeLCMD::impute.QRILC(as.matrix(' datstr '))[[1]]'])
        else
            Rrun([var ' <- imputeLCMD::impute.' method{i} '(as.matrix(' datstr '))'])
=======
        %evalR('if (~exists(datm)) { datm <- as.matrix(' datstr ') }')
        evalR([var ' <- VIM::' method{i} '(as.matrix(' datstr '))'])

    % softImpute
    elseif strcmp(lib{i},'softImpute')
        %evalR('if (~exists(datm)) { datm <- as.matrix(' datstr ') }')
        evalR(['f <- softImpute(as.matrix(' datstr '))'])
        evalR([var ' <- softImpute::complete(as.matrix(' datstr '),f)'])

    % LCMD
    elseif strcmp(lib{i},'imputeLCMD')   
        %evalR('if (~exists(datm)) { datm <- as.matrix(' datstr ') }')
        if strcmp(method{i},'QRILC')
            evalR([var ' <- imputeLCMD::impute.QRILC(as.matrix(' datstr '))[[1]]'])
        else
            evalR([var ' <- imputeLCMD::impute.' method{i} '(as.matrix(' datstr '))'])
>>>>>>> d8671062bf0008d5dc457cee80560c43597f1bec
        end

    % jeffwong
    elseif strcmp(lib{i},'imputation')               
        if contains(method{i},'SVD')
<<<<<<< HEAD
            Rrun([var ' <- imputation::' method{i} '(' datstr ', k=3)$x'])
        elseif contains(method{i},'kNN')
            Rrun([var ' <- imputation::' method{i} '(' datstr ', k=3)$x'])
        elseif contains(method{i},'SVT')
            Rrun([var ' <- imputation::' method{i} '(' datstr ',lambda=3)$x'])
        else
            Rrun(['I <- imputation::' method{i} '(' datstr ')'])
            Rrun([var ' <- I$x'])
=======
            evalR([var ' <- imputation::' method{i} '(' datstr ', k=3)$x'])
        elseif contains(method{i},'kNN')
            evalR([var ' <- imputation::' method{i} '(' datstr ', k=3)$x'])
        elseif contains(method{i},'SVT')
            evalR([var ' <- imputation::' method{i} '(' datstr ',lambda=3)$x'])
        else
            evalR(['I <- imputation::' method{i} '(' datstr ')'])
            evalR([var ' <- I$x'])
>>>>>>> d8671062bf0008d5dc457cee80560c43597f1bec
        end   

    % MICE
    elseif strcmp(lib{i},'mice')                
<<<<<<< HEAD
        Rrun(['I <- mice::mice(' datstr ', m=1, method = "' method{i} '")'])
        Rrun([var ' <- mice::complete(I)'])

    % Amelia (Expectation maximization with bootstrap)
    elseif strcmp(lib{i},'Amelia')
        Rrun('tryCatch( { require(R.utils) },')
        Rrun('warning=function(c) {install.packages("R.utils")')
        Rrun('require(R.utils) })')  
        % if isSymmetric, R aborts without error message
        Rrun(['if (isSymmetric(' datstr ')) { f <- withTimeout({Amelia::amelia(' datstr ',m=1)},timeout = 1, cpu = 100,elapsed=3600)']) % of all pride data the max time of amelia was cpu=1
        Rrun([var ' <- f$imputations[[1]] }'])
        if exist('nparallel','var')
            for np = 2:nparallel
                Rrun(['if (isSymmetric(' datstr ')) {  f <- withTimeout({Amelia::amelia(' datstr ',m=1)},timeout = 1, cpu = 100,elapsed=3600)']) % of all pride data the max time of amelia was cpu=1
                Rrun([var '[,,' num2str(np) '] <- f$imputations[[1]] }'])
            end
            Rrun([var ' <- array(as.numeric(unlist(' var ')), dim=c(' num2str(dim(1)) ',' num2str(dim(2)) ',' num2str(dim(3)) '))'])
=======
        evalR(['I <- mice::mice(' datstr ', m=1, method = "' method{i} '")'])
        evalR([var ' <- mice::complete(I)'])

    % Amelia (Expectation maximization with bootstrap)
    elseif strcmp(lib{i},'Amelia')
        evalR('tryCatch( { require(R.utils) },')
        evalR('warning=function(c) {install.packages("R.utils")')
        evalR('require(R.utils) })')  
        % if isSymmetric, R aborts without error message
        evalR(['if (isSymmetric(' datstr ')) { f <- withTimeout({Amelia::amelia(' datstr ',m=1)},timeout = 1, cpu = 100,elapsed=3600)']) % of all pride data the max time of amelia was cpu=1
        evalR([var ' <- f$imputations[[1]] }'])
        if exist('nparallel','var')
            for np = 2:nparallel
                evalR(['if (isSymmetric(' datstr ')) {  f <- withTimeout({Amelia::amelia(' datstr ',m=1)},timeout = 1, cpu = 100,elapsed=3600)']) % of all pride data the max time of amelia was cpu=1
                evalR([var '[,,' num2str(np) '] <- f$imputations[[1]] }'])
            end
            evalR([var ' <- array(as.numeric(unlist(' var ')), dim=c(' num2str(dim(1)) ',' num2str(dim(2)) ',' num2str(dim(3)) '))'])
>>>>>>> d8671062bf0008d5dc457cee80560c43597f1bec
        end
        
    % missForest
    elseif strcmp(lib{i},'missForest')
<<<<<<< HEAD
        Rrun(['f <- missForest(' datstr ')'])
        Rrun([var ' <- f$ximp'])
=======
        evalR(['f <- missForest(' datstr ')'])
        evalR([var ' <- f$ximp'])
>>>>>>> d8671062bf0008d5dc457cee80560c43597f1bec

    % Hmisc
    elseif strcmp(lib{i},'Hmisc')
        if exist('nsamples','var') && ~isempty(nsamples)
<<<<<<< HEAD
         %   Rrun('dat <- data.frame(' datstr ')')
=======
         %   evalR('dat <- data.frame(' datstr ')')
>>>>>>> d8671062bf0008d5dc457cee80560c43597f1bec
            formula = '~ X1';
            for j=2:nsamples
                formula = [formula ' + X' num2str(j)];
            end
            if strcmp(method{i},'aregImpute')
<<<<<<< HEAD
                Rrun(['f <- Hmisc::aregImpute(' formula ', data=data.frame(' datstr '), n.impute=1, type="pmm") '])
            else
                Rrun(['f <- Hmisc::aregImpute(' formula ', data=data.frame(' datstr '), n.impute=1, type="' method{i} '")'])
            end
            Rrun([var ' <- array(unlist( Hmisc::impute.transcan(f, imputation=TRUE, data=data.frame(' datstr '), list.out = TRUE)) ,dim=dim(' datstr '))'])
=======
                evalR(['f <- Hmisc::aregImpute(' formula ', data=data.frame(' datstr '), n.impute=1, type="pmm") '])
            else
                evalR(['f <- Hmisc::aregImpute(' formula ', data=data.frame(' datstr '), n.impute=1, type="' method{i} '")'])
            end
            evalR([var ' <- array(unlist( Hmisc::impute.transcan(f, imputation=TRUE, data=data.frame(' datstr '), list.out = TRUE)) ,dim=dim(' datstr '))'])
>>>>>>> d8671062bf0008d5dc457cee80560c43597f1bec
        else
            warning('WriteinR.m: Imputation with package Hmisc could not be performed because input argument nsamples is not given. Try again by calling WriteinR(lib,method,nsamples).')
        end

    % DMwR
    elseif strcmp(lib{i},'DMwR')
<<<<<<< HEAD
        Rrun([var ' <- DMwR::knnImputation(' datstr ')'])

    % mi
    elseif strcmp(lib{i},'mi')
        %Rrun('dat <- data.frame(' datstr ')')
        Rrun(['I <- mi(data.frame(' datstr '), n.chains=1)'])
        Rrun([var ' <- mi::complete(I)[1:length(' datstr ')]'])

    % GMSimpute
    elseif strcmp(lib{i},'GMSimpute')
        Rrun([var ' <- GMS.Lasso(' datstr ',log.scale=T,TS.Lasso=T)'])
=======
        evalR([var ' <- DMwR::knnImputation(' datstr ')'])

    % mi
    elseif strcmp(lib{i},'mi')
        %evalR('dat <- data.frame(' datstr ')')
        evalR(['I <- mi(data.frame(' datstr '), n.chains=1)'])
        evalR([var ' <- mi::complete(I)[1:length(' datstr ')]'])

    % GMSimpute
    elseif strcmp(lib{i},'GMSimpute')
        evalR([var ' <- GMS.Lasso(' datstr ',log.scale=T,TS.Lasso=T)'])
>>>>>>> d8671062bf0008d5dc457cee80560c43597f1bec

    % other    
    else
        error(['WriteinR.m: library ' lib{i} ' is not recognized. Expand code here.'])
    end
    
    % end of trycatch and parallelizism
<<<<<<< HEAD
    Rrun('}, error = function(e) { sink("Rwarn.txt", append=T)')
    Rrun(['cat("Error in R package ' lib{i} ' within algorithm ' method{i} ':", conditionMessage(e))'])
    Rrun('sink() })')
    
    if exist('nparallel','var') && ~strcmp(method{i},'amelia')
       Rrun('}');
        % Rrun('return(I)}');
       % Rrun([var ' <- array(as.numeric(unlist(' var ')), dim=c(' num2str(dim(1)) ',' num2str(dim(2)) ',' num2str(dim(3)) '))'])
=======
    evalR('}, error = function(e) { sink("Rwarn.txt", append=T)')
    evalR(['cat("Error in R package ' lib{i} ' within algorithm ' method{i} ':", conditionMessage(e))'])
    evalR('sink() })')
    
    if exist('nparallel','var') && ~strcmp(method{i},'amelia')
        evalR('}');
        evalR([var ' <- array(as.numeric(unlist(' var ')), dim=c(' num2str(dim(1)) ',' num2str(dim(2)) ',' num2str(dim(3)) '))'])
>>>>>>> d8671062bf0008d5dc457cee80560c43597f1bec
    end
    
end