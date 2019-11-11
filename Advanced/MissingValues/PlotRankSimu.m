
file = dir('Data/SimuLazar1000*');
file = natsort({file.name});
MV = 2:5:52;
MNAR = 0:10:100;
n = 7; % RSR = 7, RMSE = 6
len = 30;

RowNames = {'mean','std','min','max','MeanError','RMSE','RSR','F','Acc','PCC','time'};
for i=1:length(file)
    file{i}
    for j=1:len
        load(['Data' filesep file{i} filesep 'O_' num2str(j) '.mat']);
        T = get(O,'Table');   
        T = T(:,2:end);
        if j==1
            Tfile = T(n,:);
        else
            Tfile(j,T.Properties.VariableNames) = T(n,:);
        end
        if j==len
            Tfile = array2table(nanmedian(Tfile{:,:}),'VariableNames',Tfile.Properties.VariableNames);
        end
    end
    if i==1
        TRSR = Tfile;
    else
        TRSR(i,Tfile.Properties.VariableNames) = Tfile;
    end
end

figure; set(gcf,'units','points','position',[0,0,800,430])
for j=1:size(TRSR,2)
    subplot(2,3,j)
    pcolor([reshape(TRSR{:,j},length(MNAR),length(MV)) nan(length(MNAR),1); nan(1,length(MV)+1)]);
    shading flat;
    colormap(jet)
    %caxis manual
    %caxis([min(nanmin(RSR)) max(nanmax(RSR))]);
    xlabel('MV')
    xticks(1:length(MV))
    xticklabels(MV)
    ylabel('MNAR')
    yticks(1:length(MNAR))
    yticklabels(MNAR)
    title(TRSR.Properties.VariableNames{j})
    set(gca,'FontSize',12)
end
colorbar
print('Lazar','-dpng','-r100');
