function O = impute_R(O,lib,method)

global OPENR
    
% Start R
openR;
OPENR.libraries{end+1} = lib;

% put method in right format
if ~exist('method','var') || isempty(method)
    method = lib;
end
if ~iscell(method)
    method = {method};
end

% Get data
data = get(O,'data_mis');            % assigned missing pattern
if ~exist('data','var') || isempty(data)
    data = get(O,'data'); 
end
ImpM = nan(size(data,1),size(data,2),size(data,3),length(method));
bootst = get(O,'boot');
if isempty(bootst)
    bootst = size(data,3);
    warning(['"boot" is set to ' num2str(bootst) '.']);
end

for boot=1:bootst
    dat = data(:,:,boot);
    % rows with just NaNs?
    if get(O,'deleteemptyrows')
        idxnan = find(all(isnan(dat),2));
        if ~isempty(idxnan) && length(idxnan)<size(dat,1)
            warning([num2str(length(idxnan)) ' rows containing all NaNs ignored for imputation. If you dont want this, set(O,"deleteemptyrows",false).'])
            dat(idxnan,:) = [];
           % dat(end+1:end+length(idxnan),:) = nan(length(idxnan),size(dat,2));
        end
    else
        warning('Empty rows are not deleted. Consider deleting because empty rows can cause failure in imputation. You can delete empty rows by O = set(O,"deleteemptyrows",true).')
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
            end
        else
            return
        end
        
    % missMDA
    elseif strcmp(lib,'missMDA')
            for i=1:length(method)
                evalR('dat <- data.frame(dat)');  
                if ~isempty(strfind(method{i},'MIPCA'))
                    evalR(['imp <- ' method{i} '(dat,nboot=1)']);    
                    evalR(['ImpR' num2str(i) ' <- imp$res.imputePCA']);
                else
                    evalR(['imp <- ' method{i} '(dat)']);  
                    evalR(['ImpR' num2str(i) ' <- imp$completeObs']);
                end
            end
        
    % rrcovNA
    elseif strcmp(lib,'rrcovNA')
       for i=1:length(method) 
            if ~isempty(strfind(method{i},'SeqRob'))
                evalR(['imp  <- imp' method{i} '(dat)'])
                evalR(['ImpR' num2str(i) ' <- imp$xseq'])
            else
                evalR(['ImpR' num2str(i) ' <- imp' method{i} '(dat)'])
            end
        end
        
    % VIM
    elseif strcmp(lib,'VIM')
        evalR('dat<-as.matrix(dat)');
            for i=1:length(method)
                evalR(['ImpR' num2str(i) ' <- ' method{i} '(dat)']);
            end

    % softImpute
    elseif strcmp(lib,'softImpute')
        for i=1:length(method)
            evalR('dat <- as.matrix(dat)') 
            evalR('f <- softImpute(dat)');
            evalR(['ImpR' num2str(i) ' <- complete(dat,f)']);
        end
            
    % LCMD
    elseif strcmp(lib,'imputeLCMD')
        if sum(sum(isnan(dat)))< sum(sum(~isnan(dat)))
        evalR('dat <- data.matrix(dat)') 
        for i=1:length(method) 
            if ~isempty(strfind(method{i},'KNN'))
                evalR(['ImpR' num2str(i) ' <- impute.wrapper.KNN(dat,K=10)'])
            elseif ~isempty(strfind(method{i},'MLE'))
                evalR(['ImpR' num2str(i) ' <- impute.wrapper.MLE(dat)'])
            elseif ~isempty(strfind(method{i},'QRILC'))
                evalR(['ImpR' num2str(i) ' <- impute.QRILC(dat)[[1]]'])
            else
                evalR(['ImpR' num2str(i) ' <- impute.' method{i} '(dat)'])
            end
        end
        else
            return
        end
    % jeffwong
    elseif strcmp(lib,'imputation')
            for i=1:length(method)
                if ~isempty(strfind(method{i},'SVD'))
                    evalR(['ImpR' num2str(i) ' <- ' method{i} '(dat, k=3)$x']);
                elseif ~isempty(strfind(method{i},'kNN'))
                    evalR(['ImpR' num2str(i) ' <- ' method{i} '(dat, k=3)$x']);
                elseif ~isempty(strfind(method{i},'SVT'))
                    evalR(['ImpR' num2str(i) ' <- ' method{i} '(dat,lambda=3)$x']);
                else
                    evalR(['I' num2str(i) ' <- ' method{i} '(dat)']);
                    evalR(['ImpR' num2str(i) ' <- I' num2str(i) '$x']);
                end    
            end

    % MICE
    elseif strcmp(lib,'mice')
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
                %evalR(['if (sum(is.na(ImpR' num2str(i) '))>0) { I' num2str(i) ' <- mice(ImpR' num2str(i) ', m=1, method = "' method{i} '")']);
                %evalR(['ImpR' num2str(i) ' <- complete(I' num2str(i) ')}']);
                % if it still has missing values, ignore this method
                evalR(['if (sum(is.na(ImpR' num2str(i) '))>0) { ImpR' num2str(i) ' <- {} }']);
                %method{i} = [lib '_' method{i}];
            end

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
                    evalR(['f' num2str(i) ' <- amelia(dat, m=1, ps2=0)']);
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
            evalR('f <- missForest(dat)');
            evalR(['ImpR' num2str(i) ' <- f$ximp']);
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
            end
        else
            return
        end

    % DMwR
    elseif strcmp(lib,'DMwR')
        for i=1:length(method)
            evalR(['ImpR' num2str(i) ' <- knnImputation(dat)']);
        end

    else
        error(['Impute_R.m: library ' lib ' is not recognized. Expand code here to write in R.'])
    end

    % order result
    time=zeros(length(method),1);
    for i=1:length(method)
        try        
            t = cputime;
            ImpR = getRdata(['ImpR' num2str(i)]);
            time(i) = cputime-t;
            if ~isempty(ImpR)
                if strcmp(lib,'Hmisc') || strcmp(lib,'mice') || strcmp(lib,'VIM')
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
        end
    end
end
% Delte not working methods
if any(all(all(all(isnan(ImpM)))))
    idx = squeeze(all(all(all(isnan(ImpM)))));
    ImpM(:,:,:,idx) = [];
    method(idx) = [];
end


% Write result
if exist('ImpM','var') && ~isempty(ImpM)
    if isfield(O,'data_imput') && ~isempty(O,'data_imput')
        Imp = get(O,'data_imput');
        Imp(:,:,1:size(ImpM,3),(size(Imp,4)+1):(size(Imp,4)+size(ImpM,4))) = ImpM;
        method = [get(O,'method_imput'),method];
        if size(Imp,4)~=size(method,2)
            'stop'
        end
        time = [get(O,'time_imput');time];
    else
        Imp = ImpM;
    end
    
    % Save
    O = set(O,'data_imput',Imp,'Imputed with R packages');
    O = set(O,'method_imput',method);
    O = set(O,'time_imput',time);
    saveO(O)
end 

closeR;