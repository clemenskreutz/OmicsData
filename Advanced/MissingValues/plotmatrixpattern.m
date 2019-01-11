function plotmatrixpattern(dat_mis,dat_imp,T)

%figure; set(gcf,'units','points','position',[10,10,1000,130])
   figure('units','normalized','outerposition',[0 0 1 1])  
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
    set(gca, 'XTickLabel', [])
    set(gca, 'YTickLabel', [])
    ylabel('Imputed data values','Rotation',90,'FontSize',12)
    title({'Original values'; 'to compare'},'FontSize',10)
end

nr = size(dat_imp,1);
nc = size(dat_imp,2);
d = T.Variables; % Var values for text in image

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
    set(gca, 'XTickLabel', [])
    set(gca, 'YTickLabel', [])
    if c==0 && i==1
        ylabel('Imputed data values','Rotation',90,'FontSize',12)
    end
    if contains(T.Properties.VariableNames{i+1},'_')
        str = strsplit(T.Properties.VariableNames{i+1},'_');
        title({str{1}; str{2}},'Interpreter','none','FontSize',10)
    else
        title(T.Properties.VariableNames{i+1},'Interpreter','none','FontSize',10)
    end
    text(size(dat_imp,2)/10,size(dat_imp,1)/20,['$\sqrt{LS}=$' sprintf('%.2f',d(6,i+1))],'Interpreter','latex','FontSize',8)
end

hp4 = get(subplot(1,n+c,n+c),'Position');
c = colorbar('Position', [hp4(1)+hp4(3)+0.01  hp4(2)  0.01  hp4(4)]);
c.Label.String = 'log10(LFQ Intensity)';
