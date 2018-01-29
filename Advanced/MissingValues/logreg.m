% p = logreg(O,X,varargin)
% 
%   LOGREG Fit a generalized linear model if necessary with penalty
%          Estimate p-values if H1(all parameters) is different from H0
%          (set one parameter sequentiell = 0)
%   The function calls glmfit.m(X,dat(i,:)',varargin)
%   If 'perfect separation of data' 
%       lassoglm.m(X,dat(i,:)') overwrites coefficients of glmfit.m
%
%   O       @OmicsData
% 
%   X       Design matrix % Do not put intercept (vector with one's) in X! 
%           It's automatically added by glmfit.m and lassoglm.m
% 
%   p       p-values (indicating significance of differing dataset)
%           for each column of design matrix (length(p) = size(X,2))


function pv = logreg(O,varargin)
if nargin<1
    error('OmicsData/logreg.m requires an OmicsData set. glmfit_janine(O,varargin).')
end

%% Set predictor
% [X,dat] = ReducebyName(O,1);    % Check for equal strings in SampleNames
% if isempty(X) && isempty(dat)
    dat = get(O,'data')';
    X = get(O,'X');
% end

if all(all(all(isnan(dat))))==0
    dat(dat==0) = nan;  % if missing values are not NaN but 0 in data matrix
    dat = isnan(dat);
else
    dat = isnan(dat); 
end

% SORT! Just for looking at the p-values. In the end delete these lines.
% dat = horzcat(dat,sum(dat,2));
% dat = sortrows(dat,size(dat,2));
% A = dat(:,end);                     % A gives #nans
% dat = dat(:,1:end-1);
% dat = dat(:,9080:9101);

%% Check design matrix
if size(X,1)~=size(dat,1)
    if size(X,2)==size(dat,1)
        X = X';
    else
        error('OmicsData/glmfit.m: Length of design matrix has to be the same size as data matrix. If a column should not be compared, fill in NaNs in design matrix.');
    end
end


%% Set output variables nan
nf  = size(dat,2);  % number of features, e.g. number of proteins
np = size(X,2);     % number of parameters, e.g. means
b   = NaN(np+1,nf);
dev = NaN(1,nf);
dev0 = NaN(1,nf);
pv   = NaN(nf,np);
idx = NaN(1,nf);


%% LogReg
for i=1:size(dat,2)
    
    %% glm for H1
    if isempty(varargin)
        [b(:,i),dev(i)] = glmfit(X,dat(:,i),'binomial','link','logit');
    else
        [b(:,i),dev(i)] = glmfit(X,dat(:,i),varargin);
    end
    
    %% if perfectly separated: Lasso
    if strncmp(lastwarn,'The estimated coefficients perfectly separate failures from successes.',70)
        % Lasso for H1
        [~, FitInfo] = lassoglm(X,dat(:,i),'binomial'); 
        [dev(i),idx(i)]  = min(FitInfo.Deviance);
        warning(['glmfit_janine.m (Line 88): Used penalization/lasso for Protein in line ' num2str(i)]);
        
        for j=1:size(X,2)               % To check if log regress is sinnvoll for this parameter switch off each parameter and check by lrt      
            % Lasso for H0
            if size(X,2)==1
                Xtmp = ones(size(dat,1),1);
            else
                Xtmp = X;
                Xtmp(:,j) = [];
            end     
            [~, FitInfo0] = lassoglm(Xtmp,dat(:,i),'binomial','Lambda',FitInfo.Lambda(idx(i)));  % Use same lambda as in H1     
            dev0(i)  = FitInfo0.Deviance;                          % Dev = -2*(log(L1)-log(Ls))
            pv(i,j) = 1-chi2cdf(abs(dev(i)-dev0(i)),1);                 % Devi-dev0 = -2*(log(L1)-log(L0))
        end
    %% Glm for H0 
    else    
        for j=1:size(X,2)
            % glm for H0
            if size(X,2)==1
                Xtmp = ones(size(dat,1),1);
            else
                Xtmp = X;
                Xtmp(:,j) = [];
            end
            if isempty(varargin)
                [~,dev0(i)] = glmfit(Xtmp,dat(:,i),'binomial','link','logit');
            else
                [~,dev0(i)] = glmfit(Xtmp,dat(:,i),varargin);
            end
            pv(i,j) = 1-chi2cdf(abs(dev(i)-dev0(i)),1);
        end
    end
end

pv