function O = RMSEttest(O,varargin)

if size(O,2)<4
    warning(['ttest was not performed due to lack of samples. Matrix just has ' num2str(size(O,2)) ' columns.']);
    return
end

if exist('varargin','var') && ~isempty(varargin)
    if length(varargin)==1
        k = varargin{1};
    else
        indg1 = varargin{1};
        indg2 = varargin{2};
    end
else
    warning('No grouping indeces given for ttest. Separating data into 2 blocks by kmeans clustering. If you want to specify blocks or number of clusters, call RMSEttest(O,k) or RMSEttest(O,indg1,indg2) in GetPerformance(O).')
    k=2;
end

if exist('k','var')
    erg = clusterR(O,2,2);
%     comp = get(O,'data_complete');
%     idx = kmeans(comp',k);
    indg1 = erg.samplecluster==1;
    indg2 = erg.samplecluster==2;
end
%% instead of indg1, indg2, use idx(1,:) idx(2,:)
    
% Get data
dat1 = get(O,'data_complete');
dat1_mis = get(O,'data_mis');
dat1_imp = get(O,'data_imput');
if ~isfield(O,'Table',true)
    O = GetTable(O);
end
T = get(O,'Table');

RMSEt = nan(size(dat1_imp,4),size(dat1_imp,3));
for b=1:size(dat1_imp,3)
    for m=1:size(dat1_imp,4)
        %  Set 2D matrices of method and bootstrap
        dat = dat1;
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
        tm(isinf(tm)) = nan;
        RMSEt(m,b) = sqrt( sum((t-tm).^2,'omitnan') /length(t));
        if isinf(RMSEt(m,b))
            fprintf('Infinite value in RMSEttest.m')
        end
    end
end
T(end+1,2:end,:) = RMSEt;
O = set(O,'Table',T);