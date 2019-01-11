function assignmissing

global O

if ~exist('O','var')
    error('MissingValues/assignmissing.m requires class O as global variable.')
end

A = get(O,'data');                                                      % Dataset without missing values
dat = get(O,'data_original');                                           % Original with missing values
out = get(O,'out');                                                     % Logreg coefficients
try
    boot = get(O,'boot');
catch
    boot = 1;
end
% n_mis = length(find(isnan(dat)))/size(dat,1)/size(dat,2);             % how many missing values in original dataset ? 
dat_mis = nan(size(A,1),size(A,2),boot);
for b=1:boot
    A = get(O,'data');   
    %% Shift intensities of full dataset to N~(0,1)
    m = nanmean(A,2);
    A = (A-nanmean(m))./nanstd(m);

    %% get coeff for each cell index
    t = out.type(:,1);                            % In the separation of datasets:
    b1 = out.b(t==1,:); b1 = mean(b1,2);          % Intensities together
    b2 = out.b(t==2,:); b2 = mean(b2,2);          % Columns together
    b3mat = out.b(t==3,:);                           % rows each separate
    b3 = reshape(b3mat,[size(b3mat,1)*size(b3mat,2),1]); % combine bootstraps
    b3(isnan(b3)) = []; 
    datr = dat(sum(isnan(dat),2)<size(dat,2),:);
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
            logit(i,j) = exp(b1*A(i,j)+b2(j)+b3(i));
        end
    end
    p = logit./(1+logit);                    % Probability

    %% Shift intensities of full dataset to original distribution
     m = nanmean(dat,2);
     A = A.*nanstd(m)+nanmean(m);
     full=A;
    O = set(O,'data_full',full,'Complete dataset without missing values');     % Remember full/complete dataset for comparing 'right' solutions with imputed afterwards

    %% assign nans
    r = rand(size(p,1),size(p,2));
    A(r<=p) = NaN;
    
%     % put rows with just NaNs in last row
%     if get(O,'deleteemptyrows')
%         idxnan = find(all(isnan(A),2));
%         if ~isempty(idxnan) && length(idxnan)<size(A,1)
%             warning([num2str(length(idxnan)) ' rows containing all NaNs, shifted to last rows of matrix.'])
%             A(idxnan,:) = [];
%             A(end+1:end+length(idxnan),:) = nan(length(idxnan),size(A,2));
%         end
%     end

    %% Shift intensities of simulated pattern dataset to original distribution
     m = nanmean(A,2);
     A = (A-nanmean(m))./nanstd(m);
     m = nanmean(dat,2);
     A = A.*nanstd(m)+nanmean(m);

    sum(sum(isnan(A)))/size(A,1)/size(A,2)
    sum(sum(isnan(dat)))/size(dat,1)/size(dat,2)
    %% Plot matrices original/simulated intensities/nans

    % Sort for plotting
    [~,idx] = sort(sum(isnan(dat),2));
    datplot = dat(idx,:);
    fullplot = datplot(find(~any(isnan(datplot),2)),:);
    [~,idx] = sort(sum(isnan(A),2));
    Aplot = A(idx,:);
    
    figure; set(gcf,'units','points','position',[10,10,600,300])
    subplot(1,3,1)
    nr = size(dat,1);
    nc = size(dat,2);
    pcolor([datplot nan(nr,1); nan(1,nc+1)]);
    shading flat;
    set(gca, 'ydir', 'reverse');
    caxis manual
    caxis([min(nanmin(dat)) max(nanmax(dat))]);
    title({'Original data O'})
    %ylabel('Proteins')
    xlabel('Experiments')

    subplot(1,3,2)
    nr = size(full,1);
    nc = size(full,2);
    pcolor([fullplot nan(nr,1); nan(1,nc+1)]);
    shading flat;
    set(gca, 'ydir', 'reverse');
    caxis manual
    caxis([min(nanmin(dat)) max(nanmax(dat))]);
    title({'Fully known data F'})
    c = colorbar('southoutside');
    c.Label.String = 'log_{10}(LFQ Intensity)';

    subplot(1,3,3)
    nr = size(A,1);
    nc = size(A,2);
    pcolor([Aplot nan(nr,1); nan(1,nc+1)]);
    shading flat;
    set(gca, 'ydir', 'reverse');
    caxis manual
    caxis([min(nanmin(dat)) max(nanmax(dat))]);
    title({'Simulated missing pattern S'})
    c = colorbar('southoutside');
    c.Label.String = 'log_{10}(LFQ Intensity)';

    % Save fig
    path = get(O,'path');
    [filepath,name] = fileparts(path);
    mkdir(filepath, name)
    saveas(gcf,[filepath '/' name '/' name '_SimulatedMissingPattern_' num2str(b) '.png'])
    
    %% Histogram
    figure
    edges = nanmin(nanmin(dat)):0.1:nanmax(nanmax(dat));
    histogram(dat,edges)
    hold on
    histogram(full,edges)
    histogram(A,edges)
    legend('O','F','S')
    title('Intensity distribution')
    saveas(gcf,[filepath '/' name '/' name '_Histograms_' num2str(b) '.png'])
    
    %% Plot missing values per row column, compare original/simulated
    %% Remove rows randomly, so original and assigned matrix size matches
    % dat = dat;
    % if size(dat,1)>size(A,1)
    %     r = randperm(size(dat,1),size(dat,1)-size(A,1));  % delete randomly, to keep pattern
    %     dat(r,:) = [];
    % end
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
    %suptitle('Distribution of missing values')
    hold off

    % Save fig
    saveas(gcf,[filepath '/' name '/' name '_MissingRowCol_' num2str(b) '.png'])
    
    dat_mis(:,:,b) = A;
end
%% Save class O
O = set(O,'data',dat_mis,'Missing values assigned/simulated.');
O = set(O,'data_mis',dat_mis,'data with assigned missing values');
O = set(O,'mis_pat',isnan(dat_mis),'pattern of missing values');
save([filepath '/' name '/AssignedMissing.mat'],'O')

%% Write xls
%data_full = get(O,'data_full');

dlmwrite([filepath '/' name '/AssignedMissing.txt'],dat_mis);

%xlswrite([filepath '/' name '/AssignedMissing.xls'],A);
%xlswrite([filepath '/' name '/CompleteData.xls'],data_full);


