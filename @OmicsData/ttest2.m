% [p,ci,stats] = ttest2(O,indg1,indg2,paired,varequal)
% 
%   T-test for testing equal means.
%   The function calls ttest2.m or (if paired==true) ttest.m
% 
%   O       @OmicsData
% 
%   indg1   indices indication samples of group1
% 
%   indg2   indices indication samples of group2
% 
%   paired  Should a paired t-test be applied
%           Default: false
% 
%   varequal    Should equal variance be assumed?
%           Default: true
% 
%   p       p-values (indicating significance of having different means)
% 
%   ci      confidence intervals for the difference of the means (see doc ttest2)
% 
%   stats   more details statistics (see doc ttest2)
%               stats.tstat
%               stats.df
%               stats.sd
% 
% Examples:
% [p,ci,stats] = ttest2(O,1:3,4:6);  % standard t-test
% 
% [p2,ci,stats] = ttest2(O,1:3,4:6,true);  % paired t-test
% 
% [p3,ci,stats] = ttest2(O,1:3,4:6,[],false);  % t-test with unequal variances
% 
% plotmatrix([p,p2,p3])

function [p,ci,stats] = ttest2(O,indg1,indg2,paired,varequal)
if nargin<3
    error('OmicsData/ttest2.m requires at least three arguments.')
end

if ~exist('paired','var') || isempty(paired)
    paired = false;
elseif paired
    if length(indg1)~=length(indg2)
        error('OmicsData/ttest2.m: Paired tests require the same number of replicates in both groups.')
    end
end

if ~exist('varequal','var') || isempty(varequal)
    varequal = true;
end

if ~isempty(intersect(indg1,indg2))
    error('OmicsData/ttest2.m: Both groups should not contain the same samples.')
end

dat = get(O,'data');
nf  = size(dat,1);  % number of features, e.g. number of proteins

p  = NaN(nf,1);
ci = NaN(nf,2);

for i=1:size(dat,1)
    if paired
        [~,p(i),ci(i,:),stat] = ttest(dat(i,indg1)-dat(i,indg2));
    else  % unpaired
        if varequal
            [~,p(i),ci(i,:),stat] = ttest2(dat(i,indg1),dat(i,indg2),'vartype','equal');
        else
            [~,p(i),ci(i,:),stat] = ttest2(dat(i,indg1),dat(i,indg2),'vartype','unequal');
        end
    end
    
    if i==1
        stats = stat;
    else
        stats(i) = stat;
    end
end

