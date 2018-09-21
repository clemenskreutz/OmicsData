clear all
close all
global O

%% File
file = 'Data/dataset01_yeast_oxICAT.xlsx';
%file = 'Data/dataset02_tbrucei_ATOM_depletome_proteins_christian.txt'; % 51 rows completely missing, other rows non at all missing
%file = 'Data/dataset03_mouse_comparison_of_cell_lines_proteins_lena.xlsx';

% Load data
[filepath,name] = fileparts(file);
if exist([filepath '/' name '/O.mat'],'file') 
    load([filepath '/' name '/O.mat']) 
else
    error('You first have to run Start_MissingPattern.m')
end


%% Delete previous imputations ?
imputation_clear

%% DMwR
lib= 'DMwR';
methods = 'knn';
impute_R(lib,methods);

%% Hmisc
lib= 'Hmisc';
methods = {'pmm','regression'};
impute_R(lib,methods);

%% MICE
lib= 'mice';
%methods = 'cart';
methods = {'pmm','midastouch','sample','cart','rf','mean','norm','ri'};
impute_R(lib,methods)

%% Amelia
lib= 'Amelia';
impute_R(lib);

%% missForest
lib= 'missForest';
impute_R(lib);


%% Plot
imputation_analysis;
