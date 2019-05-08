    
function PlotSimulatedPattern

global O

dat = get(O,'data_original');
dat_mis = get(O,'data_mis');

% Save directory
path = get(O,'path');
[filepath,name] = fileparts(path);
% Remove existing figures (Matlab does not overwrite images)
if exist([filepath '\' name '\' name '_SimulatedMissingPattern_1.tif'],'file')
    delete([filepath '\' name '\' name '_SimulatedMissingPattern*.tif']);
end

% Sort for plotting
[~,idx] = sort(sum(isnan(dat),2));
dat = dat(idx,:);
comp = dat(~any(isnan(dat),2),:);  % Complete matrix is used for pattern simu
fileID = fopen([filepath filesep name filesep '%Mis.txt'],'w');

for b=1:size(dat_mis,3)
    A = dat_mis(:,:,b);
    [~,idx] = sort(sum(isnan(A),2));
    A = A(idx,:);

    %% Plot matrices original/simulated intensities/nans

    figure; set(gcf,'units','points','position',[10,10,600,300])
    h1 = subplot(1,3,1);
    nr = size(dat,1);
    nc = size(dat,2);
    pcolor([dat nan(nr,1); nan(1,nc+1)]);
    shading flat;
    caxis manual
    caxis([min(nanmin(dat)) max(nanmax(dat))]);
    title({'original data O'})
    ylabel('Proteins')
    xlabel('Samples')
    set(gca, 'ydir', 'reverse');

    h2 = subplot(1,3,2);
    nr = size(comp,1);
    nc = size(comp,2);
    pcolor([comp nan(nr,1); nan(1,nc+1)]);
    shading flat;
    caxis manual
    caxis([min(nanmin(dat)) max(nanmax(dat))]);
    c = colorbar('southoutside');
    c.Label.String = 'log_{2}(Intensity)';
    h2.Position = [h2.Position(1) h1.Position(2)+h1.Position(4)*(1-size(comp,1)/size(dat,1)) h2.Position(3) h1.Position(4)/size(dat,1)*size(comp,1)];
    title({'complete data C'})
    set(gca, 'ydir', 'reverse');
    ylim([0 size(comp,1)])

    subplot(1,3,3)
    nr = size(A,1);
    nc = size(A,2);
    pcolor([A nan(nr,1); nan(1,nc+1)]);
    shading flat;
    set(gca, 'ydir', 'reverse');
    caxis manual
    caxis([min(nanmin(dat)) max(nanmax(dat))]);
    title({'pattern simulation S'})
    xlabel('Samples')
    %yticks([0,round(size(A,1)/4,1,'significant'),round(size(A,1)/2,1,'significant'),round(size(A,1)*0.9,2,'significant')])
    %yticklabels([0,round(size(A,1)/4,1,'significant'),round(size(A,1)/2,1,'significant'),round(size(A,1)*0.9,2,'significant')])

    saveas(gcf,[filepath '/' name '/' name '_SimulatedMissingPattern_' num2str(b) '.tif'])

    misdat = sum(sum(isnan(dat)))/size(dat,1)/size(dat,2)
    misA = sum(sum(isnan(A)))/size(A,1)/size(A,2)
    fprintf(fileID,'%i\t%i\n',misdat,misA);
    
end
fclose(fileID);