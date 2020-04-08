%% Plots the real dataset and the simulated, to see if simulation is nice

% Chose setting
settings = {'p1'};
%pattern = {'real','R1','R2','R3','R4','S1','S2','S3','S4'};
a = (1:4).*ones(4,1);
a2 = a';
pattern = [{'real'}, strcat( strcat('R', cellstr(string(a(:))))' , strcat('S', cellstr(string(a2(:))))' )];
pattern = pattern(1:15);

for s=1:length(settings)
    setting = settings{s};
    Ocombined = [];
    for pat = 1:length(pattern)
        %% Load
        if ~contains(pattern{pat},'real')
            if exist([setting filesep 'Osim' pattern{pat} '.mat'],'file')
                load([setting filesep 'Osim' pattern{pat} '.mat'])
                if ~exist('Ocombined','var') || isempty(Ocombined)
                    Ocombined = O;
                else
                    Ocombined = [Ocombined, O];
                end
            end
        end
    end
    % Load original data
    load('O.mat')
    if contains(setting,'Whole')
        O = O(:,contains(get(O,'hy'),'___'));
    else
        O = O(:,contains(get(O,'hy'),['___' setting(end)]));
    end
    O = OmicsRemoveEmptyFeatures(O);
    O = ReplaceSamplenames(O);
    
    % Sort for plotting
    [~,idx] = sort(nanmean(O,2));
    O = O(idx,:);
    Ocombined = Ocombined(idx,:);
    [~,idx] = sort(sum(isnan(O),2));
    O = O(idx,:);
    Ocombined = Ocombined(idx,:);
    
    % Plot
    figure(s); set(gcf,'units','normalized','outerposition',[0 0 0.9 0.9])
    subplot(1,2,1)
    image(O,[],0)
    hold on
    plot(0:size(O,2)+1,(size(O,1)-sum(any(isnan(O),2)))*ones(size(O,2)+2),'y','LineWidth',2)
    xticks(1:size(O,2))
    xticklabels(get(O,'SampleNames'))
    xtickangle(90)
    title(setting)

    subplot(1,2,2)
    image(Ocombined,[],0)
    hold on
    caxis manual
    caxis([min(nanmin(O)) max(nanmax(O))]);
    xticks(1:size(O,2))
    xticklabels(get(Ocombined,'SampleNames'))
    xtickangle(90)
    title([setting ' simulated'])
    print(gcf,['SimulatedPattern_' setting],'-dpng');%,'-r1000')
end