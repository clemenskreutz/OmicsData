function plotmatrixpattern(dat_mis,dat_imp,T,idx)

figure; set(gcf,'units','points','position',[10,10,1000,130])

if length(size(dat_imp))<4
    n = size(dat_imp,3);  % number of imputations
else
    n = size(dat_imp,4);  % number of imputations
end

if isempty(dat_mis)
    c=0;
else %% Plot original values first
    c=1;

    subplot(1,n+c,1)
    [nr nc] = size(dat_mis);
    pcolor([dat_mis nan(nr,1); nan(1,nc+1)]);
    shading flat;
    set(gca, 'ydir', 'reverse');
    caxis manual
    caxis([0 max(max(max(dat_imp)))]);
    %xlabel('Experiments')
    set(gca, 'XTickLabel', [])
    set(gca, 'YTickLabel', [])
    %ylabel('Proteins')
    title({'Original values'; 'to compare'})
end

nr = size(dat_imp,1);
nc = size(dat_imp,2);
d = T.Variables; % LS values for text in image
for i=1:n
    subplot(1,n+c,i+c)
    if length(size(dat_imp))==3
        pcolor([dat_imp(:,:,i) nan(nr,1); nan(1,nc+1)]);
    elseif length(size(dat_imp))==4
        pcolor([dat_imp(:,:,1,i) nan(nr,1); nan(1,nc+1)]);
    end
    shading flat;
    set(gca, 'ydir', 'reverse');
    caxis manual
    caxis([0 max(max(max(dat_imp)))]);
 %   xlabel('Experiments')
    set(gca, 'XTickLabel', [])
    set(gca, 'YTickLabel', [])
 %   ylabel('Proteins')
    title({'Imputed with'; [T.Properties.VariableNames{idx(i)+1}]},'Interpreter','none')
    text(size(dat_imp,2)/3*2-1,size(dat_imp,1)/10,['LS = ' sprintf('%.2f',d(6,idx(i)+1))],'Interpreter','latex')
end
hp4 = get(subplot(1,n+c,n+c),'Position');
c = colorbar('Position', [hp4(1)+hp4(3)+0.01  hp4(2)  0.01  hp4(4)]);
c.Label.String = 'log10(LFQ Intensity)';
