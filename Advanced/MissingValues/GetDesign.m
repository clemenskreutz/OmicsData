
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

% mean to X
m = nanmean(O,2);
m = (m-nanmean(m))./nanstd(m);
m = m*ones(1,size(isna,2)); 
X = m(:);
bnames{c} = 'mean';
type(c) = 1; % mean-dependency

% mean linearized to X
% mlin = feval(out.mean_trans_fun,m,out.lincoef); 
% mlin = mlin*ones(1,size(isna,2)); 
% X = [X, mlin(:)];
% c=c+1;
% bnames{c} = 'linmean';
% type(c) = 6; % mean-dependency

% Peptide counts to X
pep = get(O,'Peptides',true);
if ~isempty(pep)
    %pep = (pep-nanmean(pep))./nanstd(pep);
    if 2*size(pep,2)==size(isna,2)
        pep = [pep, pep];
    elseif 2*size(pep,2)+1==size(isna,2)
        pep = [pep, pep, ones(size(pep,1),1)];
    elseif size(pep,2)==1
        pep = pep*ones(1,size(isna,2));
    elseif size(pep,2)~=size(isna,2) && size(pep,2)~=1
        return
    end
    pep(isnan(pep)) = 0;
    X = [X, pep(:)];
    c=c+1;
    bnames{c} = 'Peptides';
    type(c) = 4;
end

% Sequence coverage to X
seq = get(O,'SequenceCoverage___',true);
if exist('seq','var') && ~isempty(seq)
    seq(isnan(seq)) = 0;
    if size(seq,2)==1
        seq = seq*ones(1,size(isna,2));
    end
    X = [X, seq(:)];
    c=c+1;
    bnames{c} = 'SequenceCoverage';
    type(c) = 5;
end

% Intensity
Int = get(O,'Intensity',true);
if exist('Int','var') && ~isempty(Int)
    Int = (Int-nanmean(Int))./nanstd(Int);
    Int = Int*ones(1,size(isna,2));
    X = [X, Int(:)];
    c=c+1;
    bnames{c} = 'Intensity';
    type(c) = 6;
end
% iBAQ
iBAQ = get(O,'iBAQ',true);
if exist('iBAQ','var') && ~isempty(iBAQ)
    iBAQ = (iBAQ-nanmean(iBAQ))./nanstd(iBAQ);
    iBAQ = iBAQ*ones(1,size(isna,2));
    X = [X, iBAQ(:)];
    c=c+1;
    bnames{c} = 'iBAQ';
    type(c) = 7;
end
% Score
Score = get(O,'Score',true);
if exist('Score','var') && ~isempty(Score)
    Score = Score*ones(1,size(isna,2));
    X = [X, Score(:)];
    c=c+1;
    bnames{c} = 'Score';
    type(c) = 8;
end
% Q_value
Q_value = get(O,'Q_value',true);
if exist('Q_value','var') && ~isempty(Q_value)
    Q_value = Q_value*ones(1,size(isna,2));
    X = [X, Q_value(:)];
    c=c+1;
    bnames{c} = 'Q_value';
    type(c) = 9;
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
