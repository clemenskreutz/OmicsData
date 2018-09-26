function impute_R(lib,method,path)

global O
global OPENR

% Start R
openR;
if ~strcmp(lib,'jeffwong')
    OPENR.libraries{end+1} = lib;
end

% Get data
dat = get(O,'data_mis');            % assigned missing pattern
putRdata('dat',dat);

if ~exist('method','var') || isempty(method)
    method = lib;
end
if ~iscell(method)
    method = {method};
end

% R packages:
if strcmp(lib,'pcaMethods')
    evalR('dat[is.na(dat)] <- NA') 
    for i=1:length(method)
        evalR(['if (sum(rowSums(is.na(dat))>=ncol(dat))>0) { ImpR' num2str(i) ' <- {} } else {'])
        evalR(['I' num2str(i) ' <- pca(dat,method="' method{i} '")'])
        evalR(['ImpR' num2str(i) ' <- completeObs(I' num2str(i) ') }'])
    end
% LCMD
elseif strcmp(lib,'imputeLCMD')
    evalR('dat <- data.matrix(dat)') 
    for i=1:length(method) 
        if contains(method{i},'KNN')
            evalR(['ImpR' num2str(i) ' <- impute.wrapper.KNN(dat,K=10)'])
        elseif contains(method{i},'MLE')
            evalR(['ImpR' num2str(i) ' <- impute.wrapper.MLE(dat)'])
        elseif contains(method{i},'QRILC')
            evalR(['ImpR' num2str(i) ' <- impute.QRILC(dat)[[1]]'])
        else
            evalR(['ImpR' num2str(i) ' <- impute.' method{i} '(dat)'])
        end
    end
    
% jeffwong
elseif strcmp(lib,'jeffwong')
    if ~exist(path,'file')
        path = strrep(path,'/','\');
        path = strrep(path,'\\','\');
        if ~exist(path,'file') || isempty(path)
            fprintf('Select directory for R implementation of jeffwong')
            path = uigetdir;
        end
    end
    if ~exist(path,'file') || isempty(path)
        warning('Jeffwong implementation ignored because directory of source files is unknown. Did you download it? Then specify in gui.')
    else
        for i=1:length(method)
            if i==1
                path = strrep(path,'\','/');
                evalR(['file.sources = list.files(path="' path '/R/", pattern="*.R")'])
                evalR(['sapply(paste("' path '/R/",file.sources,sep=""),source,.GlobalEnv)'])               
                %evalR('data <- data.matrix(dat)')
            end
            if contains(method{i},'gbm')
                evalR('library("gbm")')
                evalR('datgbm <- data_putRdata$dat')
                evalR('datgbm[is.na(datgbm)] <- NA')
                %evalR('datgbm <- data.matrix(datgbm)')
                evalR(['ImpR' num2str(i) ' <- ' method{i} '(datgbm)']);
            else
                if contains(method{i},'lm')
                    evalR('library("locfit")')
                    evalR('dat <- data_putRdata$dat')
                end
                if contains(method{i},'SVD') || contains(method{i},'kNN')
                    evalR(['ImpR' num2str(i) ' <- ' method{i} '(dat, k=1)$x']);
                elseif contains(method{i},'SVT')
                    evalR(['ImpR' num2str(i) ' <- ' method{i} '(dat,lambda=0.1)$x']);
                else
                    evalR(['I' num2str(i) ' <- ' method{i} '(dat)']);
                    evalR(['ImpR' num2str(i) ' <- I' num2str(i) '$x']);
                end
                method{i} = [lib '_' method{i}];
            end
        end
    end

% MICE
elseif strcmp(lib,'mice')
    for i=1:length(method)
        evalR(['I' num2str(i) ' <- mice(dat, m=1, method = "' method{i} '")']);
        evalR(['ImpR' num2str(i) ' <- complete(I' num2str(i) ')']);
        % if too many missing values, not all are capture due to
        % multicollinearity, run a second time then
        evalR(['if (sum(is.na(ImpR' num2str(i) '))>0) { I' num2str(i) ' <- mice(ImpR' num2str(i) ', m=1, method = "' method{i} '")']);
        evalR(['ImpR' num2str(i) ' <- complete(I' num2str(i) ')}']);
        % if it still has missing values, ignore this method
        evalR(['if (sum(is.na(ImpR' num2str(i) '))>0) { ImpR' num2str(i) ' <- {} }']);
        method{i} = [lib '_' method{i}];
    end

% Amelia (Expectation maximization with bootstrap)
elseif strcmp(lib,'Amelia')
    for i=1:length(method)
        evalR(['f' num2str(i) ' <- amelia(dat, m=1)']);
        evalR(['ImpR' num2str(i) ' <- f' num2str(i) '$imputations[[1]]']);
        evalR(['if (sum(is.na(ImpR' num2str(i) '))>0) { ImpR' num2str(i) ' <- {} }']);
    end
    
% missForest
elseif strcmp(lib,'missForest')
    for i=1:length(method)
        evalR(['f' num2str(i) ' <- missForest(dat)']);
        evalR(['ImpR' num2str(i) ' <- f' num2str(i) '$ximp']);
    end
    
% Hmisc
elseif strcmp(lib,'Hmisc')
    evalR('dat <- data.frame(dat)');
    for i=1:length(method)
        formula = '~ X1';
        for j=2:size(dat,2)
            formula = [formula ' + X' num2str(j)];
        end
        evalR(['f' num2str(i) ' <- aregImpute(' formula ', data=dat, n.impute=1, type="' method{i} '")']);
        evalR(['ImpR' num2str(i) ' <- impute.transcan(f' num2str(i) ', imputation=TRUE, data=dat, list.out = TRUE)']);
        method{i} = [lib '_' method{i}];
    end
    
% DMwR
elseif strcmp(lib,'DMwR')
    for i=1:length(method)
        evalR(['ImpR' num2str(i) ' <- knnImputation(dat)']);
        method{i} = [lib '_' method{i}];
    end
    
else
    error(['Impute_R.m: library ' lib ' is not recognized. Expand code here to write in R.'])
end
        
% order result
for i=1:length(method)
    ImpR = getRdata(['ImpR' num2str(i)]);
    if strcmp(lib,'mice') || strcmp(lib,'Hmisc')
        ImpR = cell2mat(struct2cell(ImpR)');
    end
   % if strcmp(lib,'pcaMethods') || strcmp(lib,'jeffwang')
   %     ImpR = str2double(ImpR);
   % end
    if ~exist('ImpM','var')
        ImpM = ImpR;
    else
        ImpM(:,:,1:size(dat,3),i) = ImpR;
    end
end

% Write result
if ~isempty(ImpM)
    if isfield(O,'data_imput') && ~isempty(O,'data_imput')
        Imp = get(O,'data_imput');
        Imp(:,:,1:size(dat,3),size(Imp,4)+1:size(Imp,4)+length(method)) = ImpM;
        method = [get(O,'method_imput'),method];
    else
        Imp = ImpM;
    end
    
    % Save
    O = set(O,'data_imput',Imp,'Imputed with R packages');
    O = set(O,'method_imput',method);
    output
else
    warning(['Imputation with ' method{i} ' in package ' lib ' is not saved because it still contained missing values (possibly due to a full row of missing values). Try another method.'])
end 

closeR;