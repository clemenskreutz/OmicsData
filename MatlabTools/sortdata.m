
function O = sortdata(O,which)

%plotsortdata(O)
if ~exist('which','var')
    which='colcol';
end

dat = get(O,'data');
datnan = isnan(dat);

if contains(which,'col')
    [~,idxcol] = sort(sum(datnan));
    dat = dat(:,idxcol);
    O = set(O,'index_sortcol',idxcol);
    O = set(O,'data',dat,'Sorted by #nan in column.');
    O = set(O,'data_mis',dat); 
    dat_full = get(O,'data_full');
    dat_full = dat_full(:,idxcol);
    O = set(O,'data_full',dat_full);
end
if contains(which,'row')
    [~,idxrow] = sort(sum(datnan,2));
    dat = dat(idxrow,:);
    O = set(O,'index_sortrow',idxrow);   
    O = set(O,'data',dat,'Sorted by #nan in row.');
    O = set(O,'data_mis',dat); 
    dat_full = get(O,'data_full');
    dat_full = dat_full(idxrow,:);
    O = set(O,'data_full',dat_full);
end

%%
% figure
% subplot(1,2,1)
% imagesc(dat)
% subplot(1,2,2)
% imagesc(datsortcol)