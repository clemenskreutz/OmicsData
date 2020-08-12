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


function O = AssignPattern(O,out,npat,logflag,expand)

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
    if size(O,1)*size(O,2)<50000
        npat = 20;
    elseif size(O,2)<100000
        npat = 10;
    else
        npat = 5;
    end
    npat = 1;
end
if ~exist('expand','var') || isempty(expand)
    expand = false;
end
if ~isfield(out,'b')
    error('AssignPattern.m requires coefficients from logistic regression as input. Do LearnPattern before AssignPattern. Input struct did not include coefficients.\n')
end
fprintf(['AssignPattern.m: ' num2str(npat) ' patterns of MV are simulated.\n'])

ori = get(O,'data_original');
Os = O(1:sum(~all(isnan(ori),2)),:); % delete all empty rows
oris = get(Os,'data_original');
comps = get(Os,'data');

% Design matrix
X = GetDesign(Os,out,false,logflag);
%    X = QuantileRescalingX(X,out);

% Initialize
dat_patterns = nan(size(Os,1),size(Os,2),npat);

for i=1:npat
    
    % Log Reg
    b = out.b(out.type~=3); % get offset, intensity and column coefficients
    brow = out.b(out.type==3);
    brow = brow(ceil(rand(size(Os,1),1)*length(brow)));         % get random row coefficients to match size of Complete matrix
    if length(b)+length(brow) ~= size(X,2)+1
        warning('Mismatch between size of logreg coefficients and design matrix. Check it.')
    end
    yhat = glmval( [b;brow], X, 'logit');

    % assign nans
    p = reshape(yhat(1:size(Os,1)*size(Os,2)),size(Os,1),size(Os,2)); % here yhat from regularization is cut off
    r = rand(size(p,1),size(p,2));
    % if (complete/known) data has missing values, binomial draw so total %MV matches 
    isna = r<p & ~isnan(Os);  % NaN von Logistischer Regres zusätzlich
    isnaInd = find(isna(:));
    if sum(sum(isnan(oris)))>sum(sum(isnan(Os))) && length(isnaInd)>sum(isnan(oris(:)))-sum(sum(isnan(Os)))
        isnaInd = isnaInd(randsample(length(isnaInd),sum(isnan(oris(:)))-sum(sum(isnan(Os)))));
    end
    dat_mis = comps;
    dat_mis(isnaInd) = NaN;

    % Replace complete missingness
    drin = find(all(isnan(dat_mis),2));
    if ~isempty(drin)
        back = ceil(rand(length(drin),1)*size(dat_mis,2));
        for d = 1:length(drin)
            dat_mis(drin(d),back(d)) = comps(drin(d),back(d));
        end
    end
    dat_patterns(:,:,i) = dat_mis;
end

dat_patterns(size(Os,1)+1:size(O,1),:,:) = nan;

%% Save
if expand && isfield(O,'data_mis')
    dat_patterns = cat(3,get(O,'data_mis'),dat_patterns);
end
O = set(O,'data',dat_patterns,'assign NA');
O = set(O,'data_mis',dat_patterns);

%CheckPattern(O)

%% Plot
% PlotSimulatedPattern(O);
% PatternPerRowCol(O);
end