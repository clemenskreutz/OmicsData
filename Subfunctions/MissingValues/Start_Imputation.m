clear all
close all

%% Load data
file = 'Data/dataset01_yeast_oxICAT.xlsx';
% file = 'Data/dataset02_tbrucei_ATOM_depletome_proteins_christian.txt';
% file = 'Data/dataset03_mouse_comparison_of_cell_lines_proteins_lena.xlsx';

O = OmicsData(file);
    if  strcmp(file,'Data/dataset02_tbrucei_ATOM_depletome_proteins_christian.txt')
        dat(:,end) = [];
    %     O = O(:,1:(end-1));
        O = set(O,'data',dat,'Delete last column');
        names = get(O,'SampleNames');
        O = set(O,'SampleNames',names(1:end-1),'Delete last column');
    end

%% Evaluate data
plotdata(O)
O = assignmissing(O,5);
% O = imputation_clear(O);
CompareImputationMethods
% p = imputation_anova(O);
imputation_boxplot(O);
T = imputation_analysis(O);

%% save output
output(O,file,'ImpMethods');