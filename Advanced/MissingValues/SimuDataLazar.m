% SimuData(m,n,MNAR,MCAR,mu,sig,plt)
% Simulates data matrix for peptide intensities with missing values
%
% m - number of peptides/rows
% n - number of replicates/cols
% MNAR - percentage Missing Not At Random
% MCAR - percentage Missing Completely At Random
% mu - mean of mean intensity, conditional differences               [1.5]
% sig - standard deviation of mean int, cond diff, gaussian error    [0.5]
% plt - if true, see missing values arising in data matrix         [false]
% 
% Output:
% full - matrix without a missing value
% data - matrix with assigned missing values
% 
% Example:
% [full, data] = SimuData(pep,rep,MNAR,MCAR,8,0.7);
% [full, data] = SimuData(3000,10,20,10,8,0.7);


function [full,data] = SimuDataLazar(m,n,a,b,mu,sigP,sigG,file)

if ~exist('m','var') || isempty(m)
    error('SimuData.m: Specify number of peptides/rows for simulating data.')
end
if ~exist('n','var') || isempty(n)
    error('SimuData.m: Specify number of replicatepeps/columns for simulating data.')
end
if ~exist('mv','var') || isempty(mv)
    error('SimuData.m: Specify percentage of missing values for simulating data.')
end
if ~exist('nr','var') || isempty(nr)
    error('SimuData.m: Specify percentage of missing not at random for simulating data.')
end
if ~exist('mu','var') || isempty(mu)
    mu = 1.5;
end
if ~exist('sigP','var') || isempty(sigP)
    sigP=0.5;
end
if ~exist('sigG','var') || isempty(sigG)
    sigG=sigP;
end
if b<0 || b>1 
    error('b<0 || b>1 ');
end
if a<0 || a>100
    error('a<0 || a>100');
elseif a>0 && a <1
    warning('a is defined in percentage. You chose a number between 0 and 1, please check!')
end

full = SimuData(npep,rep,mu,sigP,sigG,sige);
data = SimuMV(full,a,b,file);

% Better use Simu_OBrien


