clear all
close all

global O

%% Load data
file = 'Data/dataset01_yeast_oxICAT.xlsx';
%file = 'Data/dataset02_tbrucei_ATOM_depletome_proteins_christian.txt'; % 51 rows completely missing, other rows non at all missing
%file = 'Data/dataset03_mouse_comparison_of_cell_lines_proteins_lena.xlsx';

O = OmicsData(file);

% Wrote it here so everybody sees it. Sometimes 0s are missing/notmeasured values. Sometimes they are just 0.
% Look at your data. And Uncomment if so.
dat = get(O,'data');
dat(dat==0) = nan;  
O = set(O,'data',dat,'Replaced 0 by nan.');

if  strcmp(file,'Data/dataset02_tbrucei_ATOM_depletome_proteins_christian.txt')
    O = O(:,1:size(get(O,'data'),2)-1);                                                       % last column nans
end
if  strcmp(file,'Data/dataset03_mouse_comparison_of_cell_lines_proteins_lena.xlsx')
    O = O(:,7:size(get(O,'data'),2));                                                         % first rows ?
else
    O=log10(O);                                                                               % dataset3 is logged, the others not
end

O = O(1:1000,:); % shorten for experimenting


%% Plot overview of data matrix
%plotdata
    
%% Evaluate missing pattern
analysemissing

%% imputation
%imputation_mat; % matlab imputation methods

%% save output
output(O);
