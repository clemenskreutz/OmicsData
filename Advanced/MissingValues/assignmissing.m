function O = assignmissing(O)

A = get(O,'data');
dat = get(O,'data_original');
n_mis = length(find(isnan(dat)))/size(dat,1)/size(dat,2); % how many missing values in dataset ? 

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
p = 1./(1./logit+1);                    % Probability

%% assign nans
ps = sort(p(~isnan(p)));
thr = ps(ceil(length(ps)*(1-n_mis)));   % Find threshold where same percentage than in original dataset are missing
A(p>thr) = NaN;

%% Plot comparison
figure
subplot(1,2,1)
imagesc(dat)
subplot(1,2,2)
imagesc(A)
