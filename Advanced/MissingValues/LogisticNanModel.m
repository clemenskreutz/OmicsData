%   A logistic regression model for the occurance of missing values
%
%       O       @OmicsData object
%       
%   If O has more than 1000 features, nboot bootstap subset of 1000
%   features are drawn and the predictors are estimated nboot times for
%   these subsets.
%

function out = LogisticNanModel(O)

isna = isnan(O);

drin = find(sum(isna,2)<size(isna,2));
O = O(drin,:);
isna = isna(drin,:);
m = nanmean(O,2)*ones(1,size(isna,2));

nfeat = size(isna,1);

if nfeat>1000
    disp('More than 1000 features, bootstrap of subsamples is applied.');
    indrand = randperm(nfeat,nfeat);
    nboot = ceil(nfeat/1000);       
    nperboot = ceil(nfeat/nboot);
    indlast = 0;
    
    for i=1:nboot
        fprintf('%i out of %i ...\n',i,nboot);

        current = indlast + (1:nperboot);
        current(current>length(indrand)) = [];
        indlast = indlast+length(current);
        
        ind = indrand(current);
        
        tic; 
        out_tmp = LogisticNanModel_core(isna(ind,:), m(ind,:));
        if i==1
            out = struct;
            out.timing = NaN(1,nboot);
            out.b = NaN(size(out_tmp.b,1),nboot);
            out.se = NaN(size(out_tmp.b,1),nboot);
            out.type = NaN(size(out_tmp.b,1),nboot);
            out.current = cell(0);
        end
        out.current{i} = current;
        out.timing(i) = toc;
        out.b(1:length(out_tmp.b),i) = out_tmp.b;
        out.se(1:length(out_tmp.b),i) = out_tmp.stats.se;
        out.type(1:length(out_tmp.b),i) = out_tmp.type;
        if i==1
            out.out1 = out_tmp;
        end
    end
else
    out = LogisticNanModel_core(isna, m);
end
out.type_names = {'mean intensity dependency','column-dependency','rows-dependency'};

function out = LogisticNanModel_core(isna,m)
row  = ((1:size(isna,1))') * ones(1,size(isna,2));
row  = row(:);
col  = ones(size(isna,1),1)*(1:size(isna,2));
col  = col(:);
m = m(:);
y = isna(:);


rlev = levels(row);
clev = levels(col);
m = m-mean(m);  % centered
m = m./nanstd(m); % standardized
X = m;%[ones(size(m)),m];
type = NaN(1,1+length(rlev)+length(clev));
bnames = cell(1,length(rlev)+length(clev)+1);
bnames{1} = 'mean';

X = [X,zeros(size(X,1),length(rlev)+length(clev))];
c = 1;
type(c) = 1; % mean-dependency
for i=1:length(clev)
    c = c+1;
    X(col==clev(i),c) = 1;
    bnames{c} = ['Column',num2str(i)];
    type(c) = 2; % column-dependency
end
for i=1:length(rlev)
    c = c+1;
    X(row==rlev(i),c) = 1;
    bnames{c} = ['Row',num2str(i)];
    type(c) = 3; % row-dependency
end


%% regularization: add a 0 and a 1 for each parameter (-> regularization towards estimate 0 == probability 0.5)
ind = 1;
yreg = zeros(2*size(X,2),1);
xreg = zeros(2*size(X,2),size(X,2));
for i=1:size(X,2)
    xreg(ind:(ind+1),i) = 1;
    yreg(ind+1) = 1;
    ind = ind+2;
end

X = [X;xreg];
y = [y;yreg];

%% check condition number:
removed = 0;
fprintf('size(X,1) = %i\n',size(X,1));
fprintf('size(X,2) = %i\n',size(X,2));
con = cond(X'*X);
if con>1e6
    warning('Condition number = %d ',con);
end

if removed>0
    fprintf('%i columns removed in X due to non-identifiablity.\n',removed);
end

out.X = X;
[b,dev,stats] = glmfit(X,y,'binomial','link','logit','constant','off');
out.b = b;
out.dev = dev;
out.stats = stats;
out.y = y;
out.bnames = bnames;
out.type = type;

