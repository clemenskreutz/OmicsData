% [X,xnames,grouplevels] = DefineX(hy)
% [X,xnames,grouplevels] = DefineX(hy, 'onlyCancer')

function [X,xnames,grouplevels] = DefineX(O, option)
if ~exist('option','var') || isempty(option)
    option = '';
end

snames = get(O,'snames');

% isBPH = ~cellfun(@isempty,regexp(snames,'BPH')); % 28 x benigne hyperplasie (BPH)
is2 = ~cellfun(@isempty,regexp(snames,'batch2')); 
isLR = ~cellfun(@isempty,regexp(snames,'_LR_')); % 20 x low-risk prostate cancer (LR)
isHR = ~cellfun(@isempty,regexp(snames,'_HR_')); % 20 x high-risk prostate cancer (HR)

[psa,psa_ilev] = getPSA(O);  % custom function, have to be implemented in a project specific way (if required)
[ts,tnum]=getTumorStage(O); % custom function, have to be implemented in a project specific way (if required)
glea = getGleasonScore(O); % custom function, have to be implemented in a project specific way (if required)
[lev,anz,glea_ilev] = levels(glea); % custom function, have to be implemented in a project specific way (if required)


%% all possible predictors
X = [];
xnames = cell(0);
xnames{end+1} = 'LR';
X = [X,zeros(size(X,1),1)];
X(isLR,end) = 1;
X(~isLR,end) = 0;

xnames{end+1} = 'HR';
X = [X,zeros(size(X,1),1)];
X(isHR,end) = 1;

xnames{end+1} = 'Cancer';
X = [X,zeros(size(X,1),1)];
X(isHR,end) = 1;
X(isLR,end) = 1;

xnames{end+1} = 'Batch2';
X = [X,zeros(size(X,1),1)];
X(is2,end) = 1;

xnames{end+1} = 'PSA_0-1';
psa_tmp = psa_ilev - nanmin(psa_ilev);
psa_tmp = psa_tmp./nanmax(psa_tmp);
X(:,end+1) = psa_tmp';

xnames{end+1} = 'PSA>10';
X = [X,zeros(size(X,1),1)];
X(psa>10,end) = 1;

xnames{end+1} = 'TumorStage_0-1';
t_tmp = tnum - nanmin(tnum);
t_tmp = t_tmp./nanmax(t_tmp);
X(:,end+1) = t_tmp';

xnames{end+1} = 'pT3,pT4';
X = [X,zeros(size(X,1),1)];
X(strmatch('pT3',ts),end) = 1;
X(strmatch('pT4',ts),end) = 1;

xnames{end+1} = 'GleasonScore_0-1';
g_tmp = glea_ilev - nanmin(glea_ilev);
g_tmp = g_tmp./nanmax(g_tmp);
X(:,end+1) = g_tmp';

xnames{end+1} = 'Age';
age = get(O,'Age');
[lev,anz,age_ilev] = levels(age);
age_tmp = age_ilev - nanmin(age_ilev);
age_tmp = age_tmp./nanmax(age_tmp);
X(:,end+1) = age_tmp';

xnames{end+1} = 'Volume';
[vol,vol_ilev] = getProstateVolume(O);
vol_tmp = vol_ilev - nanmin(vol_ilev);
vol_tmp = vol_tmp./nanmax(vol_tmp);
X(:,end+1) = vol_tmp';

xnames{end+1} = 'Arterialhypertension';
X = [X,zeros(size(X,1),1)];
X(get(O,'Arterialhypertension')==1,end) = 1;

xnames{end+1} = 'Schilddruesenproblem';
X = [X,zeros(size(X,1),1)];
X(get(O,'Schilddruesenproblem')==1,end) = 1;

xnames{end+1} = 'Melanoma';
X = [X,zeros(size(X,1),1)];
X(get(O,'Melanoma')==1,end) = 1;

xnames{end+1} = 'Diabetes';
X = [X,zeros(size(X,1),1)];
X(get(O,'Diabetes')==1,end) = 1;

xnames{end+1} = 'Renalproblem';
X = [X,zeros(size(X,1),1)];
X(get(O,'Renalproblem')==1,end) = 1;

xnames{end+1} = 'Colorectalcancer';
X = [X,zeros(size(X,1),1)];
X(get(O,'Colorectalcancer')==1,end) = 1;

xnames{end+1} = 'Pleuralproblem';
X = [X,zeros(size(X,1),1)];
X(get(O,'Pleuralproblem')==1,end) = 1;

%% Now select predictors based on option:
switch(option)
    case 'all' % all except other ailments
        use = {'LR','HR','PSA_0-1','PSA>10','TumorStage_0-1','pT3,pT4','GleasonScore_0-1','Age','Volume','Batch2','Diabetes','Renalproblem'};        
        [~,~,iuse] = intersect(use,xnames);
        xnames = xnames(iuse);
        X = X(:,iuse);        
        
    case 'ailments'
        use = {'Arterialhypertension','Schilddruesenproblem','Melanoma','Diabetes','Renalproblem','Colorectalcancer','Pleuralproblem','Batch2'};        
        [~,~,iuse] = intersect(use,xnames);
        xnames = xnames(iuse);
        X = X(:,iuse);        
        
    case 'onlyDiabetes'
        use = {'Diabetes'};        
        [~,~,iuse] = intersect(use,xnames);
        xnames = xnames(iuse);
        X = X(:,iuse);        

    case 'onlyRenal'
        use = {'Renalproblem'};        
        [~,~,iuse] = intersect(use,xnames);
        xnames = xnames(iuse);
        X = X(:,iuse);        

    case 'only_pT3,pT4'
        use = {'pT3,pT4'};        
        [~,~,iuse] = intersect(use,xnames);
        xnames = xnames(iuse);
        X = X(:,iuse);        

    case 'onlyPSA>10'
        use = {'PSA>10'};        
        [~,~,iuse] = intersect(use,xnames);
        xnames = xnames(iuse);
        X = X(:,iuse);        
        
    case 'onlyAge'
        use = {'Age'};        
        [~,~,iuse] = intersect(use,xnames);
        xnames = xnames(iuse);
        X = X(:,iuse);        
        
    case 'onlyVolume'
        use = {'Volume'};        
        [~,~,iuse] = intersect(use,xnames);
        xnames = xnames(iuse);
        X = X(:,iuse);        
        
    case 'onlyBatch'
        use = {'Batch2'};        
        [~,~,iuse] = intersect(use,xnames);
        xnames = xnames(iuse);
        X = X(:,iuse);        
        
    case 'onlyPSA'
        use = {'PSA_0-1'};        
        [~,~,iuse] = intersect(use,xnames);
        xnames = xnames(iuse);
        X = X(:,iuse);        
        
    case 'onlyTumorStage'
        use = {'TumorStage_0-1'};        
        [~,~,iuse] = intersect(use,xnames);
        xnames = xnames(iuse);
        X = X(:,iuse);        
        
    case 'onlyGleason'
        use = {'GleasonScore_0-1'};        
        [~,~,iuse] = intersect(use,xnames);
        xnames = xnames(iuse);
        X = X(:,iuse);        
        
    case 'onlyCancer'
        use = {'Cancer'};
        [~,~,iuse] = intersect(use,xnames);
        xnames = xnames(iuse);
        X = X(:,iuse);

    case 'onlyHRLR'
        use = {'LR','HR'};
        [~,~,iuse] = intersect(use,xnames);
        xnames = xnames(iuse);
        X = X(:,iuse);

        
    case 'PSA'
        use = {'PSA_0-1','Age','Batch2','Renalproblem','Diabetes'};        
        [~,~,iuse] = intersect(use,xnames);
        xnames = xnames(iuse);
        X = X(:,iuse);        
        
    case 'TumorStage'
        use = {'TumorStage_0-1','Age','Batch2','Renalproblem','Diabetes'};        
        [~,~,iuse] = intersect(use,xnames);
        xnames = xnames(iuse);
        X = X(:,iuse);        
        
    case 'Gleason'
        use = {'GleasonScore_0-1','Age','Batch2','Renalproblem','Diabetes'};        
        [~,~,iuse] = intersect(use,xnames);
        xnames = xnames(iuse);
        X = X(:,iuse);        
        
    case 'HRLR'
        use = {'LR','HR','Age','Batch2','Renalproblem','Diabetes'};
        [~,~,iuse] = intersect(use,xnames);
        xnames = xnames(iuse);
        X = X(:,iuse);

    case 'Cancer'
        use = {'Cancer','Age','Batch2','Renalproblem','Diabetes'};
        [~,~,iuse] = intersect(use,xnames);
        xnames = xnames(iuse);
        X = X(:,iuse);


    otherwise
        error('option %s unknown',option)
end

[runi,ia,grouplevels] = unique(X,'rows');

figure(123)
imagesc(X);
colorbar
cm = colormap('gray');
colormap(cm(end:-1:1,:)); % inverse direction
set(gca,'YTick',1:size(X,1),'YTickLabel',strrep(snames,'_','\_'),...
    'XTick',1:size(X,2),'XTickLabel',strrep(xnames,'_','\_'),'FontSize',8);
if size(X,1)>50
    set(gca,'FontSize',6);
end
print -dpng DefineX

