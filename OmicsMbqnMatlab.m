% The follwing steps are done by MBQN
% 
%   1) calculation of rowmeans (via meanfun)
%   2) subtraction of the rowmeans
%   3) ordinary quantile normalization
%   4) adding the previously subtracted row means
% 
%   whereImpute     1: means imputation is exclusively done before step 1)
%                   and withdraw after step 1)
% 
%                   2 means imputation is exclusively done before step 1)
%                   and withdraw after step 2)
% 
%                   0 without imputation [Default]
% 
%   qnMean      Sollen die means (offsets) selber auch quantlienormalisiert
%               werden? Dann sehen boxplots später eher wie qn aus.
%               [false]     Default (wegen kompatibiltität)

function O = OmicsMbqnMatlab(O,whereImpute,meanfun,qnMean)
if ~exist('meanfun','var') || isempty(meanfun)
    meanfun = 'nanmedian';
end
if ~exist('qnMean','var') || isempty(qnMean)
    qnMean = false;
end
if ~exist('whereImpute','var') || isempty(whereImpute)
    whereImpute = 0; % no imputation
end


dat = get(O,'data');

if whereImpute>0
    isna = isnan(dat);
    dat = mice(dat,'cart');
end

m = NaN(size(dat,1),1);
for i=1:size(dat,1)
    m(i) = feval(meanfun,dat(i,:));
end%

if whereImpute==1
    dat(isna) = NaN; 
end

if qnMean
    mmatrix = m*ones(1,size(dat,2));
    mmatrix(isnan(get(O,'data'))) = NaN;  % deswegen kann MBQN boxplot erzeugen, der nicht nach QN aussieht
    mmQn = quantilenorm(mmatrix);

    disp('Balancing is done under quantilenorm-contraint.')
    offsets = mmQn;
else
    offsets = m*ones(1,size(dat,2));
end

dat = dat-offsets;
dat = quantilenorm(dat);
if whereImpute==2
    dat(isna) = NaN; 
end
dat = dat+offsets;

O = set(O,'data',dat,['Custom MBQN Normalization implemented in Matlab, imputation option ',num2str(whereImpute)]);


