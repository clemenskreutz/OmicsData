
function [X,y,type,bnames] = GetDesign(isna,m)

if nargin<2
    error('MissingValues/GetDesign.m requires two input arguments. GetDesign(isna,m).')
end

%% Shape it!
row  = ((1:size(isna,1))') * ones(1,size(isna,2));
row  = row(:);
col  = ones(size(isna,1),1)*(1:size(isna,2));
col  = col(:);
m = m*ones(1,size(isna,2)); 
m = m(:);
y = isna(:);

% initialize
rlev = levels(row);
clev = levels(col);
type = NaN(1+length(rlev)+length(clev),1);
bnames = cell(length(rlev)+length(clev)+1,1);
c = 1;

% Into X
X = m; %[ones(size(m)),m];
bnames{c} = 'mean';
type(c) = 1; % mean-dependency

X = [X,zeros(size(X,1),length(rlev)+length(clev))];
for i=1:length(clev)
    c = c+1;
    X(col==clev(i),c) = 1;
    bnames{c} = ['Column',num2str(i)];
    type(c) = 2; % column-dependency
end
for i=1:length(rlev)
    c = c+1;
    X(row==rlev(i),c) = 1;
    bnames{c} = ['Row',num2str(i)];
    type(c) = 3; % row-dependency
end


%% regularization: add a 0 and a 1 for each parameter (-> regularization towards estimate 0 == probability 0.5)
ind = 1;
yreg = zeros(2*(size(X,2)-1),1);
xreg = zeros(2*(size(X,2)-1),size(X,2));
xreg(:,1) = median(m)*ones(size(xreg,1),1);  % for regularization set first column to median(intensity)
for i=2:size(X,2)
    xreg(ind:(ind+1),i) = 1;
    yreg(ind+1) = 1;
    ind = ind+2;
end
X = [X;xreg];
y = [y;yreg];