function impute_R(lib,method)

global O
global OPENR

% Start R
openR;
OPENR.libraries{end+1} = lib;

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
% MICE
if strcmp(lib,'mice')
    for i=1:length(method)
%         if strcmp(method(i),'cart')
%             evalR('require(rpart)')
%         end
        evalR(['I' num2str(i) ' <- mice(dat, m=1, method = "' method{i} '")']);
        evalR(['ImpR' num2str(i) ' <- complete(I' num2str(i) ')']);
        method{i} = [lib '_' method{i}];
    end

% Amelia (EMB)
elseif strcmp(lib,'Amelia')
    for i=1:length(method)
        evalR(['f' num2str(i) ' <- amelia(dat, m=1)']);
        evalR(['ImpR' num2str(i) ' <- f' num2str(i) '$imputations[[1]]']);
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
    if ~exist('ImpM','var')
        ImpM = ImpR;
    else
        ImpM(:,:,1:size(dat,3),i) = ImpR;
    end
end

% Write result
if isfield(O,'data_imput') && ~isempty(O,'data_imput')
    Imp = get(O,'data_imput');
    Imp(:,:,1:size(dat,3),size(Imp,4)+1:size(Imp,4)+length(method)) = ImpM;
    method = [get(O,'method_imput'),method];
else
    Imp = ImpM;
end

O = set(O,'data_imput',Imp,'Imputed with R packages');
O = set(O,'method_imput',method);
output

closeR;