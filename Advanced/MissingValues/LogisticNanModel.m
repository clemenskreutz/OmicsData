%   A logistic regression model for the occurance of missing values
%
%       O       @OmicsData object
%       
%   If O has more than 1000 features, nboot bootstap subset of 1000
%   features are drawn and the predictors are estimated nboot times for
%   these subsets.
%
function LogisticNanModel

global O

if ~exist('O','var')
    error('MissingValues/LogisticNanModel.m requires class O as global variable or input argument.')
end

isna = isnan(O);

drin = find(sum(isna,2)<size(isna,2));
isna = isna(drin,:);

% % Peptide count
% pep = get(O,'Peptides');
% if ~isempty(pep)
%     pep = pep(drin,:);
%     pep = pep-nanmean(pep);  %normalize
%     pep = pep./nanstd(pep);
%     if 2*size(pep,2)==size(isna,2)
%         pep = [pep, pep];
%     elseif 2*size(pep,2)+1==size(isna,2)
%         pep = [pep, pep, ones(size(pep,1),1)];
%     elseif size(pep,2)~=size(isna,2)
%         pep = [];
%     end
%     pep(isnan(pep)) = 0;
% end
% 
% % Sequence coverage
% seqc = get(O,'SequenceCoverage')./100;
% if exist('seqc','var') && ~isempty(seqc)
%     seqc = seqc(drin,:);
%     seqc(isnan(seqc)) = 0;
% end

% Normalize mean
m = nanmean(O(drin,:),2);
m = m-mean(m);  % centered
m = m./nanstd(m); % standardized

% Linearize mean
 mis = sum(isna,2)./size(isna,2);

%x0=[0.5;-1];
%x0=[min(m)/max(m);-min(m)];
x0=[-1;0];
fun=@(x)(1./(1+exp(x(1)*m+x(2)))-mis);
%fun=@(x)(exp(x(1)*m+x(2))./(1+exp(x(1)*m+x(2)))-mis);
options = optimset('TolFun',1e-20,'TolX',1e-20);
%options = optimset('MaxFunEval',10000,'MaxIter',5000);
[x,~] = lsqnonlin(fun,x0,[],[],options);
%[x,~] = lsqnonlin(fun,x0);
mexp = 1./(1+exp(x(1)*m+x(2))); 
%mis = mis+rand(size(isna,1),1)*0.1;

figure
subplot(1,2,1)
plot(m,mis,'.')
hold on; 
plot(m,mexp,'.')
xlabel('mean protein intensity m_p')
ylabel('Missing values [%]')
ylim([0 1])
legend('data','logistic fit')

m = -mexp;     % negative, so that coefficients are interpretable (same slope)

lc = polyfit(m,mis,1);
lf = polyval(lc,m);

subplot(1,2,2)
plot(m,mis,'.') % linearized data
hold on;
plot(m,lf) % linear fit
xlabel('$\frac{1}{1+e^{b* m_p +c}}$','Interpreter','latex')
ylabel('Missing values [%]')
ylim([0 1])
legend('linearized data','linear fit')

path = get(O,'path');
[filepath,name] = fileparts(path);
if exist([filepath '\' name '\' name '_SimulatedMissingPattern_1.png'],'file')
    delete([filepath '\' name '\' name '_IntensityShift.png']);
else
    mkdir(filepath, name)
end
print([filepath '/' name '/' name '_IntensityShift'],'-dpng','-r100');

coef = x;
m = m*ones(1,size(isna,2)); % mean stretchen für design matrix

nfeat = size(isna,1);

if nfeat>1000
    disp('More than 1000 features, bootstrap of subsamples is applied.');
    indrand = randperm(nfeat,nfeat);
    nboot = ceil(nfeat/1000);       
    nperboot = ceil(nfeat/nboot);
    indlast = 0;
    
    for i=1:nboot
        fprintf('%i out of %i ...\n',i,nboot);

        current = indlast + (1:nperboot);
        current(current>nfeat) = [];
        indlast = indlast+length(current);
        
        ind = indrand(current);
        %ind = current;
        
        tic;         
        out_tmp = LogisticNanModel_core(isna(ind,:), m(ind,:));
        if i==1
            out = struct;
            out.timing = NaN(1,nboot);
            out.b = NaN(size(out_tmp.b,1),nboot);
            out.se = NaN(size(out_tmp.b,1),nboot);
            out.type = NaN(size(out_tmp.b,1),nboot);
            out.current = cell(0);
            out.m = out_tmp.m;
        end
        out.current{i} = ind;
        out.timing(i) = toc;
        out.b(1:length(out_tmp.b),i) = out_tmp.b;
        out.se(1:length(out_tmp.b),i) = out_tmp.stats.se;
        out.type(1:length(out_tmp.b),i) = out_tmp.type;
        
%         if i==1
%             out.out1 = out_tmp;
%         end
    end
else
    out = LogisticNanModel_core(isna, m);
end
out.type_names = {'mean intensity dependency','column-dependency','rows-dependency','peptide counts'};
if exist('coef','var')
    out.c = coef;
end
O = set(O,'out',out,'Logistic regression output.');
%save out out


function out = LogisticNanModel_core(isna,m)
row  = ((1:size(isna,1))') * ones(1,size(isna,2));
row  = row(:);
col  = ones(size(isna,1),1)*(1:size(isna,2));
col  = col(:);
m = m(:);
y = isna(:);

% initialize
rlev = levels(row);
clev = levels(col);
type = NaN(1+length(rlev)+length(clev),1);
bnames = cell(length(rlev)+length(clev)+1,1);
c = 1;

% Mean to X
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
yreg = zeros(2*size(X,2),1);
xreg = zeros(2*size(X,2),size(X,2));
for i=1:size(X,2)
    xreg(ind:(ind+1),i) = mean(m);
    yreg(ind+1) = 1;
    ind = ind+2;
end
X = [X;xreg];
y = [y;yreg];

%% check condition number:
removed = 0;
fprintf('size(X,1) = %i\n',size(X,1));
fprintf('size(X,2) = %i\n',size(X,2));
% con = rcond(X'*X);                    % dauert zu lang für große Matrizen
% if con>1e6
%     warning('Condition number = %d ',con);
% end

if removed>0
    fprintf('%i columns removed in X due to non-identifiablity.\n',removed);
end

out.X = X;

[b,dev,stats] = glmfit(X,y,'binomial','link','logit','constant','off');

out.b = b;
out.dev = dev;
out.stats = stats;
out.y = y;
out.bnames = bnames;
out.m = m;

out.type = type;

