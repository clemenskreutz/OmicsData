function O = Impute(O,method,lib,clean)

if ~exist('lib','var') || isempty(lib)
    lib = {};
    for i=1:length(method)    
        lib{i} = GetLib(method(i));
    end
end
if exist('clean','var') && ~isempty(clean) && clean
    O = imputation_clear(O);  % clear previous imputations in O, optional
end

%% Start R
global OPENR
openR;
OPENR.libraries{end+1} = lib{1};

%% Get data
data = get(O,'data_mis',true);            % assigned missing pattern
if ~exist('data','var') || isempty(data)
    data = get(O,'data'); 
end

npat = get(O,'npat',true);
if isempty(npat)
    npat = size(data,3);
    fprintf(['"npat" is set to ' num2str(npat) '.']);
end

% initialize
ImpM = nan(size(data,1),size(data,2),size(data,3),length(method));
time = nan(length(method),npat);

%% Loop over # of patterns to simulate (default: npat = 5)
for ii=1:npat
    dat = data(:,:,ii);
    
    % rows with just NaNs?
%     if get(O,'deleteemptyrows')
%         idxnan = find(all(isnan(dat),2));
%         if ~isempty(idxnan) && length(idxnan)<size(dat,1)
%             warning([num2str(length(idxnan)) ' rows containing all NaNs ignored for imputation. If you dont want this, set(O,"deleteemptyrows",false).'])
%             dat(idxnan,:) = [];
%         end
%     else
%         warning('Empty rows are not deleted. Consider deleting because empty rows can cause failure in imputation. You can delete empty rows by O = set(O,"deleteemptyrows",true).')
%     end

%% Loop over imputation algorithms    
    for i=1:length(method)    
        
        putRdata('dat',dat);
        OPENR.libraries{end} = lib{i};
        
        % pcaMethods
        if strcmp(lib(i),'pcaMethods')
            if sum(sum(isnan(dat)))< sum(sum(~isnan(dat)))
                evalR('dat[is.na(dat)] <- NA') 
                evalR('if (sum(rowSums(is.na(dat))>=ncol(dat))>0) { ImpR <- {} } else {')
                evalR(['I <- pca(dat,method="' method{i} '")'])
                evalR('ImpR <- completeObs(I) }')           
            else
                return
            end

        % missMDA
        elseif strcmp(lib(i),'missMDA')
            evalR('dat <- data.frame(dat)');  
            if ~isempty(strfind(method{i},'MIPCA'))
                evalR(['imp <- ' method{i} '(dat,nboot=1)']);    
                evalR('ImpR <- imp$res.imputePCA');
            else
                evalR(['imp <- ' method{i} '(dat)']);  
                evalR('ImpR <- imp$completeObs');
            end              

        % rrcovNA
        elseif strcmp(lib(i),'rrcovNA')
            if ~isempty(strfind(method{i},'SeqRob'))
                evalR(['imp  <- imp' method{i} '(dat)'])
                evalR('ImpR <- imp$x')
            else
                evalR(['ImpR <- imp' method{i} '(dat)'])
            end

        % VIM
        elseif strcmp(lib(i),'VIM')
            evalR('dat<-as.matrix(dat)');
            evalR(['ImpR <- ' method{i} '(dat)']);


        % softImpute
        elseif strcmp(lib(i),'softImpute')
            evalR('dat <- as.matrix(dat)') 
            evalR('f <- softImpute(dat)');
            evalR('ImpR <- complete(dat,f)');

        % LCMD
        elseif strcmp(lib(i),'imputeLCMD')
            
            if sum(sum(isnan(dat)))< sum(sum(~isnan(dat)))    
                evalR('dat <- data.matrix(dat)')
                if ~isempty(strfind(method{i},'KNN'))
                    evalR('ImpR <- impute.wrapper.KNN(dat,K=10)')
                elseif ~isempty(strfind(method{i},'MLE'))
                    evalR('ImpR <- impute.wrapper.MLE(dat)')
                elseif ~isempty(strfind(method{i},'QRILC'))
                    evalR('ImpR <- impute.QRILC(dat)[[1]]')
                else
                    evalR(['ImpR <- impute.' method{i} '(dat)'])
                end
            else
                return
            end
        % jeffwong
        elseif strcmp(lib(i),'imputation')               
            if ~isempty(strfind(method{i},'SVD'))
                evalR(['ImpR <- ' method{i} '(dat, k=3)$x']);
            elseif ~isempty(strfind(method{i},'kNN'))
                evalR(['ImpR <- ' method{i} '(dat, k=3)$x']);
            elseif ~isempty(strfind(method{i},'SVT'))
                evalR(['ImpR <- ' method{i} '(dat,lambda=3)$x']);
            else
                evalR(['I' num2str(i) ' <- ' method{i} '(dat)']);
                evalR(['ImpR <- I' num2str(i) '$x']);
            end    

        % MICE
        elseif strcmp(lib(i),'mice')                
            if strcmp(method,'ri')
                da = dat;
                da(isnan(da))=0;
                sv = abs(svd(da));
                if min(sv) < max(sv)*1e-8
                    warning('ri in mice is skipped because the matrix is singular. Try another method.')
                    continue
                end
            end
            evalR(['I <- mice(dat, m=1, method = "' method{i} '")']);
            evalR('ImpR <- complete(I)');
            % if too many missing values, not all are capture due to multicollinearity, run a second time then
            %evalR(['if (sum(is.na(ImpR))>0) { I' num2str(i) ' <- mice(ImpR, m=1, method = "' method{i} '")']);
            %evalR(['ImpR <- complete(I' num2str(i) ')}']);
            % if it still has missing values, ignore this method
            evalR('if (sum(is.na(ImpR))>0) { ImpR <- {} }');

        % Amelia (Expectation maximization with bootstrap)
        elseif strcmp(lib(i),'Amelia')
            if sum(sum(isnan(dat)))< sum(sum(~isnan(dat)))
                da = dat;
                da(isnan(da))=0;
                sv = abs(svd(da));
                if min(sv) < max(sv)*1e-8
                    warning('Amelia is skipped because the matrix is singular. Try another method.')
                else
                    evalR('f <- amelia(dat, m=1, ps2=0)');
                    evalR('ImpR <- f$imputations[[1]]');
                    evalR('if (sum(is.na(ImpR))>0) { ImpR <- {} }');
                end
            else
                return
            end

        % missForest
        elseif strcmp(lib(i),'missForest')
            evalR('f <- missForest(dat)');
            evalR('ImpR <- f$ximp');

        % Hmisc
        elseif strcmp(lib(i),'Hmisc')
            if sum(sum(isnan(dat)))< sum(sum(~isnan(dat)))
                evalR('dat <- data.frame(dat)');
                formula = '~ X1';
                for j=2:size(dat,2)
                    formula = [formula ' + X' num2str(j)];
                end
                evalR(['f' num2str(i) ' <- aregImpute(' formula ', data=dat, n.impute=1, type="' method{i} '")']);
                evalR(['ImpR <- impute.transcan(f' num2str(i) ', imputation=TRUE, data=dat, list.out = TRUE)']);
            else
                return
            end

        % DMwR
        elseif strcmp(lib(i),'DMwR')
            evalR('ImpR <- knnImputation(dat)');

        % other    
        else
            error(['Impute_R.m: library ' lib{i} ' is not recognized. Expand code here.'])
        end
        
        %% Get imputation from R
        try
            tic
            if strcmp(lib(i),'softImpute') || strcmp(lib(i),'rrcovNA') || strcmp(lib(i),'missMDA')
                ImpM(:,:,ii,i) = getRdata('ImpR');
            elseif strcmp(lib(i),'VIM')
                Imptemp = struct2array(getRdata('ImpR'));
                ImpM(:,:,ii,i) = Imptemp(:,1:size(ImpM,2));  % VIM outputs [imputed_double,imputed_boolean] so columns are doubled
            else
                ImpM(:,:,ii,i) = struct2array(getRdata('ImpR'));
            end
            time(i) = toc;            
        catch
            warning(['Imputation with ' method{i} ' in package ' lib{i} ' was not feasible.'])  
        end    
    end
end
closeR;

% Delte not working methods
if any(all(all(all(isnan(ImpM)))))
    idx = squeeze(all(all(all(isnan(ImpM)))));
    ImpM(:,:,:,idx) = [];
    method(idx) = [];
end

%% Save result
if exist('ImpM','var') && ~isempty(ImpM)
    if isfield(O,'data_imput') && ~isempty(O,'data_imput')
        Imp = get(O,'data_imput');
        Imp(:,:,1:size(ImpM,3),(size(Imp,4)+1):(size(Imp,4)+size(ImpM,4))) = ImpM;
        method = [get(O,'method_imput'),method];
        if size(Imp,4)~=size(method,2)
            error('ImputePattern.m: Dimensions of imputation matrix and imputation algorithms does not match. Check here!')
        end
        time = [get(O,'time_imput');nanmean(time,2)];
    else
        Imp = ImpM;
    end
    
    % Save
    O = set(O,'data_imput',Imp,'Imputed with R packages');
    O = set(O,'method_imput',method);
    O = set(O,'time_imput',time);
    
    O = GetTable(O);
    O = GetRankTable(O);
end 
