% Multivariate analysis based on the linear model implementation in the
% R-package limma.

function res = limma(O,X,varargin)

dat = get(O,'data');

if sum(sum(X==1,1)==size(X,1))<1 % no intercept
    X = [ones(size(X,1),1),X]; % add intercept;
end

% determine features where the linear model has full rank:
b = NaN(size(X,2),size(dat,1));
for i=1:size(dat,1)
    y = dat(i,:)';
    drin = ~isnan(y);
    
    Xinv = pinv(X(drin,:));
    if rank(Xinv)==size(X,2)
        b(:,i) = Xinv*y(drin);
    end
end
coefs = b';

ok = find(sum(isnan(coefs),2)==0);
fprintf('%i out of %i features have full rank (%.2f%s)\n',length(ok),size(dat,1),length(ok)/size(dat,1)*100,'%');
fprintf('limma started for full-rank features ...\n');
erg = limma(dat(ok,:),X);
fprintf(' Finished.\n');

res.coefficients = NaN(size(dat,1),size(X,2));

res.coefficients(ok,:) = erg.coefficients;
res.X = erg.X;
res.coefs = erg.coefs;
res.coefs.indices = ok;

res.p = NaN(size(dat,1),size(X,2));
for i=1:length(erg.coefs.f_pvalue)
    res.p(res.coefs.indices,i) = erg.coefs.t_mod_pvalue{i};
end









    

