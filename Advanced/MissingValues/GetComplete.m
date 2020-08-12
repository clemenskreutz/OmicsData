%  O = GetComplete(O)
%
%  delete all features with (many) MV
%
%  if less than 50 features have no MV, one MV per feature is allowed
%  if less than 50 features have one MV, two MVs per feature are allowed
%  ...
%
%  O - @OmicsData object

function O = GetComplete(O,compcut)

if ~exist('O','var')
    error('MissingValues/GetComplete.m requires class O as input argument.')
end

% Save original
O = set(O,'data_original',[]);          % Put in container so it stays original (always same size)  
dat = get(O,'data');
O = set(O,'data_original',dat,'Original dataset');

Onnan = O(~all(isnan(O),2),:);
quar_isna = quantile(sum(isnan(Onnan),2),compcut);
O = O(sum(isnan(O),2)<=quar_isna,:);

if size(O,1)==size(dat,1)
    warning('Complete/Known matrix not feasible. Kept original matrix as data default.')
else
    idx = ceil(rand(size(dat,1)-size(O,1),1)*size(O,1));
   % O = [O; O(idx,:)+randn(size(idx)).*nanstd(O(idx,:))];
    residx = ceil(rand(size(dat,1)-size(O,1),1)*size(O,1));
    O = [O; (O(residx,:)-nanmean(O(residx,:)))./nanstd(O(residx,:))*nanstd(O(idx,:))+nanmean(O(idx,:))]; 
    %O = [O; (O(residx,:)+ O(idx,:))./2];
    %idx = ceil(rand(size(dat,1),1)*size(O,1));
    %residx = ceil(rand(size(dat,1),1)*size(O,1));
    %O = (O(residx,:)-nanmean(O(residx,:)))./nanstd(O(residx,:))*nanstd(O(idx,:))+nanmean(O(idx,:));
    O = scaleO(O,'original');
    %O = QuantileRescaling(O,dat);

end
% remember complete dataset
dat = get(O,'data');
O = set(O,'data_complete',[]);          % Put in container so it stays same 
O = set(O,'data_complete',dat,'Complete dataset');
O = set(O,'data',dat,'Complete');


%idx2 = randsample(size(O,1),size(dat,1)-size(O,1),true,sum(~isnan(O),2)/min(sum(~isnan(O),2)));
%O = [O; O(idx2,:) + nanstd(O(idx2,:)).*randn(length(idx2),size(O,2))];%/size(O,2);%sum(~isnan(O),2);
%dat = get(O,'data');
%O2 = O + dat*0.05.*randn(size(O)); 