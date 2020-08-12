%   A logistic regression model for the occurence of missing values
%
%   O   - @OmicsData object
%   bio - flag if biological information should be taken into account [false]
%
%   out - result of logistic regression function glmfit (incl. types+coefs)
%
% Example:
% out = LearnPattern(O);
% O = GetComplete(O);
% O = AssignPattern(O,out);

function out = LearnPattern(O,bio,regw,logflag)

if ~exist('O','var')
    error('MissingValues/LearnPattern.m requires class O as input argument.')
end
if ~exist('bio','var')
    bio = [];
end

drin = sum(isnan(O),2)<size(O,2);
O = O(drin,:);

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
b = nan(ceil(nfeat/nboot),nboot);
out = struct;

for i=1:nboot  % subsample proteins
    if nboot>1
        fprintf('%i out of %i ...\n',i,nboot);
    end
    if nboot == 1
        ind = 1:nfeat;                              % if nfeat <1000, no subsample
    elseif  i==nboot
        ind = indrand( nperboot*(i-1)+1 : end );    % if last subsample, take indices till end
    else
        ind = indrand( nperboot*(i-1)+1 : nperboot*i );
    end
    
    [X,y,typ,typnames] = GetDesign(O(ind,:),out,bio,logflag);
    if i==1 || length(typ)+1>length(out.type)
        out.type = [0; typ]; % offset gets type=0
        out.typenames = ['offset'; typnames];
    end

    out.stats(i) = LogReg(X,y,regw);
    
    b(1:length(out.stats(i).beta),i) = out.stats(i).beta;
end

% output
brow = b(out.type==3,:);
brow = brow(brow~=0);                       % keep all row coefficients
out.b = [mean(b(out.type~=3),2,'omitnan'); brow];  % mean of coefficients over bootstrap
out.type(end+1:length(out.b)) = out.type(end);
out.typenames(end+1:length(out.b)) = out.typenames(end);
out.X = X;
%PlotDesign(out,isnan(O(ind,:)),get(O,'path'))
end


function stats = LogReg(X,y,regw)

w = ones(size(y));
[X,y] = GetRegularization(X,y);
w(end+1:length(y)) = regw;
%     lastwarn('');

if size(X,1)<50000
     % [B,FitInfo] = lassoglm(X,y,'binomial','link','logit','Lambda',0.01);
     
     [~,~,stats] = glmfit(X,y,'binomial','link','logit','weight',w);
     
%    [~,~,stats] = glmfit(X,y,'binomial','link','logit');          % faster
else
     mdl = fitglm(X,y,'Distribution','binomial','link','logit');  % works for tall matrices
     stats = struct;
     stats.beta = mdl.Coefficients.Estimate;
     stats.p = mdl.Coefficients.pValue;
end

%     if strcmp(lastwarn,'Iteration limit reached.')
%         opts = statset('glmfit');
%         opts.MaxIter = 1000; 
%         [~,~,stats] = glmfit(X,y,'binomial','link','logit','options',opts);
%     end
    
end
            