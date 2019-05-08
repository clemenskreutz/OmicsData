function imputation_original

global O

%% save copy 
%to remember imputation from simulated pattern
path = get(O,'path');
[filepath,name] = fileparts(path);
if ~exist([filepath '/' name],'dir')
    mkdir(filepath, name)
end
saveO(O,[],'O_sim')
save([filepath '/' name '/O_sim.mat'],'O');

%% find lowest ranked algo
algos = GetRankTable;
algo = algos{1};
lib = FindLib(algo);

%% Load O new 
%because simulated pattern was much smaller, and also names etc. were shortened
if strncmp(path,'Data\Simu',9)
    load([path '\' path(6:end) '.mat']);
    O = OmicsData(data,path);
else
    O = OmicsData(path);
end
O = O(:,~all(isnan(O)));                      % delete columns/experiments with all nan
if max(O)>1000                                % data not logged yet? Log!
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
O = set(O,'deleteemptyrows',false);
impute_R(lib,algo)

% did it work? else try delete empty rows
if ~isfield(O,'data_imput')
    O = set(O,'deleteemptyrows',true);
    imputation_clear  % clear previous imputations in O
    impute_R(lib,algo)
end
% no nans in imputed ? else try second algo
if ~isfield(O,'data_imput')
    algo = algos{2};
    imputation_clear  % clear previous imputations in O
    impute_R(lib,algo,[])
    if ~isfield(O,'data_imput')
        O = set(O,'deleteemptyrows',true);
        imputation_clear  % clear previous imputations in O
        impute_R(lib,algo)
    end
end
if ~isfield(O,'data_imput')
    error('Imputation was not feasible. There are still nans in dataset.')
end

%% SAVE
dat = get(O,'data_imput');
O = set(O,'data',dat,['Imputed with ' algo ]);
saveO
%ImpToTxt

%% PLOT
path = get(O,'path');
[filepath,name] = fileparts(path);
if ~exist([filepath '/' name],'dir')
    mkdir(filepath, name)
end

% Limits for colorbar
bottom = min(min(min(dat)),min(min(dat_original)));
top  = max(max(max(dat_original)),max(max(dat)));

figure; %set(gcf,'units','points','position',[10,10,600,300])
subplot(1,2,1)
b = imagesc(dat_original);
set(b,'AlphaData',~isnan(dat_original))
caxis manual
caxis([bottom top]);
title('Original data')
ylabel('Proteins')
xlabel('Experiments')
subplot(1,2,2)
b = imagesc(dat);
set(b,'AlphaData',~isnan(dat))
title(['Imputed data with ' algo])
xlabel('Experiments')
caxis manual
caxis([bottom top]);
c=colorbar;
c.Label.String = 'Log2(LFQ Intensity)';
print([filepath '/' name '/' name '_Imputed'],'-dpng','-r200');

%% Sort/plot (for #nans)
[~,idx] = sort(sum(isnan(dat_original),2));
dat_original = dat_original(idx,:);
dat = dat(idx,:);

figure; %set(gcf,'units','points','position',[10,10,600,300])
subplot(1,2,1)
b = imagesc(dat_original);
set(b,'AlphaData',~isnan(dat_original))
caxis manual
caxis([bottom top]);
title('Original data')
ylabel('Proteins')
xlabel('Experiments')
subplot(1,2,2)
b = imagesc(dat);
set(b,'AlphaData',~isnan(dat))
title(['Imputed data with ' algo])
%ylabel('Proteins')
xlabel('Experiments')
caxis manual
caxis([bottom top]);
%c=colorbar;
c.Label.String = 'Log2(LFQ Intensity)';
print([filepath '/' name '/' name '_Imputed_Sorted'],'-dpng','-r200');

