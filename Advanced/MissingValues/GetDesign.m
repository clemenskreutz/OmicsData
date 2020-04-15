% Generate design matrix X with the factorial row/col predictors and the
% mean intensity
%
% O - omics data object
% out - results of logistic regression (incl. types & coefs)        []
% bio - flag if biological information should be taken into account [false]
%
% X - Design matrix
% y - response vector (flag if NA)
% type - vector of predictor type (mean=1,col=2,row=3,bio=4)
% bnames - names of predictor type
%
% Example:
% [X,y] = GetDesign(O);
% out = LogReg(X,y);

function [X,y,type,bnames] = GetDesign(O,out,bio)

if ~exist('out','var')
    out = [];
end
if ~exist('bio','var') || isempty(bio)
   bio = false;
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
c = 0;

% % mean to X
m = nanmean(O,2);
m = m*ones(1,size(isna,2)); 
if ~isfield(out,'typenames') || any(strcmp(out.typenames,'mean'))
    X = m(:);
    c=c+1;
    bnames{c} = 'mean';
    type(c) = 1; % mean-dependency
end

if bio
    % Predictors from O.cols
    pred = fieldnames(get(O,'cols'));
    for i=1:length(pred)
        % if not used for learning pattern, continue
        if  ~isfield(out,'typenames') || any(strcmp(out.typenames(out.type==4),pred{i}))
            predvec = get(O,pred{i},true);
            % if not 'data' or 'id'
            if isfield(out,'typenames') || (isnumeric(predvec) && ~strcmp(pred{i},get(O,'default_data')) && ~contains(pred{i},'id') && ~contains(pred{i},'Count') && ~contains(pred{i},'Fraction') )         
                if any(predvec>10^5) || any(predvec<10^(-5) & predvec>0)
                    predvec = log2(predvec);
                    predvec(isinf(predvec)) = nan;
                end
                % less than 5%MV, more than 5% different values (itself & with
                % previous predictor)
                if isfield(out,'typenames') || (sum(diff(predvec)==0)<0.05*size(predvec,1) && sum(isnan(predvec))<0.05*size(predvec,1) && sum(predvec-X(1:size(predvec,1),end)==0)<0.05*size(predvec,1) )
                    predvec = predvec*ones(1,size(isna,2));
                    X = [X, predvec(:)];
                    c=c+1;
                    bnames{c} = pred{i};
                    type(c) = 4;
                end
            end
        end
    end

    % % Predictors from O.data 
    pred = fieldnames(getfield(O,'data'));  % get(O,'data') is the default data matrix
    for i=1:length(pred)
        if ~isfield(out,'typenames') || any(strcmp(out.typenames(out.type==5),pred{i}))
            predmat = get(O,pred{i},true);
            % if size matches X
            if isfield(out,'typenames') || (isnumeric(predmat) && size(predmat,1)*size(predmat,2)==size(X,1) && ~strcmp(pred{i},get(O,'default_data')))
                if any(any(predmat>10^5)) || any(any(predmat<10^(-5) & predmat>0))
                    predmat = log2(predmat);
                    predmat(isinf(predmat)) = nan;
                end
                % less than 5%MV, more than 5% different values
                if isfield(out,'typenames') || (all(sum(diff(predmat)==0))<0.05*size(predmat,1) && all(sum(diff(predmat,[],2)==0)<0.05*size(predmat,1)) && all(sum(isnan(predmat))<0.05*size(predmat,1)) )
                    X = [X, predmat(:)];
                    c=c+1;
                    bnames{c} = pred{i};
                    type(c) = 5;
                end
            end
        end
    end
end

X = (X-nanmean(X))./nanstd(X);

sX = size(X,2);
% Col to X
for i=1:length(clev)
    c = c+1;
    X(col==clev(i),i+sX) = 1;
    bnames{c} = ['Column',num2str(i)];
    type(c) = 2; % column-dependency
end

sX = size(X,2);
% Row to X
for i=1:length(rlev)
    c = c+1;
    X(row==rlev(i),i+sX) = 1;
    bnames{c} = ['Row',num2str(i)];
    type(c) = 3; % row-dependency
end
