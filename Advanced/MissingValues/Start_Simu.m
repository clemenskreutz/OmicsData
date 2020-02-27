
set(0,'DefaultFigureVisible','off')

npep = 1000;
rep = 20;
mv = 50:-5:5;
nr = 100:-10:0;
mu = 1.5;
sigP = 0.5;
sigG = 0.5;
sige = 0.5;
nsimu = 1;

methods = {'impSeq','missForest','SVDImpute','imputePCA','SVTImpute','irmi','bpca','ppca','MIPCA','kNNImpute','impSeqRob','knn','QRILC','nipals','MinProb','ri','rf','sample','pmm','svdImpute','norm','cart','softImpute','MinDet','amelia','regression','midastouch','mean','aregImpute','nlpca'};

if exist('full.mat','file')
    load('full.mat')
else
    full = SimuData(npep,rep,mu,sigP,sigG,sige);
    save('full.mat','full')
end
t = [];
for j=1:length(nr)
    for i=1:length(mv)
        for k=1:nsimu

            % Simu MV
            file = ['PaperSome' num2str(npep) 'MV' num2str(mv(i)) 'MNAR' num2str(nr(j))];
            data = SimuMV(full,mv(i),nr(j),file);

            % best imputation for complete data
             O = OmicsData(data,['Data/' file]);
             O = set(O,'data_complete',full);
             O = impute(O,methods);
             saveO(O,[],['O_full_' num2str(k)]);

            % best imputation for simulated data with MNAR/MCAR
            tic
            O = OmicsData(data,['Data/' file]);
            O = DIMA(O);
            O = impute(O,methods,[],true);
            O = set(O,'time',toc);
            saveO(O,[],['O_' num2str(k)])
        end
    end
end
t
GetRank
