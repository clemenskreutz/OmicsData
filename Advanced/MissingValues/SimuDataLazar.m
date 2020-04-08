% SimuData(m,n,mv,nr,mu,sig,plt)
% Simulates data matrix for peptide intensities with missing values
%
% m - number of peptides/rows
% n - number of replicates/cols
% mv - percentage of missing values
% nr - percentage of Missing Not At Random
% mu - mean of mean intensity, conditional differences               [1.5]
% sig - standard deviation of mean int, cond diff, gaussian error    [0.5]
% plt - if true, see missing values arising in data matrix         [false]
% 
% Output:
% full - matrix without mv missing value
% data - matrix with assigned missing values
% 
% Example:
% [full, data] = SimuData(pep,rep,mv,nr,8,0.7);
% [full, data] = SimuData(3000,10,20,10,8,0.7);


function [full,data] = SimuDataLazar(m,n,mv,nr,mu,sigP,sigG,file)

if ~exist('m','var') || isempty(m)
    error('SimuData.m: Specify number of peptides/rows for simulating data.')
end
if ~exist('n','var') || isempty(n)
    error('SimuData.m: Specify number of replicatepeps/columns for simulating data.')
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
if nr<0 || nr>1 
    error('nr<0 || nr>1 ');
end
if mv<0 || mv>100
    error('mv<0 || mv>100');
elseif mv>0 && mv <1
    warning('mv is defined in percentage. You chose mv number between 0 and 1, please check!')
end

full = SimuData(m,n,mu,sigP,sigG,sige);
data = SimuMV(full,mv,nr,file);

% Better use Simu_OBrien


