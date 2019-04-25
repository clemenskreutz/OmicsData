
function algo = GetRankTable

global O

%% Get
method = get(O,'method_imput');
Table = get(O,'Table');
Table = Table(:,2:end,:); % clear 0 first column
boot = get(O,'boot');

%% find lowest rank
idx = ones(boot,size(Table,2))*30;    
idboot = zeros(boot,size(Table,2));
for b=1:boot
    [~,idx(b,:)] = sort(Table(6,:,b),'MissingPlacement','last'); 
    idboot(b,idx(b,:)) = 1:size(Table,2);
end
[~,idxrank] = sort(sum(idboot),2,'MissingPlacement','last'); 

T = nanmean(Table(5:9,idxrank,:),3);
algo = method(idxrank);

O = set(O,'RankTable',T);
O = set(O,'RankMethod',algo);
path = get(O,'path');
save([path(1:end-4) '/RankTable.mat'],'T','algo')
