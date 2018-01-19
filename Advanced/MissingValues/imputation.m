
function O = imputation(O,method)

if ~exist('O','var')
    error('OmicsData object has to be passed in to function imputation.m.')
end
if ~exist('method','var') || isempty(method)
    method = get(O,'method_imput');
    if ~exist('method','var') || isempty(method)
        error('No imputation method given.')
    end
end

dat = get(O,'data');                            % data with missing pattern
Y = nan(size(dat,1),size(dat,2),size(dat,3));   % Matrix for imputation

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
    case 'pcambda'
        for i=1:size(dat,3)
            Y(:,:,i) = pcambda(dat(:,:,i),3,10,3);
        end
    case 'pcambia'
        for i=1:size(dat,3)
            Y(:,:,i) = pcambia(dat(:,:,i),3,10,1e-6);
        end
    case 'pcambkdr'
        for i=1:size(dat,3)
            Y(:,:,i) = pcambkdr(dat(:,:,i),3,10,1e-6);
        end
    case 'pcambnipals'
        for i=1:size(dat,3)
            Y(:,:,i) = pcambnipals(dat(:,:,i),3,10,1e-6);
        end
    case 'pcambtsr'
        for i=1:size(dat,3)
            Y(:,:,i) = pcambtsr(dat(:,:,i),3,10,1e-6);
        end
    otherwise
        fprintf('imputation method unknown')
end

if exist('Y','var') && ~all(all(all(all(isnan(Y)))))
    Imp = get(O,'data_imput');
    if ~isempty(Imp)
        Imp(:,:,:,end+1) = Y;
        Y = Imp;
        met = get(O,'method_imput');
        met{1,end+1} = method;
        method = met;
    end
    dataset = [get(O,'dataset'),1:size(dat,3)];
    O = set(O,'data_imput',Y);
    O = set(O,'method_imput',cellstr(method));
    O = set(O,'dataset',dataset);
else
    fprintf('Data is not imputed.')
end
