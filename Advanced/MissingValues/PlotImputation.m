
function PlotImputation(O)

if ~exist('O','var')
    error('OmicsData object has to be given as input argument.')
end

%% Get variables from class
% Get data
dat_complete = get(O,'data_complete',true);       % Complete dataset without missing values, to compare "right" solution
if isempty(dat_complete)
    dat_complete = get(O,'data_full');
    dat_complete = dat_complete(:,:,1);
end
dat_original = get(O,'data_original');
dat_mis = get(O,'data_mis',true);            % simulated missing values       
if isempty(dat_mis)
    dat_mis = get(O,'data');
end
dat_imp = get(O,'data_imput');               % Imputed data

dat_mis(isnan(dat_mis)) = 1;
dat_mis(dat_mis ~= 1) = NaN;
dat_just_imp = dat_imp .* dat_mis;                % JUST imputed data

% Get path
path = get(O,'path');
[filepath,name] = fileparts(path);

% Get method & RMSE
Tab = get(O,'RankTable',true);
if isempty(Tab)
    O = GetRankTable(O);
    Tab = get(O,'RankTable');
end
try
    Tab = Tab{2,:};
catch
    Tab = Tab(2,:);
end
method = get(O,'method_imput');
Rankmethod = get(O,'RankMethod');
[~,idxmethod] = ismember(Rankmethod,method);
%Rankmethod = GetNames(Rankmethod);

% Mean Error
Diff = abs(dat_complete-dat_just_imp);               % |Imp-Original| 
s = size(Diff);
Diff = reshape(Diff,[s(1)*s(2)*s(3),s(4)]);    % row,col,pattern do not matter -> squeeze
Diff = Diff(:,idxmethod);                   % sort method by rank
Diff(Diff==0) = NaN;                            % if not imputed, ignore for boxplot

%% Boxplot
figure; set(gcf,'outerposition',[0 0 800 500]) 
boxplot(Diff,'PlotStyle','compact','Symbol','.');%,'DataLim',[0 6])
hold on;
p2 = plot(Tab,'rd','MarkerFaceColor','r','LineWidth',1);
set(gca,'XTick',1:size(dat_imp,4)+1);
set(gca,'XTickLabel',Rankmethod,'XTickLabelRotation',45, 'FontSize',14);  
ylabel('|Imputed - Original|', 'FontSize',14)
ylim([0 6])
legend(p2,'RMSE','Location','northwest')
%title('Imputation error', 'FontSize',18)
print([filepath filesep name filesep 'ImputationError'],'-djpeg','-r1000');

%% correlation imputed vs original
figure; set(gcf,'outerposition',[0 0 1000 1000]) 
s = size(dat_imp);
Imp = reshape(nanmean(dat_imp,3),[s(1)*s(2),s(4)]);
Imp = Imp(:,idxmethod);
idxplot = 1:s(4); %round(linspace(1,s(4),3));
myColorMap = jet(256);
myColorMap(1:s(4),:) = 1;
limin = nanmin(dat_complete(:));
limax = nanmax(dat_complete(:));
for i=1:s(4)
    subplot(floor(sqrt(s(4))),ceil(s(4)/floor(sqrt(s(4)))),i)
    %plot(dat_complete(:),Imp(:,idxplot(i)),'.')
    hold on
    if i>=floor(sqrt(s(4)))*(ceil(s(4)/floor(sqrt(s(4))))-1)
        xlabel('Original')
    else
        xticks([])
    end
    if rem(i,ceil(s(4)/floor(sqrt(s(4)))))==1
        ylabel('Imputed')
    else
        yticks([])
    end
    [anz,c] = hist3([dat_complete(:),Imp(:,idxplot(i))],'Nbins',[70,70]);
    H = pcolor(c{1}(:), c{2}(:), anz');
    shading interp
    set(H,'edgecolor','none');
    colormap(myColorMap);
    caxis([0 13]);
    plot(limin:limax,limin:limax)
    xlim([limin limax])
    ylim([limin limax])
    title(Rankmethod{idxplot(i)},'Interpreter','none')                    
    set(gca,'FontSize', 11)
end
print([filepath filesep name filesep 'ImputationDistribution'],'-dtiff','-r1000');

% Histogram
figure
[f,xi] = ksdensity(dat_original(:));
plot(xi,f,'k--','LineWidth',1.5)
%histogram(dat_complete(:),limin:0.3:limax,'k','DisplayStyle','stairs','LineWidth',3);
hold on;
for i=1:s(4)
    [f,xi] = ksdensity(Imp(:,idxplot(i)));
    plot(xi,f,'LineWidth',1)
    %histogram(Imp(:,idxplot(i)),limin:0.3:limax,'DisplayStyle','stairs','LineWidth',1.5);  
end
xlim([limin limax])
xlabel('Intensity')
ylabel('Frequency')
yticks([])
title('Distribution')
hp4 = get(gca,'Position');
set(gca,'FontSize', 11)
%legend({'Ori','Seq','mFo','Ame','Nor','kNN'},'Interpreter','none','Position',[hp4(1)+hp4(3)*2/3 hp4(2)+0.11 hp4(3)/2.5 hp4(3)*0.8],'FontSize',18);
legend([{'Original'},{'Imputations'}],'Interpreter','none','FontSize',11);%,'Position',[hp4(1)+hp4(3)/2 hp4(2)+0.13 hp4(3)/2.5 hp4(3)*0.5])
print([filepath filesep name filesep 'ImputationHistogram'],'-djpeg','-r1000');
