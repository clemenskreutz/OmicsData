function assignmissing

global O

if ~exist('O','var')
    error('MissingValues/assignmissing.m requires class O as global variable.')
end

A = get(O,'data');                                                      % Dataset without missing values
O = set(O,'data_womissing',A);                                          % Save dataset without missing values
O = set(O,'data_full',A,'Complete dataset without missing values');     % Remember full/complete dataset for comparing 'right' solutions with imputed afterwards
dat = get(O,'data_original');                                           % Original with missing values
out = get(O,'out');                                                     % Logreg coefficients
% n_mis = length(find(isnan(dat)))/size(dat,1)/size(dat,2);             % how many missing values in original dataset ? 

%% get coeff for each cell index
t = out.type(:,1);                            % In the separation of datasets:
b1 = out.b(t==1,:); b1 = mean(b1,2);          % Intensities together
b2 = out.b(t==2,:); b2 = mean(b2,2);          % Columns together
b3 = out.b(t==3,:); b3(isnan(b3)) = [];       % rows each separate
if size(A,1)<size(b3,1)                       % Because by deleting all nans, matrix gets smaller
    r = randperm(size(b3,1),size(b3,1)-size(A,1));  % delete randomly, to keep pattern
    b3(r) = [];
end
m = (A-mean(A))./nanstd(A);  % Intensity centered & normalized

%% Calculate probability for each cell index
logit = nan(size(A,1),size(A,2));
for i=1:size(A,1)
    for j=1:size(A,2)
        logit(i,j) = exp(b1*m(i,j)+b2(j)+b3(i));
    end
end
p = logit./(1+logit);                    % Probability

%% assign nans
r = rand(size(p,1),size(p,2));
full=A;
A(r<=p) = NaN;

%% Plot matrices original/simulated intensities/nans

figure; set(gcf,'units','points','position',[10,10,600,300])
subplot(1,3,1)
nr = size(dat,1);
nc = size(dat,2);
pcolor([dat nan(nr,1); nan(1,nc+1)]);
shading flat;
set(gca, 'ydir', 'reverse');
caxis manual
caxis([0 max(max(dat))]);
title('Original data')
ylabel('Proteins')
xlabel('Experiments')

subplot(1,3,2)
nr = size(full,1);
nc = size(full,2);
pcolor([full nan(nr,1); nan(1,nc+1)]);
shading flat;
set(gca, 'ydir', 'reverse');
caxis manual
caxis([0 max(max(dat))]);
title({'Original data','without missing values'})
c = colorbar('southoutside');
c.Label.String = 'log10( LFQ Intensity )';

subplot(1,3,3)
nr = size(A,1);
nc = size(A,2);
pcolor([A nan(nr,1); nan(1,nc+1)]);
shading flat;
set(gca, 'ydir', 'reverse');
caxis manual
caxis([0 max(max(dat))]);
title('Simulated missing pattern')
c = colorbar('southoutside');
c.Label.String = 'log10( LFQ Intensity )';

% Save fig
path = get(O,'path');
[filepath,name] = fileparts(path);
mkdir(filepath, name)
saveas(gcf,[filepath '/' name '/' name '_datamatrices.png'])

%% Plot missing values per row column, compare original/simulated
%% Remove rows randomly, so original and assigned matrix size matches
data_new = dat;
if size(dat,1)>size(A,1)
    r = randperm(size(dat,1),size(dat,1)-size(A,1));  % delete randomly, to keep pattern
    data_new(r,:) = [];
end
figure
subplot(2,1,1)
bar(sum(isnan(data_new),2)/size(data_new,2))
hold on
bar(sum(isnan(A),2)/size(data_new,2))
xlabel('rows')
ylabel('Missing values [%]')
h = legend('Original','Simulated','Location','northeast');
hold off

subplot(2,1,2)
bar(sum(isnan(data_new),1)/size(data_new,1))
hold on
bar(sum(isnan(A),1)/size(data_new,1))
xlabel('columns')
ylabel('Missing values [%]')
h = legend('Original','Simulated','Location','northeast');
hold off

% Save fig
saveas(gcf,[filepath '/' name '/' name '_perrowcol.png'])


% figure
% subplot(2,1,1)
% histogram(sum(isnan(data_new),2)/size(data_new,2),'BinWidth',0.05,'FaceColor','blue')
% hold on
% histogram(sum(isnan(A),2)/size(A,2),'BinWidth',0.05,'FaceColor','yellow')
% xlabel('Missing values [%]')
% h = legend('Original','Simulated','Location','northeast')
% %set(h,'FontSize',8);
% title('Compare columns')
% 
% subplot(2,1,2)
% histogram(sum(isnan(data_new),1)/size(data_new,1),'BinWidth',0.01,'FaceColor','blue')
% hold on
% histogram(sum(isnan(A),1)/size(A,1),'BinWidth',0.01,'FaceColor','yellow')
% xlabel('Missing values [%]')
% ylabel('Frequency')
% title('Compare rows')
% %legend('Original','Simulated','Location','northoutside','Orientation','horizontal')
% hold off

% Save fig
%saveas(gcf,[filepath '/' name '/' name '_perrowcol.png'])

%% Save class O
O = set(O,'data',A,'Missing values assigned/simulated.');
O = set(O,'data_mis',A,'data with assigned missing values');
O = set(O,'mis_pat',isnan(A),'pattern of missing values');
save([filepath '/' name '/AssignedMissing.mat'],'O')

%% Write xls
data_full = get(O,'data_full');

dlmwrite([filepath '/' name '/AssignedMissing.txt'],A);

%xlswrite([filepath '/' name '/AssignedMissing.xls'],A);
%xlswrite([filepath '/' name '/CompleteData.xls'],data_full);


