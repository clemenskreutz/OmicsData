function O = assignmissing(O,out)

if ~exist('O','var')
    error('MissingValues/assignmissing.m requires class O as global variable.')
end

dat = get(O,'data_original');                                           % Original with missing values
pep = get(O,'Peptides',true);                                                % Peptide counts
seq = get(O,'SequenceCoverage',true)./100;
seq(isnan(seq))=0;

try
    boot = get(O,'boot',true);
catch
    boot = 1;
end

% Save directory
path = get(O,'path');
[filepath,name] = fileparts(path);
% Remove existing figures (Matlab does not overwrite images)
if exist([filepath '\' name '\' name '_MissingRowCol*.tif'],'file')
    delete([filepath '\' name '\' name '_MissingRowCol*.tif']);
else
    mkdir(filepath, name)
end

% Sort for plotting
comp = get(O,'data');  % Complete matrix is used for pattern simu

%% normalize/linearize mean matrix
full_norm = (comp-nanmean(comp(:)))./nanstd(comp(:));
if isfield(out,'c')
    linmean = 1./(1+exp(out.c(1)*full_norm+out.c(2)));
    % Compare linearized for logreg
    me = out.m;
    figure; histogram(me,100)
    hold on; histogram(linmean,100)
    title('Normalized & linearized for log reg')
    legend('original means','complete data')
    saveas(gcf,[filepath '/' name '/' name '_Histogram_linearized.tif'])
end


%% get  log reg coefficients
t = out.type(:,1);                            
b0 = out.b(t==0,:);                           % offset from logreg
b1 = out.b(t==1,:); b1 = mean(b1);            % Intensities together
b2 = out.b(t==2,:); b2 = mean(b2,2);          % Columns together
b3mat = out.b(t==3,:);                        % rows each separate
if any(t==4)
    b4 = out.b(t==4,:); b4 = mean(b4);        % Peptide counts
end
if any(t==5)
    b5 = out.b(t==5,:); b5 = mean(b5);        % Sequence coverage
end

%% Get peptide counts
if ~isempty(pep)
    pep = pep-mean(pep);  %normalize
    pep = pep./nanstd(pep);
    if 2*size(pep,2)==size(dat,2)
        pep = [pep, pep];
    elseif 2*size(pep,2)+1==size(dat,2)
        pep = [pep, pep, ones(size(pep,1),1)];
    elseif size(pep,2)~=size(dat,2)
        pep = [];
    end
    pep(isnan(pep)) = 0;
end

% Initialize
dat_mis = nan(size(comp,1),size(comp,2),boot);
dat_full = nan(size(comp,1),size(comp,2),boot);

for b=1:boot  
    A = comp;     % Use complete matrix for missing pattern simu, and calc full same way to compare RMSE afterwards
    full = comp;  % A and full are saved in dat_mis and dat_full at end of loop
    b3 = reshape(b3mat,[size(b3mat,1)*size(b3mat,2),1]); % combine bootstraps
    datr = dat; %(sum(isnan(dat),2)<size(dat,2),:);
    datr(isnan(b3),:) = [];
    b3(isnan(b3)) = []; 
    while size(A,1)<length(b3)                       % Because by deleting all nans, matrix gets smaller
        r = randperm(length(b3),length(b3)-size(A,1));  % delete randomly, to keep pattern
        b3(r) = [];
        datr(r,:) = [];
    end

    %% Calculate probability for each cell index
    logit = nan(size(A,1),size(A,2));
    for i=1:size(A,1)
        for j=1:size(A,2)
            if exist('linmean','var')
                logit(i,j) = exp(b1*linmean(i,j)+b2(j)+b3(i)); 
            else
                logit(i,j) = exp(b1*A(i,j)+b2(j)+b3(i)); 
            end
        end
    end
    if exist('b4','var') && ~isempty(b4)
        logit = logit .* exp(b4*pep);
    end
    if exist('b5','var') && ~isempty(b5)
        logit = logit .* exp(b5*seq);
    end
    if exist('b0','var') && ~isempty(b0)
        b0 = mean(b0); 
        logit = logit .* exp(b0);       % constant on by log reg
    end
        
    p = logit./(1+logit);                    % Probability
   
    %% assign nans
    r = rand(size(p,1),size(p,2));
    A(r<=p) = NaN;
    
    %% if complete column is nan
    if any(all(isnan(A)))
        A = comp;                       % try again
        r = rand(size(p,1),size(p,2));
        A(r<=p) = NaN;
        if any(all(isnan(A)))
            r = randsample(size(A,1),1);             % replace one value in column
            A(r,all(isnan(A))) = full(r,all(isnan(A)));
        end
    end
    
    
    % Shift intensities to original distribution, shift values of complete matrix the same to compare imputation
    full = (full-nanmean(A(:)))./nanstd(A(:));
    A = (A-nanmean(A(:)))./nanstd(A(:));
    full = full.*nanstd(dat(:))+nanmean(dat(:));
    A = A.*nanstd(dat(:))+nanmean(dat(:));
    
    %% Plot missing values per row column, compare original/simulated
    figure
    subplot(2,1,1)
    datrow = sort(sum(isnan(datr),2)/size(datr,2));
    plot(datrow,'LineWidth',1.5)
    hold on
    datsimrow = sort(sum(isnan(A),2)/size(A,2));
    plot(datsimrow,'LineWidth',1.5)
    xlabel('proteins')
    ylabel('missing values')
    legend('Original','Simulated','Location','northwest');
    hold off

    subplot(2,1,2)
    bar(sum(isnan(dat),1)/size(dat,1),'FaceAlpha',.7)
    hold on
    bar(sum(isnan(A),1)/size(A,1),'FaceAlpha',.7)
    xlabel('experiments')
    ylabel('Missing values')
    legend('Original','Simulated','Location','northwest');
    hold off

    % Save fig
    saveas(gcf,[filepath '/' name '/' name '_MissingRowCol_' num2str(b) '.tif'])
    
    dat_mis(:,:,b) = A;
    dat_full(:,:,b) = full;
end
%% Save class O
if size(dat_mis,2)>size(dat_mis,1)*2
    dat_mis = rot90(dat_mis);
    dat_full = rot90(dat_full);
end
O = set(O,'data_full',dat_full,'Complete dataset without missing values');     % Remember full/complete dataset for comparing 'right' solutions with imputed afterwards
O = set(O,'data',dat_mis,'Missing values assigned/simulated.');
O = set(O,'data_mis',dat_mis,'data with assigned missing values');
O = set(O,'mis_pat',isnan(dat_mis),'pattern of missing values');

PlotSimulatedPattern(O);


