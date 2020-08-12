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
    datstr = 'dat[,,i]';
else
    datstr = 'dat';
end

for i=1:length(method)
    var = ['Imp' method{i}];
    
    % Parallelize, if multiple datasets in 3rd dimension
    if exist('nparallel','var') && ~strcmp(method{i},'amelia')
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
        end       

    % knn
    elseif strcmp(lib{i},'impute')
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
        end              

    % rrcovNA
    elseif strcmp(lib{i},'rrcovNA')
        if contains(method{i},'imp')
            Rrun([var ' <- rrcovNA::' method{i} '(' datstr ')'])
        else
            Rrun([var ' <- rrcovNA::imp' method{i} '(' datstr ')'])
        end
        if contains(method{i},'SeqRob')
            Rrun([var ' <- ' var '$x'])
        end

    % VIM
    elseif strcmp(lib{i},'VIM')
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
        end

    % jeffwong
    elseif strcmp(lib{i},'imputation')               
        if contains(method{i},'SVD')
            Rrun([var ' <- imputation::' method{i} '(' datstr ', k=3)$x'])
        elseif contains(method{i},'kNN')
            Rrun([var ' <- imputation::' method{i} '(' datstr ', k=3)$x'])
        elseif contains(method{i},'SVT')
            Rrun([var ' <- imputation::' method{i} '(' datstr ',lambda=3)$x'])
        else
            Rrun(['I <- imputation::' method{i} '(' datstr ')'])
            Rrun([var ' <- I$x'])
        end   

    % MICE
    elseif strcmp(lib{i},'mice')                
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
        end
        
    % missForest
    elseif strcmp(lib{i},'missForest')
        Rrun(['f <- missForest(' datstr ')'])
        Rrun([var ' <- f$ximp'])

    % Hmisc
    elseif strcmp(lib{i},'Hmisc')
        if exist('nsamples','var') && ~isempty(nsamples)
         %   Rrun('dat <- data.frame(' datstr ')')
            formula = '~ X1';
            for j=2:nsamples
                formula = [formula ' + X' num2str(j)];
            end
            if strcmp(method{i},'aregImpute')
                Rrun(['f <- Hmisc::aregImpute(' formula ', data=data.frame(' datstr '), n.impute=1, type="pmm") '])
            else
                Rrun(['f <- Hmisc::aregImpute(' formula ', data=data.frame(' datstr '), n.impute=1, type="' method{i} '")'])
            end
            Rrun([var ' <- array(unlist( Hmisc::impute.transcan(f, imputation=TRUE, data=data.frame(' datstr '), list.out = TRUE)) ,dim=dim(' datstr '))'])
        else
            warning('WriteinR.m: Imputation with package Hmisc could not be performed because input argument nsamples is not given. Try again by calling WriteinR(lib,method,nsamples).')
        end

    % DMwR
    elseif strcmp(lib{i},'DMwR')
        Rrun([var ' <- DMwR::knnImputation(' datstr ')'])

    % mi
    elseif strcmp(lib{i},'mi')
        %Rrun('dat <- data.frame(' datstr ')')
        Rrun(['I <- mi(data.frame(' datstr '), n.chains=1)'])
        Rrun([var ' <- mi::complete(I)[1:length(' datstr ')]'])

    % GMSimpute
    elseif strcmp(lib{i},'GMSimpute')
        Rrun([var ' <- GMS.Lasso(' datstr ',log.scale=T,TS.Lasso=T)'])

    % other    
    else
        error(['WriteinR.m: library ' lib{i} ' is not recognized. Expand code here.'])
    end
    
    % end of trycatch and parallelizism
    Rrun('}, error = function(e) { sink("Rwarn.txt", append=T)')
    Rrun(['cat("Error in R package ' lib{i} ' within algorithm ' method{i} ':", conditionMessage(e))'])
    Rrun('sink() })')
    
    if exist('nparallel','var') && ~strcmp(method{i},'amelia')
       Rrun('}');
        % Rrun('return(I)}');
       % Rrun([var ' <- array(as.numeric(unlist(' var ')), dim=c(' num2str(dim(1)) ',' num2str(dim(2)) ',' num2str(dim(3)) '))'])
    end
    
end