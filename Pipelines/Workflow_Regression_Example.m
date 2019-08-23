restoredefaultpath
clear all

addpath('E:\clemens\Repositories\OmicsData');
OmicsInit

%%
% [num,txt,raw] = xlsread('../Daten/proteinGroups-urine-Pca-_fur-Clemens_ck.xlsx');
O = OmicsData('../Daten/proteinGroups-urine-Pca-_fur-Clemens_ck.xlsx','Raw',1,'ba');
O = log2(O);
O = OmicsAddSamplenames(O,'na');
O = OmicsRenameSamples(O,{'ba','_tch'},{'','_batch'});

[num,txt,raw] = xlsread('../Daten/Klinische Infos f OS_ck.xlsx');
raw = cell2cell(raw,1);
O = OmicsAddSampleAnnotation(O,raw,1);

ids = get(O,'Genenames');
fnames = get(O,'fnames');
for i=1:length(ids)
    if ~isempty(ids{i})
        fnames{i} = ids{i};
        if length(fnames{i})>20
            fnames{i} = fnames{i}(1:20);
        end
    end
end
O = set(O,'fnames',fnames);
o = struct(O);
save O O o

%% Options (i.e. configuration) of the regression workflow:
% the first option is always the default
opt = struct;

opt.data.NaN_FilterThreshold = {.5, 3};
opt.data.NormalizationMethod = {'OmicsMbqn','none'};
opt.data.FilterSamples = {'none'};  
opt.data.Imputation    = {'OmicsMice','none','OmicsMice2','OmicsMice3'};

opt.ana.Design = {'Cancer','onlyCancer'};  % these options have to be handelled by defineX.m 
opt.ana.Regularization = [0.5,0];

opt.out.pr   = {'Cancer'};% which p-values are written in the output file
opt.out.fold = {'Cancer'};% which fold-changes are written in the output file
opt.out.fdrr = {'Cancer'};% which FDRs are written in the output file

res = struct;
res.opts.data = all_combinations(opt.data,0);  % 0 means only default plus one alternative option
res.opts.ana  = all_combinations(opt.ana,0); % 0 means only default plus one alternative option
res.opts.out  = opt.out;

res = Workflow_Regression_core(O,res);
save res res


%% Clustering
d = 1; % 1st data set
a = 1; % 1st analysis
interestingX = setdiff(fieldnames(res.out.pr),'label');

xConfounder = setdiff(res.data{d}.ana.xnames{a},interestingX)
[~,ix] = intersect(res.data{d}.ana.xnames{a},interestingX)

indsig = find(sum(res.data{d}.ana.pr{a}(:,ix)<=0.01 & abs(res.data{d}.ana.foldr{a}(:,ix))>=log2(1.5),2)>0);
ClusterLarge(O2E(res.data{d}.O(indsig,:)),'Significant',2);
%% Clustering based on adjusted data
OAdj = OmicsAdjust(res.data{d}.O,res.data{d}.ana.X{a}(:,ix),res.data{1}.ana.foldr{a}(:,ix),true);
ClusterLarge(O2E(OAdj(indsig,:)),'Significant_Adjusted',2);

%%
save Workflow_Regression_Example

