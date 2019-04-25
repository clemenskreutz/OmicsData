global O

files = dir('PrideData\**\*peptides*.txt');         % Load proteinGroups.txt
%load('PXDTable766.mat')
for i=2:length(files)
    
    O = OmicsData([files(i).folder '\' files(i).name]); % Write in class O
%     O = O(:,~all(isnan(O)));                      % delete columns\experiments with all nan
%     if max(O)>1000                                % data not logged yet? Log!
%         O=log10(O);  
%     end
%     if ~checknan(O)                                  % no nans in data, so write zeros as nans
%         dat = get(O,'data');                          
%         dat(dat==0) = nan;  
%         O = set(O,'data',dat,'Replaced 0 by nan.');
%     end
% 
%     dat = get(O,'data');    
%     d1 = size(dat,1);
%     d2 = size(dat,2);
%     rowfull = sum(all(~isnan(dat),2))./d1*100;
%     rownan = sum(all(isnan(dat),2))./d1*100;
%     sigp = nanmean(nanstd(dat,[],2));
%     sige = nanmean(nanstd(dat));
%     sigpmis = std(sum(isnan(dat))/size(dat,1));
%     sigemis = std(sum(isnan(dat),2)/size(dat,2));
%     dat = dat(:);

%     PXD{i} = folders{contains(folders,'PXD')};
%     %     folders = strsplit(files(i).folder,'\');
%      %% Table 
%     if i==1
%         T = table([d1; d2; sum(isnan(dat))/d1/d2*100; nanmean(dat); nanmedian(dat); nanstd(dat); sigp; sige; sigpmis; sigemis; rowfull; rownan; skewness(dat); nanmin(dat); nanmax(dat)]);
%         T.Properties.RowNames = {'#proteins','#Experiments','% mis','mean','median','std','stdp','stde','stdpmis','stdemis','rowfull','rownan','skew','min','max'};
%     else
%         T = [T table([d1; d2; sum(isnan(dat))/d1/d2*100; nanmean(dat); nanmedian(dat); nanstd(dat); sigp; sige; sigpmis; sigemis; rowfull; rownan; skewness(dat); nanmin(dat); nanmax(dat)]) ];
%     end
%     try
%         T.Properties.VariableNames(i) = PXD(i);
%     catch
%         T.Properties.VariableNames(i) = {[PXD{i} '_' num2str(sum(contains(T.Properties.VariableNames,PXD(i))))]};
%     end
end
%save('PXDpepTable.mat','T')

