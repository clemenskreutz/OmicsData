function assignmissing

global O

if ~exist('O','var')
    error('MissingValues/assignmissing.m requires class O as global variable or input argument.')
end

A = get(O,'data');                                                      % Dataset without missing values
O = set(O,'data_full',A,'Complete dataset without missing values');     % Remember full/complete dataset for comparing 'right' solutions with imputed afterwards
dat = get(O,'data_original');                                           % Original with missing values
out = get(O,'out');                                                     % Logreg coefficients
% n_mis = length(find(isnan(dat)))/size(dat,1)/size(dat,2);             % how many missing values in original dataset ? 

%% get coeff for each cell index
t = out.type(:,1);                            % In the separation of datasets:
b1 = out.b(t==1,:); b1 = mean(b1,2);          % Intensities together
b2 = out.b(t==2,:); b2 = mean(b2,2);          % Columns together
b3 = out.b(t==3,:); b3(isnan(b3)) = [];       % rows each separate
if size(A,1)<size(b3,1)                       % Because by deleting all nans, matrix gets smaller
    r = randperm(size(b3,1),size(b3,1)-size(A,1));  % delete randomly, to keep pattern
    b3(r) = [];
end
m = (A-mean(A))./nanstd(A);  % Intensity centered & normalized

%% Calculate probability for each cell index
logit = nan(size(A,1),size(A,2));
for i=1:size(A,1)
    for j=1:size(A,2)
        logit(i,j) = exp(b1*m(i,j)+b2(j)+b3(i));
    end
end
p = logit./(1+logit);                    % Probability

%% assign nans
r = rand(size(p,1),size(p,2));
A(r<=p) = NaN;

%% Plot comparison
figure
subplot(2,2,1)
imagesc(dat)
title('Original dataset')
ylabel('Proteins')
subplot(2,2,2)
imagesc(A)
title('Simulated missing values')

subplot(2,2,3)
imagesc(isnan(dat))
title('Original dataset')
xlabel('Experiments')
ylabel('Proteins')
subplot(2,2,4)
imagesc(isnan(A))
title('Simulated missing values')
xlabel('Experiments')

%% Set
O = set(O,'data',A,'Missing values assigned/simulated.');
O = set(O,'data_mis',A,'data with assigned missing values');
O = set(O,'mis_pat',isnan(A),'pattern of missing values');
save AssignedMissing O
