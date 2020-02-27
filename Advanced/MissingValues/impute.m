% O = impute(O,method,[lib,clean])
%
% imputes missing data of class O (if exist data_mis else data)
% O - OmicsData class object
% method - cell array of imputation algorithms to run or 
% lib - Rpackage of method (should have same length as method)
% clean - boolean if previous imputations should be cleared beforehand
%
% Example:
% methods = {'impnorm','knn','Seq'};
% O = impute(O,methods,[],true);
%
% See also: WriteinR to see implemented methods and libraries

function O = impute(O,method,lib,clean)

if ~exist('method','var') || isempty(method)
    methods = {'impSeq','missForest','SVDImpute','imputePCA','SVTImpute','irmi','bpca','ppca','MIPCA','kNNImpute','SeqRob','KNN','QRILC','nipals','MinProb','ri','rf','sample','pmm','svdImpute','svd','MIPCA','norm','cart','imputePCA','Norm','softImpute','MinDet','Amelia','regression','midastouch','mean'};
end
if strcmp(method,'fast')
    methods = {'impSeq','missForest','SVDImpute','imputePCA','SVTImpute','irmi','bpca','ppca','MIPCA','kNNImpute','SeqRob','KNN','QRILC','nipals','MinProb','ri','rf','sample','pmm','svdImpute','svd','MIPCA','norm','cart','imputePCA','Norm','softImpute','MinDet','Amelia','regression','midastouch','mean'};
    method = methods(1:10);
    fprintf('impute.m: fast option chosen. Checks 5 best algorithms.')
end
if isnumeric(method)
    methods = {'impSeq','missForest','SVDImpute','imputePCA','SVTImpute','irmi','bpca','ppca','MIPCA','kNNImpute','SeqRob','KNN','QRILC','nipals','MinProb','ri','rf','sample','pmm','svdImpute','svd','MIPCA','norm','cart','imputePCA','Norm','softImpute','MinDet','Amelia','regression','midastouch','mean'};
    method = methods(1:method);
    fprintf(['impute.m: fast option chosen. Checks ' num2str(method) ' best algorithms.'])
end
if exist('methods','var')
    method = methods;
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
    %fprintf(['impute.m: Number of pattern simulations is expected to be ' num2str(npat) '.\n']);
end

% Amelia does not work for non-symmetric matrices (gets stuck in warning)
if ~issymmetric(data)
    if any(strcmpi(method,'amelia'))
        lib(strcmpi(method,'amelia')) = [];
        method(strcmpi(method,'amelia')) = [];
        warning('Imputation with amelia is not performed because data is not symmetric.')
    end
end

% initialize
ImpM = nan(size(data,1),size(data,2),size(data,3),length(method));
time = nan(length(method),npat);

%% Loop over # of patterns to simulate (default: npat = 5)
for ii=1:npat
    dat = data(:,:,ii);
    
    %% Remove not working algorithms
    rem = [];
%     if sum(sum(isnan(dat)))> sum(sum(~isnan(dat)))
%         rem = find(ismember(lib,{'Hmisc','impute'}));
%         warning('Impute.m: Hmisc and impute packages are skipped because there are more than 50% MV. Try other methods.')
%     end
    da = dat;
    da(isnan(da))=0;
    sv = abs(svd(da));
    if min(sv) < max(sv)*1e-8
        warning('Impute.m: Amelia and ri are skipped because the matrix is singular. Try other methods.')
        rem = [rem find(ismember(method,{'ri','Amelia'}))];
    end

    fprintf(['\n impute.m: Imputing pattern ' num2str(ii) '/' num2str(npat) ' with ' num2str(length(method)) ' algorithms..'])
%% Loop over imputation algorithms    
    for i=1:length(method)    
        if ~ismember(i,rem)
        
            %% Write in R
            putRdata('dat',dat);
            OPENR.libraries{end} = lib{i};
            WriteinR(lib{i},method{i},size(dat,2))

            %% Get imputation from R
            try
                t = cputime;
                Imptemp = getRdata('ImpR');
                if isstruct(Imptemp)
                    Imptemp = struct2array(Imptemp);
                end
                if size(Imptemp,2)>size(ImpM,2)
                    Imptemp = Imptemp(:,1:size(Imptemp,2)/2);  % VIM outputs [imputed_double,imputed_boolean] so columns are doubled
                end
                ImpM(:,:,ii,i) = Imptemp;
                time(i,npat) = cputime-t; 
                fprintf(['Finished ''' method{i} '''.. '])
            catch
                warning(['Imputation with ' method{i} ' in package ' lib{i} ' was not feasible.'])  
            end   
            deleteR;
        end
    end
end
fprintf('\n')
closeR;

% Delte not working methods
if any(isnan(ImpM(:)))
    if size(ImpM,3)>1
        idx = squeeze(any(any(any(isnan(ImpM)))));
    else
        idx = squeeze(any(any(isnan(ImpM))));
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
            error('ImputePattern.m: Dimensions of imputation matrix and imputation algorithms does not match. Check here!')
        end
        time = [get(O,'time_imput');nanmean(time,2)];
    else
        Imp = ImpM;
    end
    
    % Save
    O = set(O,'data_imput',Imp,'Imputed with R packages');
    O = set(O,'method_imput',method);
    O = set(O,'time_imput',nanmean(time,2));
end 
saveO(O)
