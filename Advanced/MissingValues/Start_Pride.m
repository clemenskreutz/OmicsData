clear all
close all
set(0,'DefaultFigureVisible','off')  

files = dir('PrideData_new/**/*proteinGroups*.txt');         % Load proteinGroups.txt
methods = {'impSeq','missForest','SVDImpute','imputePCA','SVTImpute','irmi','bpca','ppca','MIPCA','kNNImpute','impSeqRob','knn','QRILC','nipals','MinProb','ri','rf','sample','pmm','svdImpute','norm','cart','softImpute','MinDet','amelia','regression','midastouch','mean','aregImpute','nlpca'};

for i=[7:7:21]%:length(files)      % 70-77 % 78 Beispiel datensatz % 96/152/153/169 funzt nicht % 189:190 fehlt noch
    
    if i==96 || i==152 || i==153 || i==169
        continue
    end
    i
    tic
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

    O = DIMA(O);
    %O = impute(O,methods);
    %O = GetPerformance(O,true,false);
    O = set(O,'time',toc);
    saveO(O,[],'ODima')
        
end