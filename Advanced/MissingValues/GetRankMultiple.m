
name = 'OBrien500*';
%name = 'Lazar500*';

file = dir(['Data' filesep name]);
file = natsort({file.name});

MV = 5:5:50;
MNAR = 100:-10:00;
    
idx = nan(length(MV)*length(MNAR),1);
R = idx; R2 = idx; NR = idx; r = idx;
mr = cell(length(file),1); mf = cell(length(file),1);
mfulln = cell(1,30); mn = cell(1,30);
for i=1:length(file)
     folder = dir(['Data' filesep file{i} filesep 'O_full_*.mat']);
     %fol(i) = length(folder);
     if length(folder)>size(mfulln,1)
         mfulln = cell(length(folder),30); mn = cell(length(folder),30);
     end
     mfulln(1:size(mfulln,1),1:size(mfulln,2)) = {'NaN'};
     mn(1:size(mn,1),1:size(mn,2)) = {'NaN'};
     Tfulln = nan(size(mfulln,1),size(mfulln,2));
     for ii=1:length(folder)
        % direct imputation
        if exist([folder(ii).folder filesep folder(ii).name],'file')
            load([folder(ii).folder filesep folder(ii).name]); 
            if ~isfield(O,'RankTable',true)
                O = GetRankTable(O);
                saveO(O,[],folder(ii).name(1:end-4))
            end
            mget = get(O,'RankMethod');
            mfulln(ii,1:length(mget)) = mget;
            Tget = get(O,'RankTable');
            Tfulln(ii,1:size(Tget,2)) = Tget(2,:);
        else
            [folder(ii).folder filesep folder(ii).name ' does not exist. Check it.']
            mfulln(ii,1:size(mfulln,2)) = {'NaN'};
        end
        % DIMA imputation
        if exist([folder(ii).folder filesep strrep(folder(ii).name,'_full','')],'file')
            load([folder(ii).folder filesep strrep(folder(ii).name,'_full','')]); 
            if ~isfield(O,'RankTable',true)
                O = GetRankTable(O);
                saveO(O,[],strrep(folder(ii).name(1:end-4),'_full',''))
            end
            mget = get(O,'RankMethod'); 
            mn(ii,1:length(mget)) = mget;
        else
            mn(ii,1:size(mn,2)) = {'NaN'};
        end       
     end
    % Rank repetitions % Mean of direct imputation
    unimfull = unique(mfulln);
    T = nan(length(unimfull),1); ranking = nan(length(unimfull),1); Tget = nan(size(mfulln,1),1);
    for r=1:length(unimfull)
        if ~strcmp(unimfull{r},'NaN')
            [row,rankn] = find(strcmp(mfulln,unimfull{r})); % get ranks of each method to get RMSE
            if length(rankn)<size(mfulln,1)
                rankn = [rankn; 30*ones(size(mfulln,1)-length(rankn),1)];   % if method failed for a replicate, add rank 30
                row = [row; setdiff(1:size(mfulln,1),row)'];
            end
            ranking(r) = nanmean(rankn); % sum of rank, for sort methods and T later
            for rr = 1:length(rankn)
                Tget(rr) = Tfulln(row(rr),rankn(rr));
            end
            T(r) = nanmean(Tget);
        else
            T(r) = nan;
            ranking(r) = nan;
        end
    end
    [ranking,id] = sort(ranking);
    mfull = unimfull(id);
    T = T(id);
    % Rank repetition for DIMA
    unim = unique(mn);
    rankd = nan(length(unim),1);
    for r=1:length(unim)
        [~,rankn] = find(strcmp(mn,unim{r}));
        if length(rankn)<size(mfulln,1)
            rankn = [rankn; 30*ones(size(mfulln,1)-length(rankn),1)];   % if method failed for a replicate, add rank 30
        end
        rankd(r) = nanmean(rankn);
    end
    [~,id] = sort(rankd);
    m = unim(id);
     
    %% Get numbers for heatmap
    try     
%         data = get(O,'data_original');
%         NR(i) = MNARtest(data);
%         for j=1:length(algo)
%             if any(strcmp(mfull,algo{j}))
%                 Ra(i,j) = (T(strcmp(mfull,algo{j})) - T(1)) ./ T(1)*100;
%                 idxa(i,j) = find(strcmp(mfull,algo{j}));
%             end
%         end
        if any(strcmp(mfull,m(1)))
            idx(i) = find(strcmp(mfull,m(1)));
            rank(i) = ranking(idx(i));
            R(i) =  (T(idx(i)) - T(1)) ./ T(1)*100;
        else
            idx(i) = 0;
            rank(i) = nan;
            R(i) = nan;
        end
        mr(i) = m(1);
        mf(i) = mfull(1);
    catch 
        mr(i) = {'not working'};
        mf(i) = {'not working'};
    end
end

%% Simu Figure

idxs = flipud(reshape(rank,length(MNAR),length(MV)));
RMSE = flipud(round(reshape(R,length(MNAR),length(MV))));
[mrc,mrg] = grp2idx(mr);
[mfc,mfg] = grp2idx(mf);
mrs = flipud(reshape(mrc,length(MNAR),length(MV)));
mfs = flipud(reshape(mfc,length(MNAR),length(MV)));
% NRs = flipud(reshape(NR,length(MNAR),length(MV)));
% fols = flipud(reshape(fol,length(MNAR),length(MV)));


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
        text(r2,r1-0.3,num2str(round(idxs(r1,r2),1)),'Color',c,'HorizontalAlignment','center','FontSize',12,'FontWeight','bold');     
        text(r2,r1-0.1,num2str(round(RMSE(r1,r2),1)),'Color',c,'HorizontalAlignment','center','FontSize',12,'FontWeight','bold');     
        text(r2,r1+0.1,mfg(mfs(r1,r2)),'Color',c,'HorizontalAlignment','center','FontWeight','bold','FontSize',12);
        text(r2,r1+0.3,mrg(mrs(r1,r2)),'Color',c,'HorizontalAlignment','center','FontSize',12,'FontWeight','bold');     
    end
end
c = colorbar;
c.Label.String = '\DeltaRMSE';
xlabel('MV [%]')
xticks(1:length(MV))
xticklabels(MV)
set(gca,'FontSize',12)
print(['Simu_' strrep(name,'*','')],'-dpng');%,'-r1000');


%% Algo Figures
% figure; set(gcf,'units','points','position',[0,0,800,430])
% for j=1:size(Ra,2)
%     subplot(2,3,j)
%     RMSEa = flipud(round(reshape(Ra(:,j),length(MNAR),length(MV))));
%     ida = flipud(round(reshape(idxa(:,j),length(MNAR),length(MV))));
%     mbest = flipud(reshape(mr,length(MNAR),length(MV)));
%     imagesc(RMSE);
%     for r1=1:length(MNAR)
%         for r2 = 1:length(MV)
%             if ida(r1,r2)==1
%                 if ida(r1,r2)==1
%                     c = 'g';
%                 elseif strcmp(mbest{r1,r2},algo{j}) 
%                     c = 'y';
%                 else
%                     c = 'b';
%                 end
%             else
%                 c='k';
%             end
%             text(r2,r1+0.2,num2str(round(RMSEa(r1,r2))),'Color',c,'HorizontalAlignment','center','FontWeight','bold','FontSize',12);
%             text(r2,r1-0.2,num2str(ida(r1,r2)),'Color',c,'HorizontalAlignment','center','FontSize',12,'FontWeight','bold');     
%         end
%      end
% %     c = colorbar;
% %     c.Label.String = '\DeltaRMSE';
% %     annotation('textbox',[0.85 .72 .05 .2],'String',{'Rank','\DeltaRMSE'},'FitBoxToText','on','HorizontalAlignment','center','BackgroundColor','w','FontSize',12)
%     xlabel('MV [%]')
%     xticks(1:length(MV))
%     xticklabels(MV)
%     ylabel('MNAR [%]')   
%     yticks(1:length(MNAR))
%     yticklabels(MNAR)
%     set(gca,'FontSize',12)
%     title(algo{j})
% end
% print(['Simu_Algo_' strrep(name,'*','') '_1rep'],'-dpng');%,'-r1000');



ger = [2 4 6 8 10 12];
mvger = [2 4 6 8 10];
RMSE2 = RMSE(ger,mvger);
MNAR2 = MNAR(ger);
MV2 = MV(mvger);
idx2 = idxs(ger,mvger);
mfs2 = mfs(ger,mvger);
mrs2 = mrs(ger,mvger);

set(0,'DefaultFigureVisible','on')
figure; set(gcf,'units','points','position',[0,0,800,430])
imagesc(RMSE2);
scale = 0.88;
pos = get(gca, 'Position');
pos(3) = scale*pos(3);
set(gca, 'Position', pos)
ylabel('MNAR [%]')   
yticks(1:length(MNAR2))
yticklabels(MNAR2)
for r1=1:length(MNAR2)
    for r2 = 1:length(MV2)
        if RMSE2(r1,r2)>10 || isnan(RMSE2(r1,r2))
            c = 'r';
        else
            c='k';
        end
        text(r2,r1-0.3,num2str(round(idx2(r1,r2))),'Color',c,'HorizontalAlignment','center','FontSize',12,'FontWeight','bold');     
        text(r2,r1-0.1,num2str(round(RMSE2(r1,r2))),'Color',c,'HorizontalAlignment','center','FontSize',12,'FontWeight','bold');     
        text(r2,r1+0.1,mfg(mfs2(r1,r2)),'Color',c,'HorizontalAlignment','center','FontWeight','bold','FontSize',12);
        text(r2,r1+0.3,mrg(mrs2(r1,r2)),'Color',c,'HorizontalAlignment','center','FontSize',12,'FontWeight','bold');     
    end
end
c = colorbar;
c.Label.String = '\DeltaRMSE';
hp4 = get(gca,'Position');
% colorbar('YTick',1:length(mfg),'YTickLabel',mfg,'Position', [hp4(1)+hp4(3)+0.02  hp4(2)  0.02  hp4(4)*0.8],'TickLabelInterpreter','none','FontSize',17);
% annotation('textbox',[0.85 .72 .05 .2],'String',{'MNAR','\DeltaRMSE'},'FitBoxToText','on','HorizontalAlignment','center','BackgroundColor','w','FontSize',12)
xlabel('MV [%]')
xticks(1:length(MV2))
xticklabels(MV2)
set(gca,'FontSize',12)
print(['Simu_' strrep(name,'*','') 'klein'],'-dpng');