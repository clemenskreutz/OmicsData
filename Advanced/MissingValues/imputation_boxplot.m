
function imputation_boxplot(O,log,how,compare)

% how: ganzer Datensatz oder nur imputed
% compare: columnwise or whole array
if ~exist('O','var')
    error('OmicsData object has to be passed in to function imputation_boxplot.m.')
end
% Get variables from class
dat = get(O,'data_full');
Imp = get(O,'data_imput');
method = get(O,'method_imput');
mispat = get(O,'mis_pat');

if ~exist('how','var') || isempty(how) % if how = false: columnwise comparison 
    if isempty(dat)
         how = false;
    else how = true;                        % if how = true: one group for whole matrix
    end
end
if ~exist('compare','var') || isempty(compare) % if how = false: columnwise comparison 
    if isempty(dat)
         compare = false;
    else compare = true;                        % if how = true: one group for whole matrix
    end
end

if ~exist('log','var') || isempty(log)
    if range(dat)>10^3
        log = true;
    else log = false;
    end
end
if log
    dat(dat<=0) = nan;              % for numbers <=0 log not possible
    dat = log10(dat);               % Data is ignored
    Imp(Imp<=0) = nan;
    Imp = log10(Imp);
end

% calculate just imputed values
if compare
    dat_mis = nan(size(mispat,1),size(mispat,2),size(mispat,3));
    if size(dat,3) ==size(mispat,3)
        dat_mis = dat.*mispat;
    else
        for j=1:size(mispat,3)
            dat_mis(:,:,j) = dat.*mispat(:,:,j);
        end
    end
    dat_imp = nan(size(Imp,1),size(Imp,2),size(Imp,3), size(Imp,4));
    for i=1:size(Imp,4)
        dat_imp(:,:,:,i) = Imp(:,:,:,i).*mispat;
    end
    if log   
        dat_mis(dat_mis<=0) = nan;
        dat_mis = log10(dat_mis);
        dat_imp(dat_imp<=0) = nan;
        dat_imp = log10(dat_imp);
    end
end



% Figure
figure
set(gcf,'units','normalized','outerposition',[0 0 1 1])
for i=1:size(Imp,4)
    % sum of square
    Quad = 0;
    if size(dat_imp,3) == size(dat_mis,3)
        Quad = Quad + sum(sum(nansum((dat_mis - dat_imp(:,:,:,i)).^2)));       
    else
        for j=1:size(dat_imp,3)
            Quad = Quad + sum(nansum((dat_mis - dat_imp(:,:,j,i)).^2));
        end
    end
    Quad = Quad/size(Imp,3);
    % subplot
    if size(Imp,4)<=3                          % Create subplots depending on number of imputation methods calculated
        piep = size(Imp,4);
        subplot(1,size(Imp,4),i)
    elseif size(Imp,4)>3
        piep = ceil(size(Imp,4)/2);
        subplot(2,ceil(size(Imp,4)/2),i)
    elseif size(Imp,4)>6
        piep = ceil(size(Imp,4)/3);
        subplot(3,ceil(size(Imp,4)/3),i)
    end
    % boxplot
    if how
        if ~compare
            Y = dat(~isnan(dat));                 % Write data in one column, to suppress columnwise boxplot
            Z = Imp(~isnan(Imp(:,:,i)));
        else
            Y = dat_mis(~isnan(dat_mis));
            Z = dat_imp(~isnan(dat_imp));
        end
        aboxplot({Y;Z});
    else
        aboxplot({dat;Imp(:,:,i)});
    end
    
    % Figure definitions
    title(['Imputed by ' method{i}]);   
    ylim = get(gca,'YLim');
    text(0.52,0.98*ylim(2),['ls/bs = ' num2str(round(Quad,2,'significant'))]) 
    text(0.52,0.9*ylim(2),['bootstrap = ' num2str(size(Imp,3))]) 
%     text(0.52,0.98*max(max(max(dat))),['ls/bs = ' num2str(round(Quad,2,'significant'))]) 
%     text(0.52,0.9*max(max(max(dat))),['bootstrap = ' num2str(size(Imp,3))]) 
    if i>=size(Imp,4)-size(Imp,4)/piep && ~log
        xlabel('Measurement condition')
    end
    if compare
        set(gca,'XTick',[ 0.9 1.1 ]);
        set(gca,'XTickLabel',{'Original','Imputed'});
        xlabel('just missing values');        
    else
        set(gca,'XTick',[ 0.7 0.9 1.1 1.3]);
        set(gca,'XTickLabel',{'Original','Imputed','Original','Imputed'});
        xlabel('whole matrix   just missing values');
    end
    if rem(i+size(Imp,4)/piep,piep)==0
        if log
            ylabel('log10(data)')
        else
            ylabel('data')
        end
    end
    if i==size(Imp,4) && ~log
        lgd = legend('original data','imputed data');
        if how
            title(lgd,'just missing values')
        else title(lgd,'whole data matrix');
        end
    end
end
