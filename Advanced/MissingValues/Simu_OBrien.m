function [prot,data] = Simu_OBrien(a,b,nprot,nsam,file)

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
protMNAR = (prot - quantile(prot(:),a*b)) ./ nanstd(prot(:));

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

% nMCAR = sum(sum(MCAR)) / size(data,1) / size(data,2)
% nMNAR = sum(sum(MNAR)) / size(data,1) / size(data,2)
% nMV = sum(sum(isnan(data))) / size(data,1) / size(data,2)

if exist('file','var') && ~isempty(file)
    [~,idx] = sort(sum(isnan(data),2));
    dataplt = data(idx,:);
    dataplt = dataplt(~all(isnan(dataplt),2),:);
    prot = prot(idx,:);
    
    figure
    bottom = nanmin(nanmin(dataplt)); %min([min(nanmin(yn)),min(nanmin(yc)),min(nanmin(dataplt))]);
    %top  = max([max(nanmax(yn)),max(nanmax(yc)),max(nanmax(dataplt))]);
    top  = nanmax(nanmax(dataplt));
    
    subplot(1,3,1)
    datamnar = prot;
    datamnar(MNAR) = NaN;
    b = imagesc(datamnar);
    set(b,'AlphaData',~isnan(datamnar))
    title({'MNAR';[num2str(round(sum(sum(MNAR))/nprot/nsam*100)) '% na']})
    caxis manual
    caxis([bottom top]);
    subplot(1,3,2)
    datamcar = prot;
    datamcar(MCAR) = NaN;
    b = imagesc(datamcar);
    set(b,'AlphaData',~isnan(datamcar))
    title({'MCAR';[num2str(round(sum(sum(MCAR))/nprot/nsam*100)) '% na']})
    caxis manual
    caxis([bottom top]);
    subplot(1,3,3)
    b = imagesc(dataplt);
    set(b,'AlphaData',~isnan(dataplt))
    title({'Total';[num2str(round(sum(sum(isnan(dataplt)))/nprot/nsam*100)) '% na']})
    caxis manual
    caxis([bottom top]);
    c=colorbar;
    c.Label.String = 'Difference in magnitude';
%    print([pwd '\Data\' file '\' file '_MNARMCAR'],'-dpng','-r200');
    
    figure
    subplot(1,2,1)
    imagesc(prot)
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
    %print([pwd '\Data\' file '\' file '_SimuDataMAR'],'-dpng','-r100');
end
