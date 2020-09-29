% Imputes data of OmicsData object 'O' with the algorithm 'algos'
%
% O        - @OmicsData object
% algos    - string of imputation algorithm
%          - cell array of imputation algorithms, if first algos{1} fails 
%          second algos{2} is used for imputation
% writetxt - flag if O is written into originalfilename_Imp.txt    [true]
% plt      - flag if original data vs imputed data is plotted as heatmap [true]
%
% Example:
% Oimp = imputation(O,methods);
% O = GetTable(Oimp);
% O = imputation_original(O,algos); 

function O = imputation_original(O,algos,writetxt,plt)

if ~isa(O,'OmicsData')
    O = OmicsData(O);
end
if ~exist('algos','var') || isempty(algos) || (~ischar(algos) && ~iscell(algos))
    warning('Original dataset is not imputed. The second input argument, the recommended imputation algorithm, is required but could not be found.')
end
if ~iscell(algos)
    algos = {algos};
end
if ~exist('writetxt','var') || isempty(writetxt)
    writetxt = true;
end
if ~exist('plt','var') || isempty(plt)
    plt = true;
end
    
O = OmicsPre(O);
dat_load = get(O,'data'); % for plotting

%% Impute original dataset
O = impute(O,algos{1});
if ~isfield(O,'data_imput') && length(algos)>1
    O = impute(O,algos{2},[],true);
    if ~isfield(O,'data_imput')
        O = impute(O,algos{3},[],true);
    end
end
if ~isfield(O,'data_imput')
    error('Imputation was not feasible.')
end

%% SAVE
dat = get(O,'data_imput');
algo = get(O,'method_imput');
O = set(O,'data',dat,['Imputed with ' algo{:} ]);
O = set(O,'algorithm',algo{:});
saveO(O,[],'O_DIMA')
sprintf(['Your dataset was imputed with ' algo{:} '\n'])

%% Write txt
path = get(O,'path');
[folder,name] = fileparts(path);
if writetxt
    newname = [name '_Imp.txt'];
    Owrite = O;
    Owrite = set(Owrite,'data',dat,['Imputed with ' algo ]);
    WriteData(Owrite,[folder filesep newname]);
    fprintf('%s%s','The imputed dataset was unlogged and written in ', [folder filesep newname])
end

%% PLOT
if plt
    if ~exist([folder '/' name],'dir')
        mkdir(folder, name)
    end

    % Limits for colorbar
    bottom = min(quantile(dat(:),0.01),quantile(dat_load(:),0.01));
    top  = max(quantile(dat(:),0.99),quantile(dat_load(:),0.99));

    figure; %set(gcf,'units','points','position',[10,10,600,300])
    subplot(1,2,1)
    b = imagesc(dat_load);
    set(b,'AlphaData',~isnan(dat_load))
    caxis manual
    caxis([bottom top]);
    title('Original data')
    ylabel('features')
    xlabel('Samples')
    subplot(1,2,2)
    b = imagesc(dat);
    set(b,'AlphaData',~isnan(dat))
    title(['Imputed data with ' algo])
    xlabel('Samples')
    caxis manual
    caxis([bottom top]);
    c=colorbar;
    c.Label.String = 'Log2(NormalizedRatios)';
    print([folder '/' name '/' name '_Imputed'],'-dpng','-r50');

    %% Sort/plot (for #nans)
    [~,idx] = sort(sum(isnan(dat_load),2));
    dat_load = dat_load(idx,:);
    dat = dat(idx,:);

    figure; %set(gcf,'units','points','position',[10,10,600,300])
    subplot(1,2,1)
    b = imagesc(dat_load);
    set(b,'AlphaData',~isnan(dat_load))
    caxis manual
    caxis([bottom top]);
    title('Original data')
    ylabel('features')
    xlabel('Samples')
    subplot(1,2,2)
    b = imagesc(dat);
    set(b,'AlphaData',~isnan(dat))
    title(['Imputed data with ' algo])
    %ylabel('features')
    xlabel('Samples')
    caxis manual
    caxis([bottom top]);
    c=colorbar;
    c.Label.String = 'Log2(NormalizedRatios)';
    print([folder '/' name '/' name '_Imputed_Sorted'],'-dpng');
end
