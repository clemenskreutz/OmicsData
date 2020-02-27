
file = dir('Data/PaperSome1000*');
file = natsort({file.name});
% file(contains(file,'MNAR70') | contains(file,'MNAR80') | contains(file,'MNAR90')) = [];
% file = file(7:end);

MV = 5:5:50;
MNAR = 100:-10:0;

idx = nan(length(MV)*length(MNAR),1);
idx2 = idx; R = idx; R2 = idx;
mr = cell(length(file),1); mf = cell(length(file),1);
for i=1:length(file)
     folder = file{i};
    % Get order of direct fullutation
    if exist(['Data' filesep folder filesep 'O_full_1.mat'],'file')
        load(['Data' filesep folder filesep 'O_full_1.mat']); 
        if ~isfield(O,'RankTable',true)
            if ~isfield(O,'Table')
                O = GetTable(O);
            end
            O = GetRankTable(O);
            saveO(O,[],'O_full_1')
        end
        mfull = get(O,'RankMethod');
        Tfull = get(O,'RankTable');
    else
        mr(i) = {'NaN'};
        mf(i) = {'NaN'};
        continue
    end

    % Get simu RMSE
    if exist(['Data' filesep folder filesep 'O_1.mat'],'file')
        load(['Data' filesep folder filesep 'O_1.mat']); 
        if ~isfield(O,'RankTable',true)
            O = GetTable(O);
            O = GetRankTable(O);
            saveO(O,[],'O_1')
        end
        m = get(O,'RankMethod');
        T = get(O,'RankTable');  
    else
        m = 'nan';
        T = nan;
    end
      
    try     
        idx(i) = find(strcmp(mfull,m(1)));
        R(i) =  (Tfull(2,idx(i)) - Tfull(2,1)) ./ Tfull(2,1)*100;
        mr(i) = m(1);
        mf(i) = mfull(1);
    catch 
        mr(i) = {'not working'};
        mf(i) = {'not working'};
    end
end

idxs = flipud(reshape(idx,length(MNAR),length(MV)));
RMSE = flipud(round(reshape(R,length(MNAR),length(MV))));
[mrc,mrg] = grp2idx(mr);
[mfc,mfg] = grp2idx(mf);
mrs = flipud(reshape(mrc,length(MNAR),length(MV)));
mfs = flipud(reshape(mfc,length(MNAR),length(MV)));

% Change order so pcas are blue
% mfscopy = mfs; 
% mfs(mfscopy==7) = 1;
% mfs(mfscopy==8) = 2;
% mfs(mfscopy==9) = 3;
% mfs(mfscopy==1) = 4;
% mfs(mfscopy==3) = 5;
% 
% mfs(mfscopy==6) = 10;
% mfs(mfscopy==5) = 9;
% mfs(mfscopy==10) = 8;
% mfs(mfscopy==2) = 7;
% mfs(mfscopy==4) = 6;
% 
% mfgcopy = mfg;
% mfg(1) = mfgcopy(7);
% mfg(2) = mfgcopy(8);
% mfg(3) = mfgcopy(9);
% mfg(4) = mfgcopy(1);
% mfg(5) = mfgcopy(3);
% 
% mfg(10) = mfgcopy(6);
% mfg(9) = mfgcopy(5);
% mfg(8) = mfgcopy(10);
% mfg(7) = mfgcopy(2);
% mfg(6) = mfgcopy(4);

set(0,'DefaultFigureVisible','on')
figure; set(gcf,'units','points','position',[0,0,800,430])
imagesc(mfs);
scale = 0.88;
pos = get(gca, 'Position');
pos(3) = scale*pos(3);
set(gca, 'Position', pos)
ylabel('MNAR [%]')   
yticks(1:length(MNAR))
yticklabels(MNAR)
for r1=1:length(MNAR)
    for r2 = 1:length(MV)
        if ~(isnan(RMSE(r1,r2)) && idxs(r1,r2) ==1)
           if isnan(RMSE(r1,r2))
           elseif RMSE(r1,r2)>=10 %&& idxs(r1,r2)>=5
                text(r2,r1+0.2,[num2str(RMSE(r1,r2)) '%'],'Color','r','HorizontalAlignment','center','FontWeight','bold','FontSize',12);
                text(r2,r1-0.2,num2str(idxs(r1,r2)),'Color','r','HorizontalAlignment','center','FontWeight','bold','FontSize',12);     
           else
                text(r2,r1+0.2,[num2str(RMSE(r1,r2)) '%'],'Color','k','HorizontalAlignment','center','FontWeight','bold','FontSize',12);
                text(r2,r1-0.2,num2str(idxs(r1,r2)),'HorizontalAlignment','center','FontSize',12,'FontWeight','bold');     
           end
        end
    end
end
cmap = jet(length(mfg)+2);
cmap(1,:) = [];
cmap(end-1,:) = [];
cmap(4,:) = [0 0.9 1];
cmap(5,:) = [0 1 1];
cmap(end,:) = [1 1 1];
colormap(cmap)
hp4 = get(gca,'Position');

colorbar('YTick',1:length(mfg),'YTickLabel',mfg,'Position', [hp4(1)+hp4(3)+0.02  hp4(2)  0.02  hp4(4)*0.8],'TickLabelInterpreter','none','FontSize',17);
annotation('textbox',[0.85 .72 .05 .2],'String',{'Rank','\DeltaRMSE'},'FitBoxToText','on','HorizontalAlignment','center','BackgroundColor','w','FontSize',12)
xlabel('MV [%]')
xticks(1:length(MV))
xticklabels(MV)
set(gca,'FontSize',12)
print(['Simu_' folder(1:13)],'-dpng','-r1000');

figure
subplot(1,2,1)
histogram(mrc)
xticks(1:length(mrg))
xticklabels(mrg)
title('DIMA')
subplot(1,2,2)
histogram(mfs)
xticks(1:length(mfg))
xticklabels(mfg)
title('Direct imputation')

