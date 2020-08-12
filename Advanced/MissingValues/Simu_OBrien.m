% [full,data] = Simu_OBrien(mv,nr,nprot,nsam,file)
% Simulates data matrix for protein intensities with missing values
%
% nprot - number of peptides/rows
% nsam - number of replicates/cols
% mv - percentage of missing values
% nr - percentage of Missing Not At Random
% file - if true, plots/saves data matrix         [false]
% 
% Output:
% full - matrix without missing values
% data - matrix with assigned missing values
% 
% Example:
% [full, data] = Simu_OBrien(mv,nr,nprot,nsam,file)
% [full, data] = Simu_OBrien(0.3,0.8,4000,20)



function [full,data] = Simu_OBrien(mv,nr,nprot,nsam,file)

if ~exist('nprot','var') || isempty(nprot)
    nprot = 200;
end
if ~exist('nsam','var') || isempty(nsam)
    nsam = 2;
end
if ~exist('mv','var') || isempty(mv)
    mv = 0.5;
end
if ~exist('nr','var') || isempty(nr)
    nr = 1;
end
if mv>1
    mv = mv/100;
end
if nr>1
    nr = nr/100;
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
full = mean(pep,2,'omitnan')+randn(nprot,ceil(nsam/2))*sig;
full(:,end+1:end*2) = full+FC;

% Norm Janine
protMNAR = (full - mean(full(:),'omitnan')) ./ std(full(:),'omitnan');
protMNAR = protMNAR*mv*nr+ quant(protMNAR(:),mv*nr);

%% MNAR
MNAR = cdf('Normal',protMNAR,0,1);
r = rand(size(MNAR));
MNAR = r<=MNAR;

%% MCAR
MCAR = false(nprot,nsam);
%if 0<nr
    v=find(~MNAR);
    idx = unique(ceil(rand(nprot*nsam,1)*length(v)),'stable');
    idx = idx(1:int32(nprot*nsam*(1-nr)*mv));
    %idx = randsample(length(v),int32(nprot*nsam*(1-nr)*mv));
    MCAR(sub2ind([nprot nsam],v(idx))) = true;
%end

%% Total
mask = MNAR | MCAR;
data = full;
data(mask) = NaN;

%nMCAR = sum(sum(MCAR)) / size(data,1) / size(data,2)
%nMNAR = sum(sum(MNAR)) / size(data,1) / size(data,2)
%nMV = sum(sum(isnan(data))) / size(data,1) / size(data,2)

if exist('file','var') && ~isempty(file)
    [~,idx] = sort(sum(isnan(data),2));
    dataplt = data(idx,:);
    dataplt = dataplt(~all(isnan(dataplt),2),:);
    full = full(idx,:);
    
    figure
    bottom = nanmin(nanmin(dataplt)); %min([min(nanmin(yn)),min(nanmin(yc)),min(nanmin(dataplt))]);
    %top  = max([max(nanmax(yn)),max(nanmax(yc)),max(nanmax(dataplt))]);
    top  = nanmax(nanmax(dataplt));
    
    subplot(1,3,1)
    datamnar = full;
    datamnar(MNAR) = NaN;
    nr = imagesc(datamnar);
    set(nr,'AlphaData',~isnan(datamnar))
    title({'MNAR';[num2str(round(sum(sum(MNAR))/nprot/nsam*100)) '% na']})
    caxis manual
    caxis([bottom top]);
    subplot(1,3,2)
    datamcar = full;
    datamcar(MCAR) = NaN;
    nr = imagesc(datamcar);
    set(nr,'AlphaData',~isnan(datamcar))
    title({'MCAR';[num2str(round(sum(sum(MCAR))/nprot/nsam*100)) '% na']})
    caxis manual
    caxis([bottom top]);
    subplot(1,3,3)
    nr = imagesc(dataplt);
    set(nr,'AlphaData',~isnan(dataplt))
    title({'Total';[num2str(round(sum(sum(isnan(dataplt)))/nprot/nsam*100)) '% na']})
    caxis manual
    caxis([bottom top]);
    c=colorbar;
    c.Label.String = 'Difference in magnitude';
    print([pwd '\Data\' file '\' file '_MNARMCAR'],'-dpng','-r200');
    
    figure
    subplot(1,2,1)
    imagesc(full)
    caxis manual
    caxis([bottom top]);
    ylabel('proteins (sorted)')
    xlabel('samples')
    title({'Simulated data'})
    subplot(1,2,2)
    nr = size(dataplt,1);
    nc = size(dataplt,2);
    pcolor([dataplt nan(nr,1); nan(1,nc+1)]);
    shading flat;
    set(gca, 'ydir', 'reverse');
%    imagesc(dataplt)
    caxis manual
    caxis([bottom top]);
    xlabel('samples')
    title('Simulated MNAR/MCAR')
    c = colorbar('Units','normalized','Position',[0.93 0.11 0.02 0.815]);
    c.Label.String = 'log_2(Intensity)';
    print([pwd '\Data\' file '\' file '_SimuData'],'-dpng','-r100');
end
