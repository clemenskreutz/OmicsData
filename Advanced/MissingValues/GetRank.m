
file = dir('Data/OBrien200M*');
file = natsort({file.name});
file(contains(file,'MNAR95')) = [];
% file(contains(file,'MNAR70') | contains(file,'MNAR80') | contains(file,'MNAR90')) = [];
% file = file(7:end);

MV = 20:5:50;
MNAR = 100%:-10:0;

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
            if ~isfield(O,'Table')
                O = GetTable(O);
            end
            O = GetRankTable(O);
            saveO(O,[],'O_1')
        end
        m = get(O,'RankMethod');
        T = get(O,'RankTable');  
    else
        m = {'nan'};
        T = nan;
    end
      
    try     
%         data = get(O,'data_original');
%         NR(i) = MNARtest(data);
%         if NR(i)>99.9
%             m = {'MinDet'};
%         end
        mr(i) = m(1);
        mf(i) = mfull(1);
        idx(i) = find(strcmp(mfull,m(1)));
        R(i) =  (Tfull(2,idx(i)) - Tfull(2,1)) ./ Tfull(2,1)*100;

    catch 
        idx(i) = nan;
        R(i) = nan;
    end
end

idxs = flipud(reshape(idx,length(MNAR),length(MV)));
RMSE = flipud(round(reshape(R,length(MNAR),length(MV))));
[mrc,mrg] = grp2idx(mr);
[mfc,mfg] = grp2idx(mf);
mrs = flipud(reshape(mrc,length(MNAR),length(MV)));
mfs = flipud(reshape(mfc,length(MNAR),length(MV)));
%NRs = flipud(reshape(NR,length(MNAR),length(MV)));

set(0,'DefaultFigureVisible','on')
figure; set(gcf,'units','points','position',[0,0,800,430])
imagesc(RMSE);
scale = 0.88;
pos = get(gca, 'Position');
pos(3) = scale*pos(3);
set(gca, 'Position', pos)
ylabel('MNAR [%]')   
yticks(1:length(MNAR))
yticklabels(MNAR)
for r1=1:length(MNAR)
    for r2 = 1:length(MV)
        if RMSE(r1,r2)>10 || isnan(RMSE(r1,r2))
            c = 'r';
        else
            c='k';
        end
        text(r2,r1-0.3,num2str(round(idxs(r1,r2))),'Color',c,'HorizontalAlignment','center','FontSize',12,'FontWeight','bold');     
        text(r2,r1-0.1,num2str(round(RMSE(r1,r2))),'Color',c,'HorizontalAlignment','center','FontSize',12,'FontWeight','bold');     
        text(r2,r1+0.1,mfg(mfs(r1,r2)),'Color',c,'HorizontalAlignment','center','FontWeight','bold','FontSize',12);
        text(r2,r1+0.3,mrg(mrs(r1,r2)),'Color',c,'HorizontalAlignment','center','FontSize',12,'FontWeight','bold');     
    end
end
c = colorbar;
c.Label.String = '\DeltaRMSE';
hp4 = get(gca,'Position');

% colorbar('YTick',1:length(mfg),'YTickLabel',mfg,'Position', [hp4(1)+hp4(3)+0.02  hp4(2)  0.02  hp4(4)*0.8],'TickLabelInterpreter','none','FontSize',17);
% annotation('textbox',[0.85 .72 .05 .2],'String',{'MNAR','\DeltaRMSE'},'FitBoxToText','on','HorizontalAlignment','center','BackgroundColor','w','FontSize',12)
xlabel('MV [%]')
xticks(1:length(MV))
xticklabels(MV)
set(gca,'FontSize',12)
print(['Simu_' folder(1:13)],'-dpng');%,'-r1000');
% 
% figure
% subplot(1,2,1)
% histogram(mrc)
% xticks(1:length(mrg))
% xticklabels(mrg)
% title('DIMA')
% subplot(1,2,2)
% histogram(mfs)
% xticks(1:length(mfg))
% xticklabels(mfg)
% title('Direct imputation')

