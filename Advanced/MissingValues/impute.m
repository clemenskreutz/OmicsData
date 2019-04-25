
function impute(method)

global O

if ~exist('O','var')
    error('MissingValues/impute.m requires class O as global variable.')
end
if ~exist('method','var') || isempty(method)
    method = get(O,'method_imput');
    if ~exist('method','var') || isempty(method)
        error('No imputation method given.')
    end
end

dat = get(O,'data_mis');                            % data with simulated missing pattern
Y = nan(size(dat,1),size(dat,2),size(dat,3));       % Matrix for imputation result

% Imputation methods
switch method
    case 'previous'
        for i=1:size(dat,3)
            Y(:,:,i) = fillmissing(dat(:,:,i),'previous');
        end
    case 'next'
        for i=1:size(dat,3)
            Y(:,:,i) = fillmissing(dat(:,:,i),'next');
        end
    case 'nearest'
        for i=1:size(dat,3)
            Y(:,:,i) = fillmissing(dat(:,:,i),'nearest');
        end
    case 'linear'
        for i=1:size(dat,3)
            Y(:,:,i) = fillmissing(dat(:,:,i),'linear');
        end
    case 'spline'
        for i=1:size(dat,3)
            Y(:,:,i) = fillmissing(dat(:,:,i),'spline');
        end
    case 'pchip'
        for i=1:size(dat,3)
            Y(:,:,i) = fillmissing(dat(:,:,i),'pchip');
        end
    case 'movmean'
        for i=1:size(dat,3)
            Y(:,:,i) = fillmissing(dat(:,:,i),'movmean',5);
        end
    case 'pcada'
        for i=1:size(dat,3)
            Y(:,:,i) = pcambda(dat(:,:,i),3,10,3);
        end
    case 'pcaia'
        for i=1:size(dat,3)
            Y(:,:,i) = pcambia(dat(:,:,i),3,10,1e-6);
        end
    case 'pcakdr'
        for i=1:size(dat,3)
            Y(:,:,i) = pcambkdr(dat(:,:,i),3,10,1e-6);
        end
    case 'pcanipals'
        for i=1:size(dat,3)
            Y(:,:,i) = pcambnipals(dat(:,:,i),3,10,1e-6);
        end
    case 'pcatsr'
        for i=1:size(dat,3)
            Y(:,:,i) = pcambtsr(dat(:,:,i),3,10,1e-6);
        end
    otherwise
        fprintf('imputation method unknown')
end

if exist('Y','var') && ~all(all(all(all(isnan(Y)))))
    fprintf(['Data is imputed with method ' method ' and saved in data_imput and data.\n'])
    if isfield(O,'data_imput')
        Imp = get(O,'data_imput');
        Imp(:,:,:,end+1) = Y;
        Y = Imp;
        met = get(O,'method_imput');
        met{1,end+1} = method;
        method = met;
    end
    O = set(O,'data_imput',Y,'Imputed dataset (of simulated missing values)');          
    O = set(O,'data',Y,'Imputed dataset (of simulated missing values)');
    O = set(O,'method_imput',cellstr(method)); 
    
    path = get(O,'path');
    [filepath,name] = fileparts(path);
    if ~exist([filepath '/' name],'dir')
        mkdir(filepath, name)
    end
    save([filepath '/' name '/Imputed.mat'],'Y');
else
    warning('MissingValues/impute.m: Data is not imputed!')
end
