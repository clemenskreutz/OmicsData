function T = imputation_analysis(O,log)

if ~exist('O','var')
    error('OmicsData object has to be passed in to function imputation_boxplot.m.')
end
% Get variables from class
dat = get(O,'data_full');
Imp = get(O,'data_imput');
method = get(O,'method_imput');
mispat = get(O,'mis_pat');

% calculate just imputed values
dat_mis = nan(size(mispat,1),size(mispat,2),size(mispat,3));
for nn = 1:size(mispat,3)
    dat_mis(:,:,nn) = dat.*mispat(:,:,nn);
    dat_imp = nan(size(Imp,1),size(Imp,2),size(Imp,3),size(Imp,4));
end
for i=1:size(Imp,4)
    dat_imp(:,:,:,i) = Imp(:,:,:,i).*mispat;
end

% Log ?
if ~exist('log','var') || isempty(log)
    if range(dat)>10^3
        log = true;
    else log = false;
    end
end
if log
%     dat(dat<=0) = nan;              % for numbers <=0 log not possible
%     dat = log10(dat);               % Data is ignored
%     Imp(Imp<=0) = nan;
%     Imp = log10(Imp);    
    dat_mis(dat_mis<=0) = nan;
    dat_mis = log10(dat_mis);
    dat_imp(dat_imp<=0) = nan;
    dat_imp = log10(dat_imp);
end

% Create statistic matrix

% dat = dat(~isnan(dat));                 % Write data in one column, to suppress columnwise boxplot
% Imp = Imp(~isnan(Imp(:,:,i)));
Y = dat_mis(~isnan(dat_mis));
T = table([nanmean(Y);nanstd(Y);nanmin(Y);nanmax(Y);0;0]);
T.Properties.VariableNames = {'original'};
T.Properties.RowNames = {'mean','std','min','max','Diff','LS'};

for i=1:size(dat_imp,4)
  
     % sum of square
    Quad = 0;
    if length(size(dat_mis)) == 3
        Quad = Quad + sum(sum(nansum((dat_mis - dat_imp(:,:,:,i)).^2)));        
    elseif length(size(dat_mis)) == 2
        for j=1:size(dat_imp,3)
            Quad = Quad + sum(nansum((dat_mis - dat_imp(:,:,j,i)).^2));
        end
    end
    Quad = Quad/size(Imp,3);
    
 X = dat_imp(~isnan(dat_imp(:,:,:,i))); 
 T = [T table([nanmean(X); nanstd(X); nanmin(X); nanmax(X); nanmean(X)-nanmean(Y);Quad])];
 T.Properties.VariableNames(i+1) = method(i);
end
figure
for i=1:size(dat_imp,4)
    histogram(dat_imp(:,:,:,i)-dat_mis,'BinWidth',T{5,i+1}/3+0.1)
    hold on
    xlabel('Difference Imputation-True')
    ylabel('Frequency')
end
legend(method)