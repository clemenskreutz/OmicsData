
function [X,y,type,bnames] = GetDesign(O,out)

if ~exist('out','var') || isempty(out)
    error('GetDesign: Perform LearnPattern before GetDesign(O,out) to get out.')
end

% response vector
isna = isnan(O);
y = isna(:);

% Mean
m = nanmean(O,2);
m = (m-nanmean(m))./nanstd(m); % standardized
mlin = feval(out.mean_trans_fun,m,out.lincoef); 

% Peptides
pep = get(O,'Peptides');
if ~isempty(pep)
    %pep = (pep-nanmean(pep))./nanstd(pep);
    if 2*size(pep,2)==size(isna,2)
        pep = [pep, pep];
    elseif 2*size(pep,2)+1==size(isna,2)
        pep = [pep, pep, ones(size(pep,1),1)];
    elseif size(pep,2)==1
        pep = pep*ones(1,size(isna,2));
    elseif size(pep,2)~=size(isna,2) && size(pep,2)~=1
        pep = [];
    end
    pep(isnan(pep)) = 0;
end

% Sequence coverage
seq = get(O,'SequenceCoverage___');
if exist('seq','var') && ~isempty(seq)
    seq(isnan(seq)) = 0;
    if size(seq,2)==1
        seq = seq*ones(1,size(isna,2));
    end
end

% Intensity
Int = get(O,'Intensity');
Int = (Int-nanmean(Int))./nanstd(Int);
Int = Int*ones(1,size(isna,2));
iBAQ = get(O,'iBAQ');
iBAQ = (iBAQ-nanmean(iBAQ))./nanstd(iBAQ);
iBAQ = iBAQ*ones(1,size(isna,2));
Score = get(O,'Score');
Score = Score*ones(1,size(isna,2));
Q_value = get(O,'Q_value');
Q_value = Q_value*ones(1,size(isna,2));

% Shape & initialize row/col input
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
m = m*ones(1,size(isna,2)); 
X = m(:);
bnames{c} = 'mean';
type(c) = 1; % mean-dependency

% mean to X
% mlin = mlin*ones(1,size(isna,2)); 
% X = [X, mlin(:)];
% c=c+1;
% bnames{c} = 'linmean';
% type(c) = 6; % mean-dependency

% Peptide counts to X
% if exist('pep','var') && ~isempty(pep)
%     X = [X, pep(:)];
%     c=c+1;
%     bnames{c} = 'Peptides';
%     type(c) = 4;
% end

% Sequence coverage to X
if exist('seq','var') && ~isempty(seq)
    X = [X, seq(:)];
    c=c+1;
    bnames{c} = 'SequenceCoverage';
    type(c) = 5;
end

% Intensity
% if exist('Int','var') && ~isempty(Int)
%     X = [X, Int(:)];
%     c=c+1;
%     bnames{c} = 'Intensity';
%     type(c) = 6;
% end
% % iBAQ
% if exist('iBAQ','var') && ~isempty(iBAQ)
%     X = [X, iBAQ(:)];
%     c=c+1;
%     bnames{c} = 'iBAQ';
%     type(c) = 7;
% end
% Score
if exist('Score','var') && ~isempty(Score)
    X = [X, Score(:)];
    c=c+1;
    bnames{c} = 'Score';
    type(c) = 7;
end
% Q_value
if exist('Q_value','var') && ~isempty(Q_value)
    X = [X, Q_value(:)];
    c=c+1;
    bnames{c} = 'Q_value';
    type(c) = 7;
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
