
function [X,y,type,bnames] = GetDesign(O,out,sprs)

if ~exist('out','var') || isempty(out)
    error('GetDesign: Perform LearnPattern before GetDesign(O,out) to get out.')
end
if ~exist('sprs','var') || isempty(sprs)
    if size(O,2)>50
        sprs = true;
    else
        sprs = false;
    end
end

% response vector
isna = isnan(O);
y = isna(:);
dat = get(O,'data');

% Shape & initialize
row  = ((1:size(isna,1))') * ones(1,size(isna,2));
row  = row(:);
col  = ones(size(isna,1),1)*(1:size(isna,2));
col  = col(:);
rlev = levels(row);
clev = levels(col);
type = NaN(1+length(rlev)+length(clev),1);
bnames = cell(length(rlev)+length(clev)+1,1);
c = 0;

% % mean to X
m = nanmean(O,2);
m = (m-nanmean(m))./nanstd(m);
m = m*ones(1,size(isna,2)); 
if contains('nan',out.typesig) || contains('mean',out.typesig)
    X = m(:);
    c=c+1;
    bnames{c} = 'mean';
    type(c) = 1; % mean-dependency
end

% mean linearized to X
if contains('nan',out.typesig) || contains('linmean',out.typesig)
    mlin = feval(out.mean_trans_fun,m(:,1),out.lincoef); 
    mlin = mlin*ones(1,size(isna,2)); 
    if exist('X','var')
        X = [X, mlin(:)];
    else
        X = mlin(:);
    end
    c=c+1;
    bnames{c} = 'linmean';
    type(c) = 100; % mean-dependency
end

% % varianz to X
if contains('nan',out.typesig) || contains('median',out.typesig)
    v = nanmedian(dat,2);
    v = (v-nanmean(v))./nanstd(v);
    v = v*ones(1,size(isna,2)); 
    X = [X, v(:)];
    c=c+1;
    bnames{c} = 'median';
    type(c) = 99;
end

% % varianz to X
if contains('nan',out.typesig) || contains('var',out.typesig)
    v = var(dat,0,2,'omitnan');
    v = (v-nanmean(v))./nanstd(v);
    v = v*ones(1,size(isna,2)); 
    X = [X, v(:)];
    c=c+1;
    bnames{c} = 'var';
    type(c) = 101;
end

% % varianz to X
if contains('nan',out.typesig) || contains('range',out.typesig)
    v = range(dat,2);
    v = (v-nanmean(v))./nanstd(v);
    v = v*ones(1,size(isna,2)); 
    X = [X, v(:)];
    c=c+1;
    bnames{c} = 'range';
    type(c) = 102;
end

% % varianz to X
if contains('nan',out.typesig) || contains('iqr',out.typesig)
    r = iqr(dat,2);
    r = (r-nanmean(r))./nanstd(r);
    r = r*ones(1,size(isna,2)); 
    X = [X, r(:)];
    c=c+1;
    bnames{c} = 'iqr';
    type(c) = 103;
end


if contains('nan',out.typesig) || contains('skew',out.typesig)
    r = skewness(dat,1,2);
    r = (r-nanmean(r))./nanstd(r);
    r = r*ones(1,size(isna,2)); 
    X = [X, r(:)];
    c=c+1;
    bnames{c} = 'skew';
    type(c) = 104;
end

if contains('nan',out.typesig) || contains('z',out.typesig)
    r = (dat - nanmean(dat,2)) ./ nanstd(dat,[],2);
    r(isnan(r)) = 0;
    X = [X, r(:)];
    c=c+1;
    bnames{c} = 'z';
    type(c) = 105;
end

if contains('nan',out.typesig) || contains('z2',out.typesig)
    r = (dat - nanmean(dat(:))) ./ nanstd(dat(:));
    r(isnan(r)) = 0;
    X = [X, r(:)];
    c=c+1;
    bnames{c} = 'z2';
    type(c) = 106;
end

% Predictors from O.cols
pred = fieldnames(get(O,'cols'));
for i=1:length(pred)
    if contains('nan',out.typesig) || contains(pred{i},out.typesig)
        predvec = get(O,pred{i},true);
        if isnumeric(predvec) && ~strcmp(pred{i},get(O,'default_data'))
            predvec = (predvec-nanmean(predvec))/nanstd(predvec);
            predvec = predvec*ones(1,size(isna,2));
            if ~exist('X','var')
                X = predvec(:);
                c=c+1;
                bnames{c} = pred{i};
                type(c) = 4;
            elseif ~isequal(predvec(:),X(:,end)) 
                X = [X, predvec(:)];
                c=c+1;
                bnames{c} = pred{i};
                type(c) = 4;
            end
        end
    end
end

% Predictors from O.data Important! Counts and Sequences
pred = fieldnames(getfield(O,'data'));  % get(O,'data') is the default data matrix
for i=1:length(pred)
    if contains('nan',out.typesig) || contains(pred{i},out.typesig)
        predmat = get(O,pred{i},true);
        if isnumeric(predmat) && size(predmat,1)*size(predmat,2)==size(X,1) && ~strcmp(pred{i},get(O,'default_data'))
            predmat = (predmat-nanmean(predmat(:)))./nanstd(predmat(:));
            X = [X, predmat(:)];
            c=c+1;
            bnames{c} = pred{i};
            type(c) = 5;
        end
    end
end

if sprs
    X2 = sparse(size(X,1),length(rlev)+length(clev));
else
    X2 = zeros(size(X,1),length(rlev)+length(clev));
end

% Col to X
for i=1:length(clev)
    c = c+1;
    X2(col==clev(i),i) = 1;
    bnames{c} = ['Column',num2str(i)];
    type(c) = 2; % column-dependency
end
% Row to X
for i=1:length(rlev)
    c = c+1;
    X2(row==rlev(i),i+length(clev)) = 1;
    bnames{c} = ['Row',num2str(i)];
    type(c) = 3; % row-dependency
end

X = [X X2];


%bnames = erase(bnames,'_');

% If significance too low, remove columns
% was used in test cases, but not used anymore
% if isfield(out,'idxrem')
%     if length(clev)+length(rlev)+max(out.idxrem)<=size(X,2)
%         X(:,out.idxrem) = []; % offset is ignored, so idxrem=1 means mean
%         bnames(out.idxrem) = [];
%         type(out.idxrem) = [];
%     else
%         warning('Design matrix consists of all predictors found in the xls. No removing due to significance performed. \n Check size of X at the end of GetDesign.m to change this.')
%     end    
% end