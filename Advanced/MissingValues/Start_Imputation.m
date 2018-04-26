clear all
close all

global O

%% Load data
%file = 'Data/dataset01_yeast_oxICAT.xlsx';
%file = 'Data/dataset02_tbrucei_ATOM_depletome_proteins_christian.txt';
file = 'Data/dataset03_mouse_comparison_of_cell_lines_proteins_lena.xlsx';

O = OmicsData(file);

if  strcmp(file,'Data/dataset02_tbrucei_ATOM_depletome_proteins_christian.txt')
    O = O(:,1:size(get(O,'data'),2)-1);
end
if  strcmp(file,'Data/dataset03_mouse_comparison_of_cell_lines_proteins_lena.xlsx')
    O = O(:,7:size(get(O,'data'),2));
end

% Wrote it here so everybody sees it. Sometimes 0s are missing/notmeasured values. Sometimes they are just 0.
% Look at your data. And Uncomment if so.
dat = get(O,'data');
dat(dat==0) = nan;  
O = set(O,'data',dat,'Replaced 0 by nan.')

%% Plot overview of data matrix
%plotdata
    
%% Evaluate missing pattern
analysemissing

%% imputation
T = imputation;

%% save output
% output(O,file,'NotSorted');

