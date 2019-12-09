% SimuData(m,n,MNAR,MCAR,mu,sig,plt)
% Simulates data matrix for peptide intensities with missing values
%
% m - number of peptides/rows
% n - number of replicates/cols
% a - percentage of missing values
% b - percentage Missing Not At Random of MVs
% mu - mean of mean intensity, conditional differences              [1.5]
% sigP - standard deviation of mean intensity                       [0.5]
% sigG - standard deviation between samples                         [0.5]
% plt - if true, see missing values arising in data matrix         [false]
% 
% Output:
% full - matrix without a missing value
% data - matrix with assigned missing values
% 
% Example:
% [full, data] = SimuData(pep,rep,a,b,8,0.7);
% [full, data] = SimuData(3000,10,30,50,8,0.7);


function data = SimuMV(full,a,b,file)

if ~exist('a','var') || isempty(a)
    error('SimuData.m: Specify percentage of missing values for simulating data.')
end
if ~exist('b','var') || isempty(b)
    error('SimuData.m: Specify percentage of missing not at random for simulating data.')
end
if b>1
    b = b/100;
end
if a>1
    a= a/100;
end
m = size(full,1);
n = size(full,2);

%% Simulate MNAR
T = normrnd(quantile(full(:),a),0.1,m,n); % threshold matrix
mask1 = full<T;
mask2 = boolean(binornd(1,b,m,n)); % binomial draw
MNAR = mask1 & mask2;
if isempty(MNAR)
    MNAR = false(m,n);
end

%% MCAR
v=find(~MNAR);
idx = randsample(length(v),int32(m*n*(1-b)*a));
MCAR = false(m,n);
MCAR(sub2ind([m n],v(idx))) = true;
% idx = find(MNAR);
% MCAR = rand(m,n)>1-(1-b)*a;
% r = randsample(m*n,int32(m*n*(1-b)*a));
% c = setdiff(r,idx);
%r(r==idx) = [];


%% Total
mask = MNAR | MCAR;
data = full;
data(mask) = NaN;
                


%% Plot
if exist('file','var')
    %% Save
    if ~exist([pwd '\Data'],'dir')
        mkdir('Data');
    end
    if ~exist([pwd filesep 'Data' filesep file],'dir')
        mkdir([pwd filesep 'Data' filesep file]);
    end

    figure
    edge = min(full):0.1:max(full);
    histogram(full,edge,'FaceColor','r','FaceAlpha',0.1)
    hold on
    %histogram(T,edge,'FaceAlpha',0.1)
    histogram(data,edge,'FaceColor','c','FaceAlpha',0.1)
    print([pwd '\Data\' file '\' file '_histogramIncorporated'],'-dpng','-r200');
          
   
    %% Sort for plotting
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
    b = imagesc(datamnar);
    set(b,'AlphaData',~isnan(datamnar))
    title({'MNAR';[num2str(round(sum(sum(MNAR))/m/n*100)) '% na']})
    caxis manual
    caxis([bottom top]);
    subplot(1,3,2)
    datamcar = full;
    datamcar(MCAR) = NaN;
    b = imagesc(datamcar);
    set(b,'AlphaData',~isnan(datamcar))
    title({'MCAR';[num2str(round(sum(sum(MCAR))/m/n*100)) '% na']})
    caxis manual
    caxis([bottom top]);
    subplot(1,3,3)
    b = imagesc(dataplt);
    set(b,'AlphaData',~isnan(dataplt))
    title({'Total';[num2str(round(sum(sum(isnan(dataplt)))/m/n*100)) '% na']})
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
    print([pwd '\Data\' file '\' file '_SimuDataMAR'],'-dpng','-r100');
end


