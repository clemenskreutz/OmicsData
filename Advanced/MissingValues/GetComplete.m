%  O = GetComplete(O)
%
%  delete all features with (many) MV
%
%  if less than 50 features have no MV, one MV per feature is allowed
%  if less than 50 features have one MV, two MVs per feature are allowed
%  ...
%
%  O - @OmicsData object

function O = GetComplete(O)

if ~exist('O','var')
    error('MissingValues/GetComplete.m requires class O as input argument.')
end

% Save original
O = set(O,'data_original',[]);          % Put in container so it stays original (always same size)  
dat = get(O,'data');
O = set(O,'data_original',dat,'Original dataset');

nasum = sum(isnan(dat),2);
[~,idxnan] = sort(nasum);
O = O(idxnan,:);

cut = 0.5;
cut = (size(O,1)-sum(nasum==size(dat,2)))./size(O,1).*cut;
idx1 = 1:floor(length(idxnan)*cut);                                     % indices till cut
idx2 = floor(length(idxnan)*cut)+1:size(O,1);     % indices cut to end (without all NaN rows)
O2 = O(idx1,:);                                                         % take first cut% of dataset as it is

idxnew = [];
while length(idxnew)<length(idx2)
    if length(idxnew)+length(idx1)<=length(idx2)
        idxnew = [idxnew, idx1];
    else
        idxnew = [idxnew, randsample(length(idx1),length(idx2)-length(idxnew))'];
    end
end
O2 = [O2; (O(idxnew,:)-nanmean(O(idxnew,:),2))./nanstd(O(idxnew,:),[],2)*nanstd(O(idx2,:),[],2)+nanmean(O(idx2,:),2)];

[~,idxnan] = sort(sum(isnan(O2),2));
O = O2(idxnan,:);

% remember complete dataset
dat = get(O,'data');
O = set(O,'data_complete',[]);          % Put in container so it stays same 
O = set(O,'data_complete',dat,'Complete dataset');
O = set(O,'data',dat,'Complete');
