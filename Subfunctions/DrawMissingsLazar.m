% dat = DrawMissingsLazar(dat,alpha,beta,[sigT])
% 
%   dat     data (without missing values) either as vector or as matrix
% 
%   alpha   rate of all missing values: 100/nm * (#MNAR + #MCAR)
% 
%   beta    MNAR ration, i.e. 100*#MNAR /(#MNAR+#MCAR)
% 
% Drawing missing values according to the stochastic thresold model used
% in: 
% Lazar et al. Accounting for the Multiple Natures of Missing Values in Label-Free
% Quantitative Proteomics Data Sets to Compare Imputation Strategies
% 
% Example:
% dat = randn(1000,10);
% dat2 = DrawMissingsLazar(dat,50,0.3);
% hist([dat(:),dat2(:)],100)

function dat = DrawMissingsLazar(dat,alpha,beta,sigT)
if ~exist('sigT','var') || isempty(sigT)
    sigT = 1;%sqrt(0.01);  % in the paper sigT=0.01 which makes no sense, I guess sigT^2=0.01
end
if beta<0 || beta>1 
    error('beta<0 || beta>1 ');
end
if alpha<0 || alpha>100
    error('alpha<0 || alpha>100');
elseif alpha>0 && alpha <1
    warning('alpha is defined in percentage. You chose a number between 0 and 1, please check!')
end
if sum(isnan(dat(:)))>0
    error('data already contains missing values.')
end 
% doplot = 0; % default
doplot = 1; % for development purposes, 

datIn = dat;
muT = quantile(dat(:),alpha/100);  % mean of threshold matrix

%% MNARs: alpha*beta percent, e.g. for alpha=0.5, beta=0.3 => 15% MNARs
T = randn(size(dat))*sigT + muT;
r = rand(size(dat));
% isMnar = r<(alpha*beta)/100 & dat<T;
isMnar = r<quantile(r(dat<T),beta) & dat<T; %quantiles are closer to intended proportions

dat(isMnar) = NaN;
fprintf('%.2f%s MNARs, ',100*sum(isnan(dat(:)))/numel(datIn),'%');

%% MCARs: Additionally alpha*(1-beta) percent, e.g. for alpha=0.5, beta=0.3 => 35% MCARs
r = rand(size(dat));
% isMcar = r<((1-beta)*alpha/100);  % in the paper: 100-beta which makes no sense since beta is in [0,1]
fracAlready = (alpha/100*beta);
isMcar = r<quantile(r,(1-beta)*alpha/100  /(1-fracAlready));  % quantiles are closer to intended percentage, correction not explained in the paper, in the paper: 100-beta which makes no sense since beta is in [0,1]

dat(isMcar) = NaN;
fprintf('%.2f%s NAs\n ',100*sum(isnan(dat(:)))/numel(datIn),'%');

if doplot % only for development purpose
    hist([datIn(:),dat(:)],100)
    legend('datIn','dat')
end
