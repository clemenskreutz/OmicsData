function p = imputation_anova(O)

if ~exist('O','var')
    error('OmicsData object has to be passed in to function imputation_anova.m.')
end

dat_full = get(O,'data_full');
if ~exist('dat_full','var')
    error('Anova after imputation just possible if missing values are known beforehand.')
end
mispat = get(O,'mis_pat');
dat_compare = dat_full.*mispat;
Imp = get(O,'data_imput');
if size(Imp,3)==size(mispat,3)
    Imp = Imp.*mispat;
else
    for i=1:size(Imp,3)
        Imp(:,:,i) = Imp(:,:,i).*mispat;
    end
end

for i=1:size(dat_compare,3)
    if isempty(Imp(:,:,i))
        fprintf(['Imputation matrix ' num2str(i) ' is empty.'])
    else
        Y = Imp(:,:,i);
        Matrix = 0;
        Matrix = [dat_compare(dat_compare(:,:,i)~=0),Y(Y~=0)];
        p(i) = anova1(Matrix);
    end
end