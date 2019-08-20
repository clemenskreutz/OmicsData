%   A logistic regression model for the occurance of missing values
%
%       O       @OmicsData object
%       
%   If O has more than 1000 features, nboot bootstap subset of 1000
%   features are drawn and the predictors are estimated nboot times for
%   these subsets.
%
function out = LearnPattern(O)

if ~exist('O','var')
    error('MissingValues/LearnPattern.m requires class O as input argument.')
end

% Delete empty proteins for logreg
drin = sum(isnan(O),2)<size(O,2);
O = O(drin,:);

% Get data
isna = isnan(O);
m = nanmean(O,2);
m = m-mean(m);  % centered
m = m./nanstd(m); % standardized

% Linearize mean
mis = sum(isna,2)./size(isna,2);    
mean_trans_fun = @(m,x)(1./(1+exp(x(1)*m+x(2))));
x0=[-1;0];
fun=@(x)(1./(1+exp(x(1)*m+x(2)))-mis);
options = optimset('TolFun',1e-20,'TolX',1e-20);
[lincoef,~] = lsqnonlin(fun,x0,[],[],options);
m = feval(mean_trans_fun,m,lincoef); 

% Subsample indices
nfeat = size(O,1);
if nfeat>1000
    nboot = ceil(nfeat/1000);  
    indrand = randperm(nfeat,nfeat);    
    nperboot = ceil(nfeat/nboot);
else
    nboot = 1;
end

% Initialize
dim = ceil(nfeat/nboot)+size(O,2)+2;
b = nan(dim,nboot);
dev = nan(dim,nboot);
type = nan(dim,nboot);

for i=1:nboot
    
    fprintf('%i out of %i ...\n',i,nboot);
    if nboot == 1
        ind = 1:nfeat;                              % if nfeat <1000, no subsample
    elseif  i==nboot
        ind = indrand( nperboot*(i-1)+1 : end );    % if last subsample, take indices till end
    else
        ind = indrand( nperboot*(i-1)+1 : nperboot*i );
    end
    
    [X,y,type,typenames] = GetDesign(isna(ind,:),m(ind));
    
    % Log Reg
    [bfit,devfit,statsfit] = glmfit(X,y,'binomial','link','logit');

    b(1:length(bfit),i) = bfit;
    dev(1:length(devfit),i) = devfit;
    stats(i) = statsfit;    
end

% Generate output struct
out.b = nanmean(b,2);
out.dev = dev;
out.stats = stats;
out.type = [0; type]; % offset gets type=0
out.typenames = ['offset'; typenames];

out.lincoef = lincoef;
out.mean_trans_fun = mean_trans_fun;
