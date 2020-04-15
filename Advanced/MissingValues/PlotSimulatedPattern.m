    
function PlotSimulatedPattern(O,path)

dat = get(O,'data_original');
comp = get(O,'data_complete');
dat_mis = get(O,'data_mis');

% Save directory
if ~exist('path','var')
    path = get(O,'path');
end
[filepath,name] = fileparts(path);
if isempty(filepath)
    filepath = '.';
end 
if ~exist([filepath filesep name],'dir')
    mkdir(filepath,name)
end
% Remove existing figures (Matlab does not overwrite images)
if exist([filepath '\' name '\' name '_SimulatedMissingPattern_AllX_1.png'],'file')
    delete([filepath '\' name '\' name '_SimulatedMissingPattern_AllX*.png']);
end

% Sort for plotting
[~,idx] = sort(sum(dat,2),'descend','MissingPlacement','last');
dat = dat(idx,:);
[~,idx2] = sort(sum(isnan(dat),2));
dat = dat(idx2,:);
dat = dat(~all(isnan(dat),2),:);
[~,idx] = sort(sum(comp,2),'descend','MissingPlacement','last');
comp = comp(idx,:);
[~,idx2] = sort(sum(isnan(comp),2));
comp = comp(idx2,:);
comp = comp(~all(isnan(comp),2),:);

fileID = fopen([filepath filesep name filesep '%Mis.txt'],'w');
fprintf(fileID,'%s\t%s\n','MV in original','MV in pattern');

for b=1%:size(dat_mis,3)
    A = dat_mis(:,:,b);
    [~,idx] = sort(sum(A,2),'descend','MissingPlacement','last');
    A = A(idx,:);
    [~,idx] = sort(sum(isnan(A),2));
    A = A(idx,:);
    A = A(~all(isnan(A),2),:);
    %% Plot matrices original/simulated intensities/nans

    figure; set(gcf,'units','points','position',[0,0,1200,600])
    h1 = subplot(1,3,1);
    nr = size(dat,1);
    nc = size(dat,2);
    pcolor([dat nan(nr,1); nan(1,nc+1)]);
    shading flat;
    caxis manual
    caxis([min(nanmin(dat)) max(nanmax(dat))]);
    title({'original data O'})
    ylabel('Proteins (sorted)')
    xlabel('Samples')
    set(gca, 'ydir', 'reverse');
    set(gca,'FontSize', 20)
    c = colorbar;
    c.Label.String = 'log_2(LFQIntensity)';
    %c.Ticks = [];
    
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
    title({'Known data K'})
    set(gca, 'ydir', 'reverse');
    ylim([0 size(comp,1)])
    set(gca,'FontSize', 20)
    
    h3 = subplot(1,3,3);
    nr = size(A,1);
    nc = size(A,2);
    pcolor([A nan(nr,1); nan(1,nc+1)]);
    shading flat;
    set(gca, 'ydir', 'reverse');
    caxis manual
    caxis([min(nanmin(dat)) max(nanmax(dat))]);
    h3.Position = [h3.Position(1) h1.Position(2) h3.Position(3) h1.Position(4)];
    %h3.Position = [h3.Position(1) h2.Position(2) h3.Position(3) h2.Position(4)];
    title({'pattern simulation S'})
    xlabel('Samples')
    ylim([0 size(comp,1)])
    %yticks([0,round(size(A,1)/4,1,'significant'),round(size(A,1)/2,1,'significant'),round(size(A,1)*0.9,2,'significant')])
    %yticklabels([0,round(size(A,1)/4,1,'significant'),round(size(A,1)/2,1,'significant'),round(size(A,1)*0.9,2,'significant')])
    set(gca,'FontSize', 20)
    print(gcf,[filepath filesep name filesep strrep(name,'.','') '_SimulatedMissingPattern_' num2str(b)],'-dpng');%,'-r1000')

    misori = sum(sum(isnan(dat)))/size(dat,1)/size(dat,2)
    mispat = sum(sum(isnan(A)))/size(A,1)/size(A,2)
    fprintf(fileID,'%i\t%i\n',misori,mispat);
    
end
fclose(fileID);