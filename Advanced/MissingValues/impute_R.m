function impute_R(lib,method,path)

global O
global OPENR
    
% Start R
openR;
if ~strcmp(lib,'jeffwong')
    OPENR.libraries{end+1} = lib;
end

% put method in right format
if ~exist('method','var') || isempty(method)
    method = lib;
end
if ~iscell(method)
    method = {method};
end

% Get data
data = get(O,'data');            % assigned missing pattern


for boot=1:size(data,3)
    dat = data(:,:,boot);
    % rows with just NaNs?
    if get(O,'deleteemptyrows')
        idxnan = find(all(isnan(dat),2));
        if ~isempty(idxnan) && length(idxnan)<size(dat,1)
            warning([num2str(length(idxnan)) ' rows containing all NaNs ignored for imputation. If you dont want this, set(O,deleteemptyrows,false).'])
            dat(idxnan,:) = [];
           % dat(end+1:end+length(idxnan),:) = nan(length(idxnan),size(dat,2));
        end
    end

    putRdata('dat',dat);

    % R packages:
    % pcaMethods
    if strcmp(lib,'pcaMethods')
        if sum(sum(isnan(dat)))< sum(sum(~isnan(dat)))
            evalR('dat[is.na(dat)] <- NA') 
            for i=1:length(method)
                evalR(['if (sum(rowSums(is.na(dat))>=ncol(dat))>0) { ImpR' num2str(i) ' <- {} } else {'])
                evalR(['I' num2str(i) ' <- pca(dat,method="' method{i} '")'])
                evalR(['ImpR' num2str(i) ' <- completeObs(I' num2str(i) ') }'])
                %method{i} = [lib '_' method{i}];
            end
        else
            return
        end
    % LCMD
    elseif strcmp(lib,'imputeLCMD')
        if sum(sum(isnan(dat)))< sum(sum(~isnan(dat)))
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
            %method{i} = [lib '_' method{i}];
        end
        else
            return
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
                end
                if contains(method{i},'gbm')
                    evalR('library("gbm")')
                    evalR('datgbm <- data_putRdata$dat')
                    evalR('datgbm[is.na(datgbm)] <- NA')
                    evalR(['ImpR' num2str(i) ' <- ' method{i} '(datgbm)']);
                else
                    if contains(method{i},'lm')
                        evalR('library("locfit")')
                        evalR('dat <- data_putRdata$dat')
                    end
                    if contains(method{i},'SVD')
                        evalR(['ImpR' num2str(i) ' <- ' method{i} '(dat, k=3)$x']);
                    elseif contains(method{i},'kNN')
                        evalR(['ImpR' num2str(i) ' <- ' method{i} '(dat, k=3)$x']);
                    elseif contains(method{i},'SVT')
                        evalR(['ImpR' num2str(i) ' <- ' method{i} '(dat,lambda=3)$x']);
                    else
                        evalR(['I' num2str(i) ' <- ' method{i} '(dat)']);
                        evalR(['ImpR' num2str(i) ' <- I' num2str(i) '$x']);
                    end    
                end
                %method{i} = [lib '_' method{i}];
            end
        end

    % MICE
    elseif strcmp(lib,'mice')
        %if sum(sum(isnan(dat)))< sum(sum(~isnan(dat)))
            for i=1:length(method)
                if strcmp(method,'ri')
                    da = dat;
                    da(isnan(da))=0;
                    sv = abs(svd(da));
                    if min(sv) < max(sv)*1e-8
                        warning('ri in mice is skipped because the matrix is singular. Try another method.')
                        continue
                    end
                end
                evalR(['I' num2str(i) ' <- mice(dat, m=1, method = "' method{i} '")']);
                evalR(['ImpR' num2str(i) ' <- complete(I' num2str(i) ')']);
                % if too many missing values, not all are capture due to
                % multicollinearity, run a second time then
                evalR(['if (sum(is.na(ImpR' num2str(i) '))>0) { I' num2str(i) ' <- mice(ImpR' num2str(i) ', m=1, method = "' method{i} '")']);
                evalR(['ImpR' num2str(i) ' <- complete(I' num2str(i) ')}']);
                % if it still has missing values, ignore this method
                evalR(['if (sum(is.na(ImpR' num2str(i) '))>0) { ImpR' num2str(i) ' <- {} }']);
                %method{i} = [lib '_' method{i}];
            end
        %else
        %    return
        %end

    % Amelia (Expectation maximization with bootstrap)
    elseif strcmp(lib,'Amelia')
        if sum(sum(isnan(dat)))< sum(sum(~isnan(dat)))
                da = dat;
            da(isnan(da))=0;
            sv = abs(svd(da));
            if min(sv) < max(sv)*1e-8
                warning('Amelia is skipped because the matrix is singular. Try another method.')
            else
                for i=1:length(method)
                    evalR(['f' num2str(i) ' <- amelia(dat, m=1)']);
                    evalR(['ImpR' num2str(i) ' <- f' num2str(i) '$imputations[[1]]']);
                    evalR(['if (sum(is.na(ImpR' num2str(i) '))>0) { ImpR' num2str(i) ' <- {} }']);
                end
            end
        else
            return
        end

    % missForest
    elseif strcmp(lib,'missForest')
        for i=1:length(method)
            evalR(['f' num2str(i) ' <- missForest(dat)']);
            evalR(['ImpR' num2str(i) ' <- f' num2str(i) '$ximp']);
        end

    % Hmisc
    elseif strcmp(lib,'Hmisc')
        if sum(sum(isnan(dat)))< sum(sum(~isnan(dat)))
            evalR('dat <- data.frame(dat)');
            for i=1:length(method)
                formula = '~ X1';
                for j=2:size(dat,2)
                    formula = [formula ' + X' num2str(j)];
                end
                evalR(['f' num2str(i) ' <- aregImpute(' formula ', data=dat, n.impute=1, type="' method{i} '")']);
                evalR(['ImpR' num2str(i) ' <- impute.transcan(f' num2str(i) ', imputation=TRUE, data=dat, list.out = TRUE)']);
                %method{i} = [lib '_' method{i}];
            end
        else
            return
        end

    % DMwR
    elseif strcmp(lib,'DMwR')
        for i=1:length(method)
            evalR(['ImpR' num2str(i) ' <- knnImputation(dat)']);
            %method{i} = [lib '_' method{i}];
        end

    else
        error(['Impute_R.m: library ' lib ' is not recognized. Expand code here to write in R.'])
    end

    % order result
    %ImpM = nan(size(dat,1),size(dat,2),boot,length(method));
    time=zeros(length(method),1);
    for i=1:length(method)
        try        
            t = cputime;
            ImpR = getRdata(['ImpR' num2str(i)]);
            time(i) = cputime-t;
            if ~isempty(ImpR)
                if strcmp(lib,'Hmisc') || strcmp(lib,'mice')
                    ImpR = cell2mat(struct2cell(ImpR)');
                end
                 if size(ImpR,1) < size(data,1)  % aber dann mispat ändern
                     idxnnan = setdiff(1:size(data,1),idxnan);
                     ImpR(idxnnan,:) = ImpR;
                     ImpR(idxnan,:) = nan(length(idxnan),size(ImpR,2));
                 end
                %if ~exist('ImpM','var')
                %    ImpM = ImpR;
                %else
                    ImpM(:,:,boot,i) = ImpR;
                %end
            else
                warning(['Imputation with ' method{i} ' in package ' lib ' is not saved because it still contained missing values (possibly due to a full row of missing values). Try another method or delete rows without a value.'])
            end 
        catch
            warning(['Imputation with ' method{i} ' in package ' lib ' was not feasible.'])
            ImpM = [];
        end
    end
end

% Write result
if exist('ImpM','var') && ~isempty(ImpM)
    if isfield(O,'data_imput') && ~isempty(O,'data_imput')
        Imp = get(O,'data_imput');
        Imp(:,:,1:size(ImpM,3),(size(Imp,4)+1):(size(Imp,4)+size(ImpM,4))) = ImpM;
        method = [get(O,'method_imput'),method];
        time = [get(O,'time_imput');time];
    else
        Imp = ImpM;
    end
    
    % Save
    O = set(O,'data_imput',Imp,'Imputed with R packages');
    O = set(O,'method_imput',method);
    O = set(O,'time_imput',time);
    saveO
end 

closeR;