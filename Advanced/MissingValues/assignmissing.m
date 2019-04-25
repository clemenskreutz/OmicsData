function assignmissing

global O

if ~exist('O','var')
    error('MissingValues/assignmissing.m requires class O as global variable.')
end

dat = get(O,'data_original');                                           % Original with missing values
out = get(O,'out');                                                     % Logreg coefficients
try
    boot = get(O,'boot');
catch
    boot = 1;
end

% Save directory
path = get(O,'path');
[filepath,name] = fileparts(path);
% Remove existing figures (Matlab does not overwrite images)
if exist([filepath '\' name '\' name '_SimulatedMissingPattern_1.tif'],'file')
    delete([filepath '\' name '\' name '_SimulatedMissingPattern*.tif']);
    delete([filepath '\' name '\' name '_MissingRowCol*.tif']);
else
    mkdir(filepath, name)
end

% Sort for plotting
[~,idx] = sort(sum(isnan(dat),2));
datplot = dat(idx,:);
comp = datplot(~any(isnan(datplot),2),:);  % Complete matrix is used for pattern simu

%% normalize/linearize mean matrix
full_norm = (comp-nanmean(comp(:)))./nanstd(comp(:));
linmean = -1./(1+exp(out.c(1)*full_norm+out.c(2)));

% Compare linearized for logreg
me = out.m;
figure; histogram(me,100)
hold on; histogram(linmean,100)
title('Normalized & linearized for log reg')
legend('original means','complete data')
saveas(gcf,[filepath '/' name '/' name '_Histogram_linearized.tif'])
    
%% get  log reg coefficients
t = out.type(:,1);                            % mean for bootstrapping
b1 = out.b(t==1,:); b1 = mean(b1,2);          % Intensities together
b2 = out.b(t==2,:); b2 = mean(b2,2);          % Columns together
b3mat = out.b(t==3,:);                        % rows each separate
if any(t==4)
    b4 = out.b(t==4,:); b4 = mean(b4,2);          % Peptide counts
end
if any(t==5)
    b5 = out.b(t==4,:); b5 = mean(b5,2);          % Sequence coverage
end

% Initialize
dat_mis = nan(size(comp,1),size(comp,2),boot);
dat_full = nan(size(comp,1),size(comp,2),boot);

for b=1:boot  
    A = comp;     % Use complete matrix for missing pattern simu, and calc full same way to compare RMSE afterwards
    full = comp;  % A and full are saved in dat_mis and dat_full at end of loop
    b3 = reshape(b3mat,[size(b3mat,1)*size(b3mat,2),1]); % combine bootstraps
    b3(isnan(b3)) = []; 
    datr = dat; %(sum(isnan(dat),2)<size(dat,2),:);
    datr(isnan(b3),:) = [];
    while size(A,1)<length(b3)                       % Because by deleting all nans, matrix gets smaller
        r = randperm(length(b3),length(b3)-size(A,1));  % delete randomly, to keep pattern
        b3(r) = [];
        datr(r,:) = [];
    end

    %% Calculate probability for each cell index
    logit = nan(size(A,1),size(A,2));
    for i=1:size(A,1)
        for j=1:size(A,2)
            logit(i,j) = exp(b1*linmean(i,j)+b2(j)+b3(i)); 
        end
    end
    p = logit./(1+logit);                    % Probability
   
    %% assign nans
    r = rand(size(p,1),size(p,2));
    A(r<=p) = NaN;
    
    %% if complete column is nan
    if any(all(isnan(A)))
        A = comp;                       % try again
        r = rand(size(p,1),size(p,2));
        A(r<=p) = NaN;
        if any(all(isnan(A)))
            r = randsample(size(A,1),1);             % replace one value in column
            A(r,all(isnan(A))) = full(r,all(isnan(A)));
        end
    end
    
    sum(sum(isnan(dat)))/size(dat,1)/size(dat,2)
    sum(sum(isnan(A)))/size(A,1)/size(A,2)
    
    % Shift intensities of simulated pattern to original distribution, shift values of complete matrix the same to compare imputation
     full = (full-nanmean(A(:)))./nanstd(A(:));
     A = (A-nanmean(A(:)))./nanstd(A(:));
   full = full.*nanstd(dat(:))+nanmean(dat(:));
    A = A.*nanstd(dat(:))+nanmean(dat(:));
    
    
%     dat = get(O,'data_original');
%     dat_full = get(O,'data_full');
%     dat_mis = get(O,'data_mis');
%     figure
%     histogram(dat,100)
%     hold on
%     histogram(dat_full,100)
%     histogram(dat_mis,100)
%     
%     for i=1:5
%         A = dat_mis(:,:,i);
%         fullsave = (dat_full-nanmean(A(:)))./nanstd(A(:));
%         fullsave = fullsave.*nanstd(dat(:))+nanmean(dat(:));
%         A = (A-nanmean(A(:)))./nanstd(A(:));
%         A = A.*nanstd(dat(:))+nanmean(dat(:));
%         dat_mis(:,:,i) = A;
%         full(:,:,i) = fullsave;
%         figure
%         histogram(dat,100)
%         hold on
%         histogram(full,100)
%         histogram(dat_mis,100)
%     end
%     %save
%     O = set(O,'data_full',full,'Complete dataset without missing values');     % Remember full/complete dataset for comparing 'right' solutions with imputed afterwards
%     O = set(O,'data',dat_mis,'Missing values assigned/simulated.');
%     O = set(O,'data_mis',dat_mis,'data with assigned missing values');

    % Sort for plotting
    [~,idx] = sort(sum(isnan(A),2));
    Aplot = A(idx,:);
    
    %% Plot matrices original/simulated intensities/nans

    figure; set(gcf,'units','points','position',[10,10,600,300])
    h1 = subplot(1,3,1);
    nr = size(dat,1);
    nc = size(dat,2);
    pcolor([datplot nan(nr,1); nan(1,nc+1)]);
    shading flat;
    caxis manual
    caxis([min(nanmin(dat)) max(nanmax(dat))]);
    title({'original data O'})
    %ylabel('Proteins')
    xlabel('Samples')
    set(gca, 'ydir', 'reverse');
    
    h2 = subplot(1,3,2);
    nr = size(full,1);
    nc = size(full,2);
    pcolor([comp nan(nr,1); nan(1,nc+1)]);
    shading flat;
    caxis manual
    caxis([min(nanmin(dat)) max(nanmax(dat))]);
    c = colorbar('southoutside');
    c.Label.String = 'log_{2}(Intensity)';
    h2.Position = [h2.Position(1) h1.Position(2)+h1.Position(4)*(1-size(full,1)/size(dat,1)) h2.Position(3) h1.Position(4)/size(dat,1)*size(full,1)];
    title({'complete data C'})
    set(gca, 'ydir', 'reverse');
    ylim([0 size(full,1)])
    
    %linkaxes([h2,h1])

    subplot(1,3,3)
    nr = size(A,1);
    nc = size(A,2);
    pcolor([Aplot nan(nr,1); nan(1,nc+1)]);
    shading flat;
    set(gca, 'ydir', 'reverse');
    caxis manual
    caxis([min(nanmin(dat)) max(nanmax(dat))]);
    title({'pattern simulation S'})
    xlabel('Samples')
    %c = colorbar('southoutside');
    %c.Label.String = 'log_{2}(Intensity)';
    %ylim([0 size(Aplot,1)])
    yticks([0,round(size(Aplot,1)/4,1,'significant'),round(size(Aplot,1)/2,1,'significant'),round(size(Aplot,1)*0.9,2,'significant')])
    yticklabels([0,round(size(Aplot,1)/4,1,'significant'),round(size(Aplot,1)/2,1,'significant'),round(size(Aplot,1)*0.9,2,'significant')])

    saveas(gcf,[filepath '/' name '/' name '_SimulatedMissingPattern_' num2str(b) '.tif'])
     
    figure
    histogram(dat,100)
    hold on
    histogram(full,100)
    histogram(A,100)
    legend('original','complete','simulated')
    saveas(gcf,[filepath '/' name '/' name '_Histograms_' num2str(b) '.tif'])
     
    %% Histogram
%     figure
%     edges = nanmin(nanmin(dat)):0.1:nanmax(nanmax(dat));
%     histogram(dat,edges)
%     hold on
%     histogram(full,edges)
%     histogram(A,edges)
%     legend('O','F','S')
%     title('Intensity distribution')
%     saveas(gcf,[filepath '/' name '/' name '_Histograms_' num2str(b) '.tif'])
    
    %% Plot missing values per row column, compare original/simulated
    figure
    subplot(2,1,1)
    datrow = sort(sum(isnan(datr),2)/size(datr,2));
    plot(datrow,'LineWidth',1.5)
    hold on
    datsimrow = sort(sum(isnan(A),2)/size(A,2));
    plot(datsimrow,'LineWidth',1.5)
    xlabel('proteins')
    ylabel('missing values')
    h = legend('Original','Simulated','Location','northwest');
    hold off

    subplot(2,1,2)
    bar(sum(isnan(dat),1)/size(dat,1),'FaceAlpha',.7)
    hold on
    bar(sum(isnan(A),1)/size(A,1),'FaceAlpha',.7)
    xlabel('experiments')
    ylabel('Missing values')
    h = legend('Original','Simulated','Location','northwest');
    hold off

    % Save fig
    saveas(gcf,[filepath '/' name '/' name '_MissingRowCol_' num2str(b) '.tif'])
    
    dat_mis(:,:,b) = A;
    dat_full(:,:,b) = full;
end
%% Save class O
if size(dat_mis,2)>size(dat_mis,1)*2
    dat_mis = rot90(dat_mis);
end
O = set(O,'data_full',dat_full,'Complete dataset without missing values');     % Remember full/complete dataset for comparing 'right' solutions with imputed afterwards
O = set(O,'data',dat_mis,'Missing values assigned/simulated.');
O = set(O,'data_mis',dat_mis,'data with assigned missing values');
O = set(O,'mis_pat',isnan(dat_mis),'pattern of missing values');


