% O = impute(O,method,[lib,clean])
%
% imputes missing data of class O (if exist data_mis else data)
% O - OmicsData class object
% method - cell array of imputation algorithms to run or 
% lib - Rpackage of method (should have same length as method)
% clean - boolean if previous imputations should be cleared beforehand
%
% Example:
% method = {'impnorm','knn','Seq'};
% O = impute(O,method,[],true);
%
% See also: WriteinR to see implemented methods and libraries

function O = impute(O,method,lib,clean,Rpath,Rlibpath)

if ~exist('method','var') || isempty(method)
    method = {'impSeqRob','impSeq','missForest','imputePCA','ppca','MIPCA','bpca','SVDImpute','kNNImpute','regression','aregImpute','softImpute','MinDet','amelia','SVTImpute','irmi','knn','QRILC','nipals','MinProb','rf','sample','pmm','svdImpute','norm','cart','midastouch','mean','ri'};
elseif strcmp(method,'fast')
    methods = {'impSeqRob','impSeq','missForest','imputePCA','ppca','MIPCA','bpca','SVDImpute','kNNImpute','regression','aregImpute','softImpute','MinDet','amelia','SVTImpute','irmi','knn','QRILC','nipals','MinProb','rf','sample','pmm','svdImpute','norm','cart','midastouch','mean','ri'};
    method = methods(1:9);
    fprintf('impute.m: fast option chosen. Checks 5 best algorithms.')
elseif isnumeric(method)
    methods = {'impSeqRob','impSeq','missForest','imputePCA','ppca','MIPCA','bpca','SVDImpute','kNNImpute','regression','aregImpute','softImpute','MinDet','amelia','SVTImpute','irmi','knn','QRILC','nipals','MinProb','rf','sample','pmm','svdImpute','norm','cart','midastouch','mean','ri'};
    method = methods(1:method);
    fprintf(['impute.m: fast option chosen. Checks ' num2str(method) ' best algorithms.'])
end

if ~exist('lib','var') || isempty(lib)
    lib = cell(length(method),0);
    if ~iscell(method)
        method  = {method};
    end
    c=0;
    for i=1:length(method)
        try
            lib{i-c} = GetLib(method(i-c));
        catch
            method(i-c) = [];
            c=c+1;
        end
    end
end
if exist('clean','var') && ~isempty(clean) && clean
    O = imputation_clear(O);  % clear previous imputations in O, optional
end

%% Start R
%global OPENR
if exist('Rpath','var') && ~isempty(Rpath)
	if exist('Rlibpath','var') && ~isempty(Rlibpath)
		Rinit(unique(lib),Rpath,Rlibpath);
	else
		Rinit(unique(lib),Rpath);
	end
else
	Rinit(unique(lib));
end

%% Get data
data = get(O,'data_mis',true);            % assigned missing pattern
if ~exist('data','var') || isempty(data)
    data = get(O,'data'); 
end

npat = get(O,'npat',true);
if isempty(npat)
    npat = size(data,3);
end

% initialize
ImpM = nan(size(data,1),size(data,2),size(data,3),length(method));
time = nan(length(method),npat);


%for ii=1:npat
%    dat = data(:,:,ii);
%    fprintf(['\n impute.m: Imputing pattern ' num2str(ii) '/' num2str(npat) ' with ' num2str(length(method)) ' algorithms..'])

    %% Write in R
    Rpush('dat',data);
    Rrun('dat <- dat');
    WriteinR(lib,method,size(data));

    %% Loop over imputation algorithms
    for i=1:length(method)
            %% Get imputation from R
            try
                t = cputime;
                Imptemp = Rpull(['Imp' method{i}]);
                if isstruct(Imptemp)
                    fprintf(['impute.m: struct2array needed for conversion of struct in ' method{i}])
                    %Imptemp = struct2array(Imptemp); % aregImpute transform in R
                end
                Imptemp = reshape(Imptemp,size(data,1),size(data,2),[]);
                if size(Imptemp,2)>size(ImpM,2)
                    Imptemp = Imptemp(:,1:size(Imptemp,2)/2);  % VIM outputs [imputed_double,imputed_boolean] so columns are doubled
                end
                if size(Imptemp,3)>size(ImpM,3)
                    Imptemp = Imptemp(:,:,1:size(ImpM,3));
                end
                Imptemp(2,2); 
                if exist('mprev','var')
                    if any(strcmpi(method(i),mprev))
                        ImpM(:,:,:,strcmpi(method(i),mprev)) = Imptemp;
                    else
                        ImpM(:,:,:,end+1) = Imptemp;
                        mprev(end+1) = method(i);
                    end
                else
                    ImpM(:,:,1:size(Imptemp,3),i) = Imptemp;
                end
                time(i,npat) = cputime-t; 
                fprintf(['Finished ''' method{i} '''.. '])
            catch
                fprintf(['Imputation was not feasible. '])  
            end   
    end
    if exist('Rwarn.txt','file')
   %     fprintf('\n')
        warning(fileread('Rwarn.txt'))
        delete('Rwarn.txt')
    end
%end
if exist('mprev','var')
    method=mprev;
end
%fprintf('\n')

% Delte not working methods
if any(any(any(all(isnan(ImpM),3))))
    if size(ImpM,3)>1
        idx = squeeze(all(all(all(isnan(ImpM)))));
    else
        idx = squeeze(all(all(isnan(ImpM))));
    end
    ImpM(:,:,:,idx) = [];
    method(idx) = [];
    time(idx,:) = [];
end

%% Save result
if exist('ImpM','var') && ~isempty(ImpM)
    if isfield(O,'data_imput',true) && ~isempty(O,'data_imput')
       Imp = get(O,'data_imput'); 
       Imp(:,:,1:size(ImpM,3),(size(Imp,4)+1):(size(Imp,4)+size(ImpM,4))) = ImpM;
       method = [get(O,'method_imput'),method];
       if size(Imp,4)~=length(method)
           error('impute.m: Dimensions of imputation matrix and imputation algorithms does not match. Check here!')
       end
       time = [get(O,'time_imput');nanmean(time,2)];
    else
       Imp = ImpM;
    end
    
    % Save
    O = set(O,'data_imput',ImpM,'Imputed with R packages');
    O = set(O,'method_imput',method);
    O = set(O,'time_imput',mean(time,2,'omitnan'));
end 
%saveO(O)
Rclear;