clear all
close all

% 4000 si = 0.5 sigcon = 2.6
% 4001 sig =sigcon = 1
% Assign variables
%pep = [3000,5000,10000,15000]; % proteinGroups: 3057x10, peptides: 14382x11, chrisianATOM: 3994x56, christianYEAST: 9101x30, lenaMOUSE: 3166x12
%rep = [10,30,50];
pep = 4000;
rep = 12;
mv = [5,10,15,20,25,30,35,40,45,50];
nr = [80,70,60,50,40,30,20,10,0,90,100];
mu = 24;
sigP = 0.5;
sigG = 2.5;

methods = {'impnorm','knn','mean','norm','ri','pmm','sample','cart','midastouch','rf','Amelia','regression','ppca','bpca','nipals','svdImpute', ...
    'MinDet','MinProb','QRILC','SVTImpute','SVDImpute','kNNImpute','missForest','softImpute','irmi','Norm','Seq','SeqRob','MIPCA','imputePCA'};

set(0,'DefaultFigureVisible','off')
t=[];
for j=1:length(nr)
    for i=1:length(mv)

        if nr(j)<10
            MNAR = ['0' num2str(nr(j))];
        else
            MNAR = num2str(nr(j));
        end
        if mv(i)<10
            MV = ['0' num2str(mv(i))];
        else
            MV = num2str(mv(i));
        end

        file = ['SimuPep' num2str(pep) 'MV' num2str(MV) 'MNAR' num2str(MNAR)];
        [full, data] = SimuDataLazar(pep,rep,mv(i),nr(j),mu,sigP,sigG,true,file);
        
        % best imputation for complete data
        O = OmicsData(data,['Data/' file]);
        O = set(O,'data_complete',full);
        O = Impute(O,methods);
        saveO(O,[],'O_full');

        % best imputation for simulated data with MNAR/MCAR
        tic
        O = OmicsData(data,['Data/' file]);
        O = DIMA(O);
        O = Impute(O,methods);
        saveO(O)
        t(end+1) = toc  
        PlotImputation(O)
    end
end
t



%t =  1.0e+03 * [ 0    1.3200    0.8109    0.6335    0.5600    0.5382    0.5270    0.4350    0.3824    0.3674 1.1521    0.8125    0.6285    0.5729    0.5419    0.5245    0.4632    0.3233    0.2862    1.1565     0.8158    0.6245    0.5698    0.5417    0.5336    0.4967    0.4250    0.3852    1.2061    0.8102     0.6469    0.5659    0.5560    0.5224    0.4981    0.3943    0.3531    1.0896    0.7792    0.6255 0.5795    0.5466    0.5203    0.4489    0.2990    0.3700];

    