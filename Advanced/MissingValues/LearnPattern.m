%   A logistic regression model for the occurence of missing values
%
%   O         @OmicsData object

function out = LearnPattern(O)

if ~exist('O','var')
    error('MissingValues/LearnPattern.m requires class O as input argument.')
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
X = nan(dim,size(O,2),nboot);
b = nan(ceil(nfeat/nboot),nboot);
out.b = [];
out.type = [];
out.typenames = [];

for i=1:nboot  % subsample proteins
    fprintf('%i out of %i ...\n',i,nboot);
    if nboot == 1
        ind = 1:nfeat;                              % if nfeat <1000, no subsample
    elseif  i==nboot
        ind = indrand( nperboot*(i-1)+1 : end );    % if last subsample, take indices till end
    else
        ind = indrand( nperboot*(i-1)+1 : nperboot*i );
    end
    
    [X,y,type,typenames] = GetDesign(O(ind,:),out);
        out.type = [0; type]; % offset gets type=0
        out.typenames = ['offset'; typenames];
    
    out.stats(i) = LogReg(X,y);
    
    % if X is ill-conditioned or overparametrized
    if any(out.stats(i).beta==0) %|| isfield(out,'significant')  
        %out.idxrem = find(out.stats(i).beta==0)-1;
        out.significant = 1;
        out = GetSignificance(out);  
        [X,y,type,typenames] = GetDesign(O(ind,:),out); % LogReg without not-significant predictors
        out.type = [0; type];
        out.typenames = ['offset'; typenames];
        out.stats(i) = LogReg(X,y);
    end
%     if all(out.stats(i).beta==0) || isfield(out,'significant')                        
%         out.significant = 1;
%         out = GetSignificance(out);                      % get not-significant predictors       
%         [X,y,type,typenames] = GetDesign(O(ind,:),out); % LogReg without not-significant predictors
%         out.type = [0; type]; % offset gets type=0
%         out.typenames = ['offset'; typenames];
%         out.stats(i) = LogReg(X,y);
%     end
    b(1:length(out.stats(i).beta),i) = out.stats(i).beta;
end

% output
out.X = X;
out.b = nanmean(b,2);


% Plot
PlotDesign(out,isnan(O(ind,:)),get(O,'path'))

end


function stats = LogReg(X,y)

    [X,y] = GetRegularization(X,y);
    
%     lastwarn('');
    [~,~,stats] = glmfit(X,y,'binomial','link','logit');
    
%     if strcmp(lastwarn,'Iteration limit reached.')
%         opts = statset('glmfit');
%         opts.MaxIter = 1000; 
%         [~,~,stats] = glmfit(X,y,'binomial','link','logit','options',opts);
%     end
    
end
            