% [p,res] = logreg(O,X,varargin)
% 
%   LOGREG Fit a generalized linear model if necessary with penalty
%          Estimate p-values if H1(all parameters) is different from H0
%          (set one parameter sequentiell = 0)
% 
%   The function calls glmfit.m(X,dat(i,:)',varargin)
%   If 'perfect separation of data' 
%       lassoglm.m(X,dat(i,:)') overwrites coefficients of glmfit.m
%
%   O       @OmicsData
% 
%   X       Design matrix % Do not put intercept (vector with one's) in X! 
%           It's automatically added by glmfit.m and lassoglm.m
% 
%   p       p-values (indicating significance of different experiments)
%           size(p,1) number of proteins
%           size(p,2) column j switches off column j of design matrix 
% 
%   res     result struct
%           res.b   estimated coefficient
%           res.p   p-value (the same as p)
%           res.fdr 
%           res.dev
% 

function [pv,res, Protein,Proteinline] = logreg(O,X,alpha,name,strpattern,group,varargin)

if nargin<1
    error('OmicsData/logreg.m requires at least one argument.')
end

if ~exist('alpha','var') || isempty(alpha)
    alpha = 0.05;
end


%% Set data
if exist('name','var') && exist('strpattern','var') && ~isempty(name) && ~isempty(strpattern)
    O = ReducebyName(O,name,strpattern);    % Check for equal strings in SampleNames
else, fprintf('Uses complete dataset for logistic regression.\n')
end

dat = get(O,'data')';
if isfield(O,'Proteinnames')
    ProteinName = get(O,'Proteinnames');
elseif isfield(O,'Proteinname')
    ProteinName = get(O,'Proteinname');
elseif isfield(O,'ProteinIDs')
    ProteinName = get(O,'ProteinIDs');
end

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
if ~exist('X','var') || isempty(X)
    if isfield(O,'X')
        X = get(O,'X');
    else
        error('logreg.m: Design matrix X has to be passed in as second input argument (logreg(O,X)), or be saved in Omics class O by set(O,"X",X). For example use X = [zeros(size(dat,2)/2,1); ones(size(dat,2)/2,1)]; \n');
    end
end
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
dev = NaN(nf,1);
dev0 = NaN(nf,1);
pv   = NaN(nf,np);
idx = NaN(1,nf);
Protein = {};
Proteinline = [];
didL1 = zeros(nf,1);


%% LogReg
for i=1:size(dat,2)
    
    %% glm for H1
    if isempty(varargin)
        [b(:,i),dev(i)] = glmfit(X,dat(:,i),'binomial','link','logit');
    else
        [b(:,i),dev(i)] = glmfit(X,dat(:,i),varargin{:});
    end
        
    %% if perfectly separated: Lasso
    if strncmp(lastwarn,'The estimated coefficients perfectly separate failures from successes.',70)
        % Lasso for H1
%         if ~exist('lam','var')
%             [Bl, Fitl] = lassoglm(X,X,'binomial','Lambda',1e-6); 
%             [B2, Fit2] = lassoglm(X,X,'binomial','Lambda',0.5); 
%             [B3, Fit3] = lassoglm(X,X,'binomial','Lambda',1e-4); 
%             %lassoPlot(Bl,Fitl,'plottype','CV');
%             [~,idx]  = min(Fitl.Deviance);
%             lam = Fitl.Lambda(idx);
%         end
        lam = 1e-6;
        [~, FitInfo] = lassoglm(X,dat(:,i),'binomial','Lambda',lam);
        didL1(i) = 1;
        dev(i)  = min(FitInfo.Deviance);

        warning(['glmfit_janine.m (Line 88): Used penalization/lasso for Protein in line ' num2str(i)]);
        
        for j=1:size(X,2)               % To check if log regress is sinnvoll for this parameter switch off each parameter and check by lrt      
            % Lasso for H0
            if size(X,2)==1
                Xtmp = ones(size(dat,1),1);
            else
                Xtmp = X;
                Xtmp(:,j) = [];
            end     
            [~, FitInfo0] = lassoglm(Xtmp,dat(:,i),'binomial','Lambda',lam);  % Use same lambda as in H1     
            dev0(i,j)  = FitInfo0.Deviance;                          % Dev = -2*(log(L1)-log(Ls))
            pv(i,j) = 1-chi2cdf(abs(dev(i)-dev0(i,j)),1);                 % Devi-dev0 = -2*(log(L1)-log(L0))
            if pv(i,j)<alpha
                 Protein = [ Protein, ProteinName{i}];
                 Proteinline = [ Proteinline i];
            end
        end
    %% Glm for H0, Why not L1 for H0 ???
    else    
        if size(X,2)==1
            Xtmp = ones(size(dat,1),1);
            if isempty(varargin)
                [~,dev0(i,1)] = glmfit(Xtmp,dat(:,i),'binomial','link','logit','constant','off');
            else
                [~,dev0(i,1)] = glmfit(Xtmp,dat(:,i),varargin,'constant','off');
            end
            pv(i) = 1-chi2cdf(abs(dev(i)-dev0(i,j)),1);
            if pv(i)<alpha
                 Protein = [ Protein, ProteinName{i}];
                 Proteinline = [ Proteinline i];
            end
        else
            for j=1:size(X,2)
                Xtmp = X;
                Xtmp(:,j) = [];
                if isempty(varargin)
                    [~,dev0(i,j)] = glmfit(Xtmp,dat(:,i),'binomial','link','logit');
                else
                    [~,dev0(i,j)] = glmfit(Xtmp,dat(:,i),varargin);
                end
                pv(i,j) = 1-chi2cdf(abs(dev(i)-dev0(i,j)),1);
                if pv(i,j)<alpha
                    Protein = [ Protein, ProteinName{i}];
                    Proteinline = [ Proteinline i];
                end
            end
        end
    end
end

%% FDR
try
    [fdr, q, fdrBH] = fdr_calculations(pv);
catch
    fdr = NaN(size(pv));
    q = NaN(size(pv));
    fdrBH = NaN(size(pv));
end
if exist('group','var')
    [fdrg,qg,fdrBHg]= fdr_calculations(pv,sum(isnan(O),2));
end

res.b = b';
res.p = pv;
res.dev = dev;
res.dev0 = dev0;
res.fdr = fdr;
res.q = q;
res.fdrBH = fdrBH;
res.didL1 = didL1;

%% Write
if isfield(O,'path')
    file = get(O,'path');
    [pfad,filename,~] = fileparts(file);
    file = [pfad '/' filename];
else, file = get(O,'name');
end

if ~isempty(file)
    if exist('strpattern','var')
        if exist('lam','var')
            OmicsWrite(O,[file '_p_' name strpattern '.xls'],'logreg p',pv,'FDR',fdr,'lambda',lam);
        else
            OmicsWrite(O,[file '_p_' name strpattern '.xls'],'logreg p',pv,'FDR',fdr);
        end
    else
        if exist('lam','var')
            OmicsWrite(O,[file '_p.xls'],'logreg p',pv,'FDR',fdr,'lambda',lam);
        else
            OmicsWrite(O,[file '_p.xls'],'logreg p',pv,'FDR',fdr);
        end
    end
else 
    if exist('strpattern','var')
        if exist('lam','var')
            OmicsWrite(O,['p_' name strpattern '.xls'],'logreg p',pv,'FDR',fdr,'lambda',lam);
        else
            OmicsWrite(O,['p_' name strpattern '.xls'],'logreg p',pv,'FDR',fdr);
        end
    else
        if exist('lam','var')
            OmicsWrite(O,'p.xls','logreg p',pv,'FDR',fdr,'lambda',lam);
        else
            OmicsWrite(O,'p.xls','logreg p',pv,'FDR',fdr);
        end
    end
end
% if isfield(O,'X')
%     X = get(O,'X');
%     if exist('strpattern','var')
%         save(['Data/DesignMatrix' name strpattern '.mat'],'X');
%     else
%         save(['Data/DesignMatrix.mat'],'X');
%     end
% end