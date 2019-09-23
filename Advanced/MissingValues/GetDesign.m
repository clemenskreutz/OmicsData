
function [X,y,type,bnames] = GetDesign(O,out)

if ~exist('out','var') || isempty(out)
    error('GetDesign: Perform LearnPattern before GetDesign(O,out) to get out.')
end

% response vector
isna = isnan(O);
y = isna(:);

% Shape & initialize
row  = ((1:size(isna,1))') * ones(1,size(isna,2));
row  = row(:);
col  = ones(size(isna,1),1)*(1:size(isna,2));
col  = col(:);
rlev = levels(row);
clev = levels(col);
type = NaN(1+length(rlev)+length(clev),1);
bnames = cell(length(rlev)+length(clev)+1,1);
c = 1;

% % mean to X
m = nanmean(O,2);
m = (m-nanmean(m))./nanstd(m);
m = m*ones(1,size(isna,2)); 
X = m(:);
bnames{c} = 'mean';
type(c) = 1; % mean-dependency

% mean linearized to X
mlin = feval(out.mean_trans_fun,m(:,1),out.lincoef); 
mlin = mlin*ones(1,size(isna,2)); 
%X = mlin(:);
X = [X, mlin(:)];
c=c+1;
bnames{c} = 'linmean';
type(c) = 100; % mean-dependency

% Predictors from O.cols
pred = fieldnames(get(O,'cols'));
for i=1:length(pred)
    predvec = get(O,pred{i},true);
    if isnumeric(predvec) && ~length(unique(predvec))==1
        predvec = (predvec-nanmean(predvec))/nanstd(predvec);
        predvec = predvec*ones(1,size(isna,2));
        X = [X, predvec(:)];
        c=c+1;
        bnames{c} = pred{i};
        type(c) = 4;
    end
end

% Predictors from O.data Important! Counts and Sequences
pred = fieldnames(getfield(O,'data'));  % get(O,'data') is the default data matrix
for i=1:length(pred)
    predmat = get(O,pred{i},true);
    if isnumeric(predmat) && size(predmat,1)+size(predmat,2)==size(X,1)
        predmat = (predmat-nanmean(predmat(:)))./nanstd(predmat(:));
        X = [X, predmat(:)];
        c=c+1;
        bnames{c} = pred{i};
        type(c) = 5;
    end
end
X = [X,zeros(size(X,1),length(rlev)+length(clev))];

% Col to X
for i=1:length(clev)
    c = c+1;
    X(col==clev(i),c) = 1;
    bnames{c} = ['Column',num2str(i)];
    type(c) = 2; % column-dependency
end
% Row to X
for i=1:length(rlev)
    c = c+1;
    X(row==rlev(i),c) = 1;
    bnames{c} = ['Row',num2str(i)];
    type(c) = 3; % row-dependency
end
bnames = erase(bnames,'_');

% If significance too low, remove columns
% was used in test cases, but not used anymore
if isfield(out,'idxrem')
    if length(clev)+length(rlev)+max(out.idxrem)<=size(X,2)
        X(:,out.idxrem) = []; % offset is ignored, so idxrem=1 means mean
        bnames(out.idxrem) = [];
        type(out.idxrem) = [];
    else
        warning('Design matrix consists of all predictors found in the xls. No removing due to significance performed. \n Check size of X at the end of GetDesign.m to change this.')
    end    
end