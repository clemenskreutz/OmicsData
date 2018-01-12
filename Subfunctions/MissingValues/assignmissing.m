
% O = assignmissing(O)
% 
%  Analyze missing data pattern
%  Delete all lines with missing values
%  Set missing values randomly in data (with probability distribution in
%  both dimensions)

function O = assignmissing(O,ndata,missing)

if ~exist('missing','var')
    missing = [];
end
if ~exist('ndata','var') || isempty(ndata)
    ndata = 1;
end

O = missingpattern(O,missing);          % First analyze pattern of missing values
O = deletemissing(O,missing);           % Delete all lines with missing values

% Get variables from O
dat = get(O,'data');
if ~isempty(dat)
    ncol = get(O,'mis_ncol');                                         
    b = get(O,'mis_logreg');
    x = linspace(1,100,size(dat,1));
    n = size(dat,2) * ones(size(dat,1),1);
    if ~exist('ncol','var')
        error('Number of missing values per column does not exist. First analyse missingpattern.m than fillinmissing.m.\n');
    end
    if ~exist('b','var')
        error('Parameter for logistic regression of # missing values per row does not exist. First analyse missingpattern.m than fillinmissing.m.\n');
    end

    % Logistic regression
    yfit = glmval(b.beta,x,'logit','size',n);
    y = round(yfit);
    % Plot
    figure
    plot(x,y./n,'-',x, yfit./n,'-','LineWidth',2)
    xlabel('ProteinID');
    ylabel('# missing values [%] per row');
    legend('used','logistic regression','Location','east')

    % Set missing values randomly in data (with probability distribution in
    % both dimensions)
    mispat = zeros(size(dat,1),size(dat,2),ndata);
    for nn = 1:ndata
        for i=1:size(dat,1)
            if y(i)>0
                ds = datasample(1:size(dat,2),y(i),'Replace',false,'Weights',ncol);
                for j=1:length(ds)
                    mispat(i,ds(j),nn) = 1;
                end        
            end
        end
        % !!! Test instead of sorted matrix by number of missing values per
        % row, swap randomly        
        mispat(:,:,nn) = mispat(randperm(size(mispat, 1)), :,nn);
          %ncol = sum(isnan(dat))./size(dat,1);
    end


    if all(all(mispat==1))
        warning('No missing values assigned in fillinmissing.m.');
    else
        O = set(O,'mis_pat',mispat,['mis_pat is pattern of missing values, picked ' num2str(ndata) ' times.']);
        mispat(mispat==1) = nan;
        mis_data = zeros(size(dat,1),size(dat,2),ndata);
        for nn = 1:ndata
            mis_data(:,:,nn) = dat+mispat(:,:,nn);        % data with missing pattern
        end
        O = set(O,'data',mis_data,'Missing values assigned.');
        fprintf('Original data in data_original.\n Data without missing values in data_full.\n Data with newly assigned missing values in data.\n');
    end
else
    warning('No missing values assigned. Dataset already has missing values in each line.')
end


