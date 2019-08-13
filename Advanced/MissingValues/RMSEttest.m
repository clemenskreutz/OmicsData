function O = RMSEttest(O,indg1,indg2)

if ~exist('indg1','var') || isempty(indg1)
    warning('RMSEttest: No grouping indeces given. Separating data into 2 blocks by default. If you want to specify blocks, call RMSEttest(indg1,indg2) or imputation([],true,indg1,indg2).')
    s = size(O);
    indg1 = 1:round(s(2)/2);
end
if ~exist('indg2','var') || isempty(indg2)
    warning('RMSEttest: Grouping index indg2 of second group not given. Specify by RMSEttest(indg1,indg2).')
    s = size(O);
    indg2 = round(s(2)/2)+1:s(2);
end

% Get data
dat1 = get(O,'data_full');
dat1_mis = get(O,'data_mis');
dat1_imp = get(O,'data_imput');
T = get(O,'Table');

RMSEt = nan(size(dat1_imp,4),size(dat1_imp,3));
for b=1:size(dat1_imp,3)
    for m=1:size(dat1_imp,4)
        %  Set 2D matrices of method and bootstrap
        dat = dat1(:,:,b);
        dat_mis = dat1_mis(:,:,b);
        dat_imp = dat1_imp(:,:,b,m);

        % sort by nans
        [~,idx] = sort(sum(isnan(dat_mis),2));
        dat = dat(idx,:);
        dat_imp = dat_imp(idx,:);

        % delete empty rows
        dat = dat(~all(isnan(dat_imp),2),:);
        dat_imp = dat_imp(~all(isnan(dat_imp),2),:);

        for i=1:size(dat,1)
            [~,~,~,stat] = ttest2(dat(i,indg1),dat(i,indg2));
            [~,~,~,statm] = ttest2(dat_imp(i,indg1),dat_imp(i,indg2));
            t(i) = stat.tstat;
            tm(i) = statm.tstat;
        end

        RMSEt(m,b) = sqrt( nansum((t-tm).^2) /length(t));
    end
end
T(end+1,2:end,:) = RMSEt;
O = set(O,'Table',T);