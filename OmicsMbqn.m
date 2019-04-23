% O = OmicsMbqn(O)
% 
%   This function uses the MBQN r-package to normalize the data.
% 
%   nriThresh  NRI stands for nearly rank-invariance. It denotes the fraction of
%              samples, where a protein has the same rank.
%              The robust version of the quantile normalization is applied
%              for all proteins with RI>=RI_thresh
%              For the remaining ones, traditional quantilenorm is applied.
% 
%              [0.5] is the default value
%              1 leads to ordinary quantilenorm because there are no NRI
%              0 applies mbqn to all features because all are NRI

function O = OmicsMbqn(O,nriThresh,fun)
if ~exist('fun','var') || isempty(fun)
    fun = 'median';
end
if ~exist('nriThresh','var') || isempty(nriThresh)
    nriThresh = 0.5;
end

openR
global OPENR
OPENR.libraries{end+1} = 'MBQN';

putRdata('dat',get(O,'data'));
putRdata('fun',fun);
putRdata('nriThresh',nriThresh);
evalR('dat2 <- mbqnNRI(dat, low_thr=as.numeric(nriThresh), FUN=fun)');
dat2 = getRdata('dat2');

closeR

O = set(O,'data',dat2,'Normalization using the MBQN R-package.');


