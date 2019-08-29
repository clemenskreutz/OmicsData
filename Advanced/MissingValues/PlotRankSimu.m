
file = dir('Data/SimuLazar1001*');
file(floor(length(file)/30)*30:end) = [];

MV = 2:5:52;
MNAR = 0:10:60;

RSR = nan(length(MV)*length(MNAR),5);
RSRfile = nan(30,5);
c=0;
for i=1:30:length(file)
    file(i+1).name
    for j=1:30
        folder = file(i+j).name;
        load(['Data' filesep folder filesep 'O.mat']); 
        T = get(O,'Table');   
%         if isempty(T)
%             if isfield(O,'data_imput')
%                O = GetTable(O); 
%                T = get(O,'Table');
%             else
%                 continue
%             end
%         end
        RSRfile(j,:) = T(7,2:size(RSR,2)+1);
    end
    c=c+1;
    RSR(c,:) = nanmean(RSRfile);
end

figure; set(gcf,'units','points','position',[0,0,800,430])
m = get(O,'method_imput');
for j=1:size(RSR,2)
    subplot(2,3,j)
    imagesc(flipud(reshape(RSR(:,j),length(MNAR),length(MV))))
    colormap(jet)
    xlabel('MV')
    xticks(1:length(MV))
    xticklabels(MV)
    ylabel('MNAR')
    yticks(1:length(MNAR))
    yticklabels(fliplr(MNAR))
    %title(m{j})
    set(gca,'FontSize',12)
end
colorbar
print('Lazar','-dpng','-r100');
