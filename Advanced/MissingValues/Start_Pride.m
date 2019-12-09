clear all
close all

files = dir('PrideData_new/**/*proteinGroups*.txt');         % Load proteinGroups.txt
set(0,'DefaultFigureVisible','off')                 % dont show figures (saved anyway)
t=[];

methods = {'impnorm','knn','mean','norm','ri','pmm','sample','cart','midastouch','rf','Amelia','aregImpute','regression','ppca','bpca','nipals','nlpca','svdImpute', ...
    'MinDet','MinProb','QRILC','SVTImpute','SVDImpute','kNNImpute','missForest','softImpute','irmi','Norm','Seq','SeqRob','MIPCA','imputePCA'};

for i=169%1:70%:length(files)      % 70-77 % 78 Beispiel datensatz % 96/152/153/169 funzt nicht % 189:190 fehlt noch
    tic
    if i==96 || i==152 || i==153 || 169
        continue
    end
    i
    O = OmicsData([files(i).folder '\' files(i).name]); % Write in class O    
    if size(O,2)>100
        continue
    end
    %% Logged?
    if max(O)>100                                % data not logged yet? Log!
        O=log2(O);   
    end
    %% Nans?
    if ~checknan(O)                                  % no nans in data, so write zeros as nans
        dat = get(O,'data');                          
        dat(dat==0) = nan;  
        O = set(O,'data',dat,'Replaced 0 by nan.');
    end
    O = O(:,~all(isnan(O)));                      % delete columns/experiments with all nan
    O = O(:,sum(isnan(O))/size(O,1)<=0.9);
    if get(O,'nsamples')>1
        
        [O,out] = DIMA(O);
        O = impute(O,methods);
        O = GetPerformance(O,true,false);

    else
        delete([files(i).folder filesep files(i).name(1:end-4) '.mat']);
    end
    t(i) = toc
end
t
%1.0e+03 *[ 0.5463    0.6262   0.5675    1.4647 ] 239.8