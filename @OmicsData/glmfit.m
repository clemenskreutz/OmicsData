% [b,dev,stats] = glmfit(O,X,varargin)
% 
%   GLMFIT Fit a generalized linear model.
%   The function calls glmfit.m(X,dat(i,:)',varargin);
% 
%   O       @OmicsData
% 
%   X       Design matrix
% 
%   p       p-values (indicating significance of having different means)
% 
%   dev     returns the deviance of the fit.
% 
%   stats   more details statistics (see doc glmfit)
%               stats.p

function [b,dev,stats,p] = glmfit(O,X,sort,varargin)
if nargin<2
    error('OmicsData/glmfit.m requires at least two arguments. glmfit(O,X,varargin).')
end

% Set predictor
dat = get(O,'data');
% Watch out!! I shortened the dat matrix !!
% dat = dat(1:1000,:);

Y = isnan(dat);         % is missing
if all(all(Y ==0)) == 1 % if mv are not nan but 0 in data matrix
    dat(dat==0) = NaN;
    Y = isnan(dat);
end
if ~exist('sort','var') || isempty(sort)
    sort = false;
end
if sort
    %sort = sum(Y,2);
    Y = horzcat(Y,sum(Y,2));
    Y = sortrows(Y,size(Y,2));
    A = Y(:,end);
    Y = Y(:,1:end-1);
end

% Check design matrix
if size(X,1)~=size(dat,2)
    if size(X,2)==size(dat,2)
        X = X';
    else
        error('OmicsData/glmfit.m: Length of design matrix has to be the same size as data matrix. If a column should not be compared, fill in NaNs in design matrix.');
    end
end
if size(X,2) <=1
    X(:,2) = X(:,1);
    X(:,1) = ones(size(X,1),1);
end

% Set output variables nan
nf  = size(dat,1);  % number of features, e.g. number of proteins
b = NaN(nf,size(X,2));
p = NaN(nf,size(X,2));
p1 = NaN(nf,size(X,2));
p2 = NaN(nf,size(X,2));
dev = NaN(nf,1);
Y1 = nan(size(Y));
Y2 = nan(size(Y));

% Fit
for i=1:size(dat,1)
    if isempty(varargin)
        [b(i,:),dev(i),stats(i)] = glmfit(X,Y(i,:)','binomial','link','logit','constant','off');
    else
        [b(i,:),dev(i),stats(i)] = glmfit(X,Y(i,:)',varargin);
    end
    p(i,:) = stats(i).p;
    
    % if perfectly separated
    % if warning message ? Existiert sowas ? 
    if all( round(p(i,:),5) == 1 ) && all(all( round( abs( stats(i).coeffcorr ) ,5) ==1 ))
        p(i,:) = nan;
%         [B, FitInfo] = lassoglm(X,Y(i,:)','binomial');
%         warning('The estimated coefficients perfectly separate failures from successes. Using lassoglm instead of glmfit.');
%         hold on
%         semilogx(FitInfo.Lambda, FitInfo.Deviance)
%         title('lassoglm: penalized logistic regression')
%         xlabel('Lambda')
%         ylabel('Deviance')
%         % lassoPlot(B,FitInfo,'plottype','Lambda');
    end
    if all(round(p(i,:),2)==1)
        Y1(i,:) = Y(i,:);
        p1(i,:) = p(i,:);
    else
        Y2(i,:) = Y(i,:);
        p2(i,:) = p(i,:);
    end
end

% plot
figure
subplot(1,2,1)
imagesc(Y(1:size(dat,1),:));
colorbar
ylabel('Protein ID')
subplot(1,2,2)
plot(p(:,2),-(1:size(dat,1)),'o');
xlabel('p value')

% figure
% p1(~any(~isnan(Y1), 2),:)=[];
% A1 = A;
% A1(~any(~isnan(Y1), 2),:)=[];
% Y1(~any(~isnan(Y1), 2),:)=[];
% subplot(1,2,1)
% imagesc(Y1); colorbar
% ylabel('Protein ID')
% subplot(1,2,2)
% plot(p1(:,2),-(1:length(p1)),'o');
% xlabel('p value')
% title('just p==1')

figure
p2(~any(~isnan(Y2), 2),:)=[];
A2 = A;
A2(~any(~isnan(Y2), 2),:)=[];
Y2(~any(~isnan(Y2), 2),:)=[];
subplot(1,2,1)
imagesc(Y2); colorbar
ylabel('Protein ID')
subplot(1,2,2)
plot(p2(:,2),-(1:length(p2)),'o');
xlabel('p value')
title('just Proteins with p~=1')

figure
boxplot(p2(:,2),A2);
xlabel('p values')
ylabel('# missing')
figure
plot(p(:,2),A,'o');
xlabel('p values')
ylabel('# missing')

Names = get(O,'SampleNames');
for i=1:length(X)
    if X(i)==1       
        save(['LogRegResult/workspace' Names{i}(1) '.mat']);
        return
    end
end