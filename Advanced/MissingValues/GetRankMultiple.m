addpath(genpath('OmicsData'))

name = 'OBrien500*';
file = dir(['Data' filesep name]);
file = natsort({file.name});
file(1:3)
MV = 5:5:50;
MNAR = 100:-10:0;
idx = nan(length(MV)*length(MNAR),1);
R = idx; R2 = idx; NR = idx; r= idx;
mr = cell(length(file),1); mf = cell(length(file),1);
mfulln = cell(1,31); mn = cell(1,31);
mall  = []; mfullall  = []; mcount  = []; mfullcount  = [];
M = zeros(length(file),1); Mfull = M;
for i=61%:length(file)
     folder = dir(['Data' filesep file{i} filesep 'O_full_*.mat']);
     fprintf(['\n' file{i} '\n'])
     if length(folder)>size(mfulln,1)
         mfulln = cell(length(folder),31); mn = cell(length(folder),31);
     end
     mfulln(1:size(mfulln,1),1:size(mfulln,2)) = {'NaN'};
     mn(1:size(mn,1),1:size(mn,2)) = {'NaN'};
     Tfulln = nan(size(mfulln,1),size(mfulln,2));
     for ii=1:length(folder)
        % direct imputation
        if exist([folder(ii).folder filesep folder(ii).name],'file')
            L = load([folder(ii).folder filesep folder(ii).name]); 
            O = L.O;
            if isfield(O,'data_imput',true)
            %fprintf([folder(ii).folder filesep folder(ii).name ' exists'])
            if ~isfield(O,'RankTable',true)
        	       	O = GetRankTable(O);
	                saveO(O,[],folder(ii).name(1:end-4))
        	end
                mget = get(O,'RankMethod');
                mfulln(ii,1:length(mget)) = mget;
                Tget = get(O,'RankTable');
	        try
	              Tfulln(ii,1:size(Tget,2)) = Tget{2,:};  
	        catch 
	              Tfulln(ii,1:size(Tget,2)) = Tget(2,:);  
	        end
	        Mfull(i) = Mfull(i)+1;
	    else
		fprintf(folder(ii).name)
		mfulln(ii,1:size(mfulln,2)) = {'NaN'};
	    end
        else
            [folder(ii).folder filesep folder(ii).name ' does not exist. Check it.']
            mfulln(ii,1:size(mfulln,2)) = {'NaN'};
        end
        % DIMA imputation
        if exist([folder(ii).folder filesep strrep(folder(ii).name,'_full','')],'file')
            L = load([folder(ii).folder filesep strrep(folder(ii).name,'_full','')]); 
	    O = L.O;
	    if isfield(O,'data_imput',true)
	 	%fprintf([folder(ii).folder filesep folder(ii).name ' exists'])
               if ~isfield(O,'RankTable',true)
                   O = GetRankTable(O);
                   saveO(O,[],strrep(folder(ii).name(1:end-4),'_full',''))
               end
               mget = get(O,'RankMethod'); 
               mn(ii,1:length(mget)) = mget;
               M(i) = M(i)+1;
	    else
		fprintf(strrep(folder(ii).name,'_full',''))
		mn(ii,1:size(mn,2)) = {'NaN'};
	    end
        else
            mn(ii,1:size(mn,2)) = {'NaN'};
        end       
     end
    % Rank repetitions
    unimfull = unique(mfulln);
    T = nan(length(unimfull),1); ranking = nan(length(unimfull),1); Tget = nan(size(mfulln,1),1);
    for r=1:length(unimfull)
        if ~strcmp(unimfull{r},'NaN')
            [row,rankn] = find(strcmp(mfulln,unimfull{r})); % get ranks of each method to get RMSE
            if length(rankn)<size(mfulln,1)-sum(all(strcmp(mfulln,'NaN'),2))
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
    %rankfull(i) = ranking(1);
    
    unim = unique(mn);
    rankd = nan(length(unim),1);
    for r=1:length(unim)
        [~,rankn] = find(strcmp(mn,unim{r}));
        if length(rankn)<size(mfulln,1)
            rankn = [rankn; 30*ones(size(mfulln,1)-length(rankn),1)];   % if method failed for a replicate, add rank 30
        end
        rankd(r) = sum(rankn);
    end
    [~,id] = sort(rankd);
    m = unim(id);
     
    % Get numbers for heatmap
    try     
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
RMSE = flipud(reshape(R,length(MNAR),length(MV)));
Mfulls = flipud(reshape(Mfull,length(MNAR),length(MV)))
Ms = flipud(reshape(M,length(MNAR),length(MV)))
[mrc,mrg] = grp2idx(mr);
[mfc,mfg] = grp2idx(mf);
mrs = flipud(reshape(mrc,length(MNAR),length(MV)));
mfs = flipud(reshape(mfc,length(MNAR),length(MV)));

set(0,'DefaultFigureVisible','off')
figure; set(gcf,'units','points','position',[0,0,1200,800])%650,400]) %1000,800
imagesc(RMSE);
scale = 0.88;
pos = get(gca, 'Position');
pos(3) = scale*pos(3);
set(gca, 'Position', pos)
ylabel('MNAR [%]')   
yticks(1:length(MNAR))
yticklabels(MNAR)
c='k';
for r1=1:length(MNAR)
    for r2 = 1:length(MV)
        text(r2,r1-0.2,num2str(idxs(r1,r2),'%.1f'),'Color',c,'HorizontalAlignment','center','FontSize',14,'FontWeight','bold');     
        text(r2,r1+0.2,num2str(RMSE(r1,r2),'%.1f'),'Color',c,'HorizontalAlignment','center','FontSize',14,'FontWeight','bold');     
    end
end
c = colorbar;
c.Label.String = '\DeltaRMSE [%]';
colormap(gca,flipud(winter))
xlabel('MV [%]')
xticks(1:length(MV))
xticklabels(MV)
set(gca,'FontSize',20)
print(['Simu_' strrep(name,'*','')],'-depsc');
print(['Simu_' strrep(name,'*','')],'-dpng');

figure; set(gcf,'units','points','position',[0,0,1300,800])%650,400]) %1000,800
imagesc(RMSE);
scale = 0.88;
pos = get(gca, 'Position');
pos(3) = scale*pos(3);
set(gca, 'Position', pos)
ylabel('MNAR [%]')   
yticks(1:length(MNAR))
yticklabels(MNAR)
c='k';
for r1=1:length(MNAR)
    for r2 = 1:length(MV)
        text(r2,r1-0.3,num2str(idxs(r1,r2),'%.1f'),'Color',c,'HorizontalAlignment','center','FontSize',8,'FontWeight','bold');     
        text(r2,r1-0.1,num2str(RMSE(r1,r2),'%.1f'),'Color',c,'HorizontalAlignment','center','FontSize',8,'FontWeight','bold');     
        text(r2,r1+0.1,mfg(mfs(r1,r2)),'Color',c,'HorizontalAlignment','center','FontWeight','bold','FontSize',8);
        text(r2,r1+0.3,mrg(mrs(r1,r2)),'Color',c,'HorizontalAlignment','center','FontSize',8,'FontWeight','bold');     
    end
end
c = colorbar;
c.Label.String = '\DeltaRMSE [%]';
colormap(gca,flipud(winter))
xlabel('MV [%]')
xticks(1:length(MV))
xticklabels(MV)
set(gca,'FontSize',14)

print(['Simu_' strrep(name,'*','') '_algo'],'-depsc');
print(['Simu_' strrep(name,'*','') '_algo'],'-dpng');
