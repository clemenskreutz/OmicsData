%% Evaluate how many more peptides are significant if repeating one experiment

% Chose setting
settings = {'p1'}; %,'Whole'};
%pattern = {'real','R1','R2','R3','R4','S1','S2','S3','S4'};
a = (1:4).*ones(4,1);
a2 = a';
pattern = ['real','R1','R2','R3','R4','S1','S2','S3','S4', strcat( strcat('R', cellstr(string(a(:))))' , strcat('S', cellstr(string(a2(:))))' )];

for s=1:length(settings)
    setting = settings{s};
    figure(s)
    hold on
    for pat = 1:length(pattern)
        %% Load
        load([setting filesep 'ps' pattern{pat} '.mat'])

        idxtime = find(contains(xnames,'Time'));  % just p for Time predictors
        %idxtime = 1:length(xnames);              % for all p
        
        %% How many peptides
        n(s,pat) = sum(~all(isnan(ps(:,idxtime)),2));
        nsig(s,pat) = sum(any(ps(:,idxtime)<0.01,2));
        
        %% Plot
        histogram(ps(:,idxtime))
    end
    legend(pattern)
    title(setting)
end
T = array2table(nsig);
T.Properties.RowNames = settings;
T.Properties.VariableNames = pattern;

Tdiff = T;
Tdiff{:,:} = T{:,:}-T{:,1};

fprintf('%s\n','Experiments with 2% more significant peptides when repeating the experiment:')
idx = find(Tdiff{end,:}>T{end,:}/50);
for i=1:length(idx)
    fprintf(['Repeating experiment ' pattern{idx(i)} ' results in ' num2str(Tdiff{end,idx(i)}) ' more significant peptides than the ' num2str(T{end,idx(i)}) 'peptides in the performed experiment.\n'])
end


figure; set(gcf,'units','points','position',[0,0,800,400])
bar(T{end,:})
ylim([nanmin(T{end,:})*0.99 nanmax(T{end,:})*1.01])
xticks(1:size(T,2))
xticklabels([T.Properties.VariableNames(1) strcat('+',T.Properties.VariableNames(2:end))])
ylabel('# Significant peptides')
print(gcf,'SignificantPeptides','-dpng');%,'-r1000')

figure; set(gcf,'units','points','position',[0,0,400,400])
bar(n(end,:))
ylim([nanmin(n(end,:))*0.99 nanmax(n(end,:))*1.01])
xticks(1:size(T,2))
xticklabels([T.Properties.VariableNames(1) strcat('+',T.Properties.VariableNames(2:end))])
ylabel('# Peptides')
print(gcf,'Peptides','-dpng');

% figure
% subplot(1,3,1)
% hist(psreal,100)
% xlim([0,0.01])
% subplot(1,3,2)
% hist(pssim1{36},100)
% xlim([0,0.01])
% subplot(1,3,3)
% hist(pssimexp,100)
% xlim([0,0.01])
