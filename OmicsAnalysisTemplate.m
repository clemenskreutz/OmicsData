%% This script indicates basic steps for using the @OmicsData library

%% Initialization
clear all
close all

OmicsInit; % initialize

addpath('E:\clemens\Repositories\OmicsData\Data\PXD000485\MaxQuantOutputValidationDataset') % add a path to the folder where the data is located.

%% Load Data, perform log-transformation and normalization:
file = 'proteinGroups.txt';
O = OmicsData(file)
O = log2(O);

hist(O)

Onorm = quantilenorm(O);
figure
boxplot(Onorm)

%%  now perform the statistical analysis
X = ones(get(O,'nsamples'),2);
X(1:3,2) = 0;  % Design matrix testing the remaining samples against the first 3 samples

p = regress(O,X);
hist(p)

