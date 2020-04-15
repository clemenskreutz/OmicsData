% Generate patterns of missing values, with the logistic regression 
% coefficients learned on the original data in out = LearnPattern(O)
%
% O - OmicsData class object
% out - logistic regression coefficients
% npat - # patterns to simulate (if >1, 3D array is returned)   [5]
%
% Example:
% out = LearnPattern(O);
% O = GetComplete(O);
% O = AssignPattern(O,out);


function O = AssignPattern(O,out,npat)

if ~exist('O','var')
    error('AssignPattern.m requires class O as input argument.\n')
end
if ~exist('out','var') || isempty(out)
    out = get(O,'out');
    if ~exist('out','var') || isempty(out)
        error('AssignPattern.m requires coefficients from logistic regression as input. Do LearnPattern before AssignPattern.\n')
    end
end
if ~exist('npat','var') || isempty(npat)
    npat = 10;
    fprintf('AssignPattern.m: 5 patterns of MV are simulated.\n')
end
if ~isfield(out,'b')
    error('AssignPattern.m requires coefficients from logistic regression as input. Do LearnPattern before AssignPattern. Input struct did not include coefficients.\n')
end

dat = get(O,'data');

% remember complete dataset
O = set(O,'data_complete',[]);          % Put in container so it stays same 
O = set(O,'data_complete',dat,'Complete dataset');

% Design matrix
    X = GetDesign(O,out);
%    X = QuantileRescalingX(X,out);

% Initialize
dat_patterns = nan(size(O,1),size(O,2),npat);

for i=1:npat
    
    % Log Reg
    b = out.b(out.type~=3); % get offset, intensity and column coefficients
    brow = out.b(out.type==3);
    brow = brow(ceil(rand(size(O,1),1)*length(brow)));         % get random row coefficients to match size of Complete matrix
    if length(b)+length(brow) ~= size(X,2)+1
        warning('Mismatch between size of logreg coefficients and design matrix. Check it.')
    end
    yhat = glmval( [b;brow], X, 'logit');

    % assign nans
    p = reshape(yhat(1:size(O,1)*size(O,2)),size(O,1),size(O,2)); % here yhat from regularization is cut off
    r = rand(size(p,1),size(p,2));
    % if (complete/known) data has missing values, binomial draw so total %MV matches 
    bino = boolean(binornd(1,sum(sum(isnan(O)))/size(O,1)/size(O,2),size(O,1),size(O,2))); % binomial draw
    r2 = (r<=p) & ~bino;
    
    dat_mis = dat;
    dat_mis(r2) = NaN;

    % Replace complete missingness
    drin = find(all(isnan(dat_mis),2));
    if sum(drin)>0
        back = ceil(rand(sum(drin),1)*size(dat_mis,2));
        for d = 1:length(drin)
            dat_mis(drin(d),back(d)) = dat(drin(d),back(d));
        end
    end
    dat_patterns(:,:,i) = dat_mis;
end
    
%% Save
O = set(O,'data',dat_patterns,'assign NA');
O = set(O,'data_mis',dat_patterns);
CheckPattern(O)

%% Plot
% PlotSimulatedPattern(O);
% PatternPerRowCol(O);