%   A logistic regression model for the occurence of missing values
%
%   O         @OmicsData object
%   constant  LogReg with constant offset

function out = LearnPattern(O,constant)

if ~exist('O','var')
    error('MissingValues/LearnPattern.m requires class O as input argument.')
end
if ~exist('constant','var') || isempty(constant)
    constant = true;
end

drin = sum(isnan(O),2)<size(O,2);
O = O(drin,:);

% Coefficients for linearizing mean
m = nanmean(O,2);
m = (m-nanmean(m))./nanstd(m);
isna = isnan(O);
mis = sum(isna,2)./size(isna,2);    

x0=[-1;0];
fun=@(x)(1./(1+exp(x(1)*m+x(2)))-mis);
options = optimset('TolFun',1e-20,'TolX',1e-20);%,'Display','iter');
[lincoef,~] = lsqnonlin(fun,x0,[],[],options);
out.mean_trans_fun = @(m,x)(1./(1+exp(x(1)*m+x(2))));
out.lincoef = lincoef;

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
dev = nan(nboot);
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
    
    [X,y,type,typenames] = GetDesign(O(ind,:),out);
    [X,y] = GetRegularization(X,y);
    
    % Log Reg
    if constant
        [bfit,devfit,statsfit] = glmfit(X,y,'binomial','link','logit');
    else
        [bfit,devfit,statsfit] = glmfit(X,y,'binomial','link','logit','constant','off'); 
    end
    
    b(1:length(bfit),i) = bfit;
    dev(i) = devfit;
    stats(i) = statsfit;    
end

% Generate output struct
out.b = nanmean(b,2);  % mean because not all are necessary
out.dev = dev;         % not used, but saved for one pattern to check
out.stats = stats;
out.X = X;
if constant
    out.type = [0; type]; % offset gets type=0
    out.typenames = ['offset'; typenames];
    out.constant = 1;
else
    out.type = type;
    out.typenames = typenames;
    out.constant = 0;
end

% To check significance
PlotDesign(out,isnan(O(ind,:)))
path = get(O,'path');
[filepath,name] = fileparts(path);
print([filepath filesep name filesep name '_Design'],'-dpng','-r100');
[sig,rem] = GetSignificance(out);
'end'
