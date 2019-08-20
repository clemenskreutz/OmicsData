function O = AssignPattern(O,out,npat)

if ~exist('O','var')
    error('MissingValues/AssignPattern.m requires class O as input argument.\n')
end
if ~exist('out','var') || isempty(out)
    error('MissingValues/AssignPattern.m requires coefficients from logistic regression as input. Do LearnPattern before AssignPattern.\n')
end
if ~exist('npat','var') || isempty(npat)
    npat = 5;
    fprintf('MissingValues/AssignPattern.m: 5 patterns of MV are simulated.\n')
end
if ~isfield(out,'b')
    error('MissingValues/AssignPattern.m requires coefficients from logistic regression as input. Do LearnPattern before AssignPattern. Input struct did not include coefficients.\n')
end
if ~isfield(out,'lincoef')
    error('MissingValues/AssignPattern.m requires coefficients to linearize mean for logistic regression. Do LearnPattern before AssignPattern.\n')
end

% Delete empty proteins for logreg
drin = sum(isnan(O),2)<size(O,2);
O = O(drin,:);

% Get data
dat = get(O,'data');
isna = isnan(O);
m = nanmean(O,2);
m = m-mean(m);  % centered
m = m./nanstd(m); % standardized

% Linearize mean   
m = feval(out.mean_trans_fun,m,out.lincoef); 

% Design matrix
X = GetDesign(isna,m);

% Initialize
dat_mis = repmat(dat,1,1,npat);

for i=1:npat
    
    % Log Reg
    b = [out.b(out.type==0); out.b(out.type==1); out.b(out.type==2)]; % get offset, intensity and column coefficients
    brow = out.b(out.type==3);
    brow = brow(ceil(rand(size(isna,1),1)*length(brow)));         % get random row coefficients to match size of Complete matrix
    if length(b)+length(brow) ~= size(X,2)+1
        warning('Mismatch between size of logreg coefficients and design matrix. Check it.')
    end
    yhat = glmval( [b;brow], X, 'logit');

    % assign nans
    p = reshape(yhat(1:size(isna,1)*size(isna,2)),size(isna,1),size(isna,2)); % here yhat from the rgularization is cut off
    r = rand(size(p,1),size(p,2));
    dat_mis = dat;
    dat_mis(r<=p) = NaN;
    dat_patterns(:,:,i) = dat_mis;
end
sum(sum(isnan(dat_patterns)))/size(dat_patterns,1)/size(dat_patterns,2)
O = set(O,'data',dat_patterns,'assign NA');
O = set(O,'data_mis',dat_patterns);

%% Plot
PlotSimulatedPattern(O);
PatternPerRowCol(O);