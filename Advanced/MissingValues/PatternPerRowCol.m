function PatternPerRowCol(O)

ori = get(O,'data_original');
pat = get(O,'data_mis');
path = get(O,'path');

ori = ori(ceil(rand(size(pat,1),1)*size(ori,1)),:);  % Reduce #rows of datginal to match #rows of pattern
pat = pat(:,:,1); % enough to plot one exemplary pattern

%% Plot patsing values per row column, compare datginal/simulated
figure
subplot(2,1,1)
datrow = sort(sum(isnan(ori),2)/size(ori,2));
plot(datrow,'LineWidth',1.5)
hold on
datsimrow = sort(sum(isnan(pat),2)/size(pat,2));
plot(datsimrow,'LineWidth',1.5)
xlabel('proteins')
ylabel('missing values')
legend('Original','Simulated','Location','northwest');
hold off

subplot(2,1,2)
bar(sum(isnan(ori),1)/size(ori,1),'Facealpha',.7)
hold on
bar(sum(isnan(pat),1)/size(pat,1),'Facealpha',.7)
xlabel('experiments')
ylabel('Missing values')
legend('Original','Simulated','Location','northwest');

% Save fig
[path, name] = fileparts(path);
if isempty(path)
    path = pwd;
end
delete([path filesep name filesep 'MissingRowCol_AllX.tif'])
saveas(gcf,[path filesep name filesep 'MissingRowCol_AllX.tif'])