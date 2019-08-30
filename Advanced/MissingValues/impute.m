function O = impute(O,method,lib,clean)

if ~exist('lib','var') || isempty(lib)
    lib = {};
    if ~iscell(method)
        method  = {method};
    end
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
    fprintf(['Number of pattern simulations is expected to be ' num2str(npat) '.\n']);
end

% initialize
ImpM = nan(size(data,1),size(data,2),size(data,3),length(method));
time = nan(length(method),npat);

%% Loop over # of patterns to simulate (default: npat = 5)
for ii=1:npat
    dat = data(:,:,ii);
    
    %% Remove not working algorithms
    rem = [];
    if sum(sum(isnan(dat)))> sum(sum(~isnan(dat)))
        rem = find(ismember(lib,{'pcaMethods','imputeLCMD','Hmisc','Amelia'}));
        warning('Impute.m: Amelia, imputeLCMD, Hmisc and pcaMethods packages are skipped because there are more than 50% MV. Try other methods.')
    end
    da = dat;
    da(isnan(da))=0;
    sv = abs(svd(da));
    if min(sv) < max(sv)*1e-8
        warning('Impute.m: Amelia and ri are skipped because the matrix is singular. Try other methods.')
        rem = [rem find(ismember(method,{'ri','Amelia'}))];
    end
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
        if ~ismember(i,rem)
        
            %% Write in R
            putRdata('dat',dat);
            OPENR.libraries{end} = lib{i};
            WriteinR(lib{i},method{i},size(dat,2))

            %% Get imputation from R
            try
                tic
                Imptemp = getRdata('ImpR');
                if isstruct(Imptemp)
                    Imptemp = struct2array(Imptemp);
                end
                if size(Imptemp,2)>size(ImpM,2)
                    Imptemp = Imptemp(:,1:size(Imptemp,2)/2);  % VIM outputs [imputed_double,imputed_boolean] so columns are doubled
                end
                ImpM(:,:,ii,i) = Imptemp;
                time(i) = toc;            
            catch
                warning(['Imputation with ' method{i} ' in package ' lib{i} ' was not feasible.'])  
            end    
        end
    end
end
closeR;

% Delte not working methods
if any(any(all(all(isnan(ImpM)))))
    if size(ImpM,3)>1
        idx = squeeze(all(all(all(isnan(ImpM)))));
    else
        idx = squeeze(all(all(isnan(ImpM))));
    end
    ImpM(:,:,:,idx) = [];
    method(idx) = [];
end

% Are nans or infs in imputation?
isna = zeros(length(method),1);
isin = zeros(length(method),1);
for i=1:length(method)
    if any(any(isnan(ImpM(:,:,:,i))))
        isna(i) = 1;
    end
    if any(any(isinf(ImpM(:,:,:,i))))
        isin(i) = 1;
    end
end
meth = struct;
meth.name = method;
meth.isna = isna;
meth.isin = isin;

%% Save result
if exist('ImpM','var') && ~isempty(ImpM)
    if isfield(O,'data_imput') && ~isempty(O,'data_imput')
        Imp = get(O,'data_imput');
        Imp(:,:,1:size(ImpM,3),(size(Imp,4)+1):(size(Imp,4)+size(ImpM,4))) = ImpM;
        meth = [get(O,'method_imput'),meth];
        if size(Imp,4)~=length(meth)
            error('ImputePattern.m: Dimensions of imputation matrix and imputation algorithms does not match. Check here!')
        end
        time = [get(O,'time_imput');nanmean(time,2)];
    else
        Imp = ImpM;
    end
    
    % Save
    O = set(O,'data_imput',Imp,'Imputed with R packages');
    O = set(O,'method_imput',meth);
    O = set(O,'time_imput',time);
    
    O = GetTable(O);
    %O = GetRankTable(O);
end 
