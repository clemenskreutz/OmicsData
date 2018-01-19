
load('Data/dataset01_yeast_oxICAT/workspace.mat');
O1 = O;
load('Data/dataset01_yeast_oxICAT/NotSorted.mat');
clearvars -except O1 O
close all
imputation_boxplot(O1);
T1 = imputation_analysis(O1)

imputation_boxplot(O);
T = imputation_analysis(O)

