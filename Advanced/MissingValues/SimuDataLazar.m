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


function [full,data] = SimuDataLazar(m,n,a,b,mu,sigP,sigG,boot,file,plt)

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
if ~exist('plt','var') || isempty(plt)
    plt = false;
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

dat = nan(m,n,boot);
for i=1:boot

     %% Simulate data values
     P = normrnd(mu,sigP,m,1);    % mean peptide value
     G = normrnd(0,sigG,1,n) ; % conditional differences
     full = P+G;

     %% Simulate MNAR
     % Threshold
     q = quantile(reshape(full,size(full,1)*size(full,2),1),a);
     T = normrnd(q,0.01,m,n);

     mask1 = full<T;
     mask2 = binornd(1,b,m,n); 

     mask = mask1.*mask2;
     mask(mask==1) = nan;
     mask(mask==0) = 1;
     yn = full.*mask;
     mis = sum(sum(isnan(yn)))/size(yn,1)/size(yn,2)
%       figure
%       subplot(1,3,1)
%       imagesc(mask1(1:10,1:10))
%       subplot(1,3,2)
%       imagesc(mask2(1:10,1:10))
%       subplot(1,3,3)
%       imagesc(mask(1:10,1:10))      
%       imagesc(yn(1:10,1:10))
% 
%       sum(sum(mask1==1))/m/n
%        sum(sum(mask2==0))/m/n
%        sum(sum(isnan(yn)))/m/n       
%        


    % MCAR
    ind = find(isnan(reshape(yn,size(yn,1),size(yn,2),1)));  % Indices which are already nan
    r = randsample(size(full,1)*size(full,2)-length(ind),int32(n*m*(1-b)*a)); % randomly sample MCAR% 
    notnans = 1:size(full,1)*size(full,2);
    notnans(ind) = [];
    rem = notnans(r);
    yc = full;
    yc(sub2ind([m n],rem)) = nan;

    % Total
    mask = ~isnan(yn).*~isnan(yc); % MNAR and MCAR together
    mask(mask==0) = nan;
    data = full.*mask;
        
    dat(:,:,i) = data;

end
                
% Save
if ~exist([pwd '\Data'],'dir')
    mkdir('Data')
end
if ~exist([pwd '\Data\' file],'dir')
    mkdir([pwd '\Data\' file])
end
save([pwd '\Data\' file '\' file '_full.mat'],'full')
save([pwd '\Data\' file '\' file '.mat'],'data')

% Plot
if plt
    % MNAR
%    figure
%     subplot(1,3,1)
%     imagesc(mask1)
%     title({'Threshold matrix';'MNAR+MCAR';[num2str(round(sum(sum(mask1==1))/m/n*100)) '% na']})
%     subplot(1,3,2)
%     imagesc(mask2)
%     title({'Bernoulli draw';'MNAR/(MNAR+MCAR)';[num2str(round(sum(sum(mask2==1))/m/n*100)) '% na']})
%     subplot(1,3,3)
%     imagesc(mask)
%     title({'Total';'MNAR';[num2str(round(sum(sum(mask==1))/m/n*100)) '% na']})
    
    % nan histogram
  %  figure
  %  subplot(1,3,1);
  %  histogram(sum(isnan(yn),2))
  %  subplot(1,3,2);
  %  histogram(sum(isnan(yc),2))
   % subplot(1,3,3);
   % histogram(sum(isnan(data),2))
   
         figure
      edge = min(full):0.1:max(full);
      histogram(full,edge,'FaceColor','r','FaceAlpha',0.1)
      hold on
      %histogram(T,edge,'FaceAlpha',0.1)
      histogram(yn,edge,'FaceColor','c','FaceAlpha',0.1)
      print([pwd '\Data\' file '\' file '_histogramIncorporated'],'-dpng','-r200');
          
   
   %% Sort for plotting
    [~,idx] = sort(sum(isnan(data),2));
    data = data(idx,:);
    dat = data(~all(isnan(data),2),:);
    full = full(idx,:);
    
    figure
    bottom = nanmin(nanmin(dat)); %min([min(nanmin(yn)),min(nanmin(yc)),min(nanmin(dat))]);
    %top  = max([max(nanmax(yn)),max(nanmax(yc)),max(nanmax(dat))]);
    top  = nanmax(nanmax(dat));
    
    subplot(1,3,1)
    b = imagesc(yn);
    set(b,'AlphaData',~isnan(yn))
    title({'MNAR';[num2str(round(sum(sum(isnan(yn)))/m/n*100)) '% na']})
    caxis manual
    caxis([bottom top]);
    subplot(1,3,2)
    b = imagesc(yc);
    set(b,'AlphaData',~isnan(yc))
    title({'MCAR';[num2str(round(sum(sum(isnan(yc)))/m/n*100)) '% na']})
    caxis manual
    caxis([bottom top]);
    subplot(1,3,3)
    b = imagesc(dat);
    set(b,'AlphaData',~isnan(dat))
    title({'Total';[num2str(round(sum(sum(isnan(dat)))/m/n*100)) '% na']})
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
    nr = size(dat,1);
    nc = size(dat,2);
    pcolor([dat nan(nr,1); nan(1,nc+1)]);
    shading flat;
    set(gca, 'ydir', 'reverse');
%    imagesc(data)
    caxis manual
    caxis([bottom top]);
    xlabel('samples')
    title('Simulated MNAR/MCAR')
    c = colorbar('Units','normalized','Position',[0.93 0.11 0.02 0.815]);
    c.Label.String = 'log_2(Intensity)';
    print([pwd '\Data\' file '\' file '_SimuDataMAR'],'-dpng','-r1000');
end


