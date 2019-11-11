function O = imputation_original(O)

%% save copy 
%to remember imputation from simulated pattern
 path = get(O,'path');
[filepath,name] = fileparts(path);
if ~exist([filepath filesep name],'dir')
    mkdir(filepath, name)
end
if isempty(filepath)
    save([name filesep 'O_sim.mat'],'O');
else
    save([filepath filesep name filesep 'O_sim.mat'],'O');
end

%% find lowest ranked algo
if ~isfield(O,'Table',true)
    [~,algos] = GetRankTable(O);
else
    algos = get(O,'RankMethod');
end
algo = algos{1};


%% Load O new 
%because simulated pattern was much smaller, and also names etc. were shortened
if strncmp(path,['Data' filesep 'Simu'],9)
    load([path filesep path(6:end) '.mat']);
    O = OmicsData(data,path);
else
    O = OmicsData(path);
end
O = O(:,~all(isnan(O)));                      % delete columns/experiments with all nan
if max(O)>100                                 % data not logged yet? Log!
    O=log2(O);   
end
if ~checknan(O)                                  % no nans in data, so write zeros as nans
    dat = get(O,'data');                          
    dat(dat==0) = nan;  
    O = set(O,'data',dat,'Replaced 0 by nan.');
end
dat_original = get(O,'data');
O = set(O,'data_original',dat_original,'Save original');


%% Impute original dataset
O = impute(O,algo);

if ~isfield(O,'data_imput')
    algo = algos{2};
    O = impute(O,algo,[],true);
    if ~isfield(O,'data_imput')
        algo = algos{3};
        O = impute(O,algo,[],true);
    end
end
if ~isfield(O,'data_imput')
    error('Imputation was not feasible.')
end

%% SAVE
dat = get(O,'data_imput');
O = set(O,'data',dat,['Imputed with ' algo ]);
saveO(O,[],'O_imp')
%ImpToTxt

%% PLOT
path = get(O,'path');
[filepath,name] = fileparts(path);
if ~exist([filepath '/' name],'dir')
    mkdir(filepath, name)
end

% Limits for colorbar
bottom = min(quantile(dat(:),0.01),quantile(dat_original(:),0.01));
top  = max(quantile(dat(:),0.99),quantile(dat_original(:),0.99));

figure; %set(gcf,'units','points','position',[10,10,600,300])
subplot(1,2,1)
b = imagesc(dat_original);
set(b,'AlphaData',~isnan(dat_original))
caxis manual
caxis([bottom top]);
title('Original data')
ylabel('Proteins')
xlabel('Samples')
subplot(1,2,2)
b = imagesc(dat);
set(b,'AlphaData',~isnan(dat))
title(['Imputed data with ' algo])
xlabel('Samples')
caxis manual
caxis([bottom top]);
c=colorbar;
c.Label.String = 'Log2(LFQ Intensity)';
print([filepath '/' name '/' name '_Imputed'],'-dpng','-r50');

%% Sort/plot (for #nans)
[~,idx] = sort(sum(isnan(dat_original),2));
dat_original = dat_original(idx,:);
dat = dat(idx,:);
dat_original(all(isnan(dat_original),2),:)= [];
dat(all(isnan(dat),2),:)= [];

figure; %set(gcf,'units','points','position',[10,10,600,300])
subplot(1,2,1)
b = imagesc(dat_original);
set(b,'AlphaData',~isnan(dat_original))
caxis manual
caxis([bottom top]);
title('Original data')
ylabel('Proteins')
xlabel('Samples')
subplot(1,2,2)
b = imagesc(dat);
set(b,'AlphaData',~isnan(dat))
title(['Imputed data with ' algo])
%ylabel('Proteins')
xlabel('Samples')
caxis manual
caxis([bottom top]);
%c=colorbar;
c.Label.String = 'Log2(LFQ Intensity)';
print([filepath '/' name '/' name '_Imputed_Sorted'],'-dpng','-r50');

