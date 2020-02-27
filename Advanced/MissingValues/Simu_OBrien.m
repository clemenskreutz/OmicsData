function [prot,data] = Simu_OBrien(a,b,nprot,nsam)

if ~exist('nprot','var') || isempty(nprot)
    nprot = 200;
end
if ~exist('nsam','var') || isempty(nsam)
    nsam = 2;
end
if ~exist('a','var') || isempty(a)
    a = 0.5;
end
if ~exist('b','var') || isempty(b)
    b = 1;
end
if a>1
    a = a/100;
end
if b>1
    b = b/100;
end

%1
tau_pep = sqrt(1/gamma(1));
tau_fc = sqrt(1/gamma(1.5));
sig = sqrt(1/gamma(2));
%2
FC = randn(nprot,1)*tau_fc;
%3
lam = 4;
npep = poissrnd(lam,nprot,1)+1;
%4
pep = randn(nprot,max(npep))*tau_pep+18.5;
for i=1:nprot
    pep(i,npep(i)+1:end) = NaN;
end
%5
prot = nanmean(pep,2)+randn(nprot,ceil(nsam/2))*sig;
prot(:,end+1:end*2) = prot+FC;

% Norm Janine
protMNAR = (prot - nanmean(prot(:))) ./ nanstd(prot(:)) - quantile(prot(:),a*b) + nanmean(prot(:));

MNAR = cdf('Normal',protMNAR,0,1);
MNAR = ~boolean(binornd(1,MNAR));

%% MCAR
MCAR = false(nprot,nsam);
%if 0<b
    v=find(~MNAR);
    idx = randsample(length(v),int32(nprot*nsam*(1-b)*a));
    MCAR(sub2ind([nprot nsam],v(idx))) = true;
%end

%% Total
mask = MNAR | MCAR;
data = prot;
data(mask) = NaN;

nMCAR = sum(sum(MCAR)) / size(data,1) / size(data,2)
nMNAR = sum(sum(MNAR)) / size(data,1) / size(data,2)
nMV = sum(sum(isnan(data))) / size(data,1) / size(data,2)
