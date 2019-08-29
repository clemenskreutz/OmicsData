
file = dir('Data/SimuPep4000*');
file(7) = [];
file(end) = [];

MV = 5:5:50;
MNAR = 0:10:100;

idx = nan(length(MV)*length(MNAR),1);
idx2 = idx; R = idx; R2 = idx;
mr = cell(length(MV)*length(MNAR),1); mf = cell(length(MV)*length(MNAR),1);
for i=1:length(file)
    folder = file(i).name;
    
    % Get order of direct imputation
    if exist(['Data' filesep folder '/O_full.mat'],'file')
        load(['Data' filesep folder '/O_full.mat']); 
        if ~isfield(O,'RankTable')
            if ~isfield(O,'Table')
                O = imputation_analysis(O);
            end
            O = GetRankTable(O);
            saveO(O,[],'O_full')
        end
        mfull = get(O,'RankMethod');
        Tfull = get(O,'RankTable');
    else
        mr(i) = {'NaN'};
        mf(i) = {'NaN'};
        continue
    end

    % Get simu RMSE
    load(['Data' filesep folder '/O.mat']); 
    if ~isfield(O,'RankTable')
        O = imputation_analysis(O);
        O = GetRankTable(O);
        saveO(O)
    end
    m = get(O,'RankMethod');
    T = get(O,'RankTable');        
    
    try     
        idx(i) = find(strcmp(mfull,m(1)));
        R(i) =  (Tfull(2,idx(i)) - Tfull(2,1)) ./ Tfull(2,1)*100;
        mr(i) = m(1);
        mf(i) = mfull(1);
    end
    try    
        idx2(i) = find(strcmp(m,mfull(1)));
        R2(i) =  (nanmean(T(2,idx2(i)+1,:),3) - nanmean(T(2,1,:),3)) ./ nanmean(T(2,1,:),3)*100;
    end
end

idxs = flipud(reshape(idx,length(MNAR),length(MV)));
idx2s = flipud(reshape(idx2,length(MNAR),length(MV)));
RMSE = flipud(round(reshape(R,length(MNAR),length(MV))));
RMSE2 = flipud(round(reshape(R2,length(MNAR),length(MV))));
[mrc,mrg] = grp2idx(mr);
[mfc,mfg] = grp2idx(mf);
mrs = flipud(reshape(mrc,length(MNAR),length(MV)));
mfs = flipud(reshape(mfc,length(MNAR),length(MV)));

% Change order so pcas are blue
% mfscopy = mfs;
% mfs(mfscopy==7) = 1;
% mfs(mfscopy==6) = 3;
% mfs(mfscopy==1) = 5;
% mfs(mfscopy==5) = 7;
% mfs(mfscopy==3) = 6;
% mfgcopy = mfg;
% mfg(1) = mfgcopy(7);
% mfg(3) = mfgcopy(6);
% mfg(5) = mfgcopy(1);
% mfg(7) = mfgcopy(5);
% mfg(6) = mfgcopy(3);

figure; set(gcf,'units','points','position',[0,0,800,430])
imagesc(mfs);
scale = 0.88;
pos = get(gca, 'Position');
pos(3) = scale*pos(3);
set(gca, 'Position', pos)
ylabel('MNAR [%]')   
yticks(1:length(MNAR))
yticklabels(fliplr(MNAR) )
for r1=1:length(MNAR)
    for r2 = 1:length(MV)
        if ~(isnan(RMSE(r1,r2)) && idxs(r1,r2) ==1)
           if isnan(RMSE(r1,r2))
                text(r2,r1+0.2,'NaN','Color','k','HorizontalAlignment','center','FontSize',12);
                text(r2,r1-0.2,num2str(idxs(r1,r2)),'Color','k','HorizontalAlignment','center','FontSize',12);     
            elseif RMSE(r1,r2)<=10 && idxs(r1,r2)<=5
                text(r2,r1+0.2,[num2str(RMSE(r1,r2)) '%'],'Color','k','HorizontalAlignment','center','FontWeight','bold','FontSize',12); % grün [0 0.55 0]
                text(r2,r1-0.2,num2str(idxs(r1,r2)),'Color','k','HorizontalAlignment','center','FontSize',12,'FontWeight','bold');     
           elseif RMSE(r1,r2)>=10 && idxs(r1,r2)>=5
                text(r2,r1+0.2,[num2str(RMSE(r1,r2)) '%'],'Color','r','HorizontalAlignment','center','FontWeight','bold','FontSize',12);
                text(r2,r1-0.2,num2str(idxs(r1,r2)),'Color','r','HorizontalAlignment','center','FontWeight','bold','FontSize',12);     
           else
                text(r2,r1+0.2,[num2str(RMSE(r1,r2)) '%'],'Color','k','HorizontalAlignment','center','FontWeight','bold','FontSize',12);
                text(r2,r1-0.2,num2str(idxs(r1,r2)),'HorizontalAlignment','center','FontSize',12,'FontWeight','bold');     
            end
        end
    end
end
%cmap = [ 1 0.8 0; 1 1 0; 1 1  0.2; 0.2 1 0.3; 0 1 1; 0 0.9 1; 0 0.8 1; 0 0.7 1; 1 1 1];
%colormap(cmap)
cmap = jet(length(mfg));
%cmap(end-1,:) = [0.4 0.4 1];
cmap(end,:) = [1 1 1];
colormap(cmap)
hp4 = get(gca,'Position');

colorbar('YTick',1:length(mfg),'YTickLabel',mfg,'Position', [hp4(1)+hp4(3)+0.02  hp4(2)  0.02  hp4(4)*0.8],'TickLabelInterpreter','none','FontSize',17);
%caxis([1 length(mfg)]);
annotation('textbox',[0.85 .72 .05 .2],'String',{'Rank','\DeltaRMSE'},'FitBoxToText','on','HorizontalAlignment','center','BackgroundColor','w','FontSize',12)
xlabel('MV [%]')
xticks(1:length(MV))
xticklabels(MV)
set(gca,'FontSize',12)
print(['AlgoOne_' folder(1:11)],'-dpng','-r100');

