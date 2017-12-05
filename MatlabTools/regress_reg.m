% [b,bSE,pval,sig_post,tstat,varest,C,resout] = regress_reg(y,X,varprior,prior_weight)
% 
%   b   	(npara,ndatasets);
%   bSE 	(npara,ndatasets);
%   pval	(npara,ndatasets);
%   sig_post(npara,ndatasets);
%   varest 	(1,ndatasets);
%   prior_weight        scalar or length(prior_weight)==ndatasets

function [b,bSE,pval,sig_post,tstat,varest,C,resout] = regress_reg(y,X,varprior,prior_weight)
% prior_weight = 0.5;

npara = size(X,2);
ndatasets = size(y,2);

if(length(prior_weight)==1)
    prior_weight = ones(ndatasets,1)*prior_weight;
end
if(length(varprior)==1)
    varprior = ones(ndatasets,1)*varprior;
end

b   = NaN*ones(npara,ndatasets);
bSE = NaN*ones(npara,ndatasets);
pval= NaN*ones(npara,ndatasets);
sig_post = NaN*ones(npara,ndatasets);
varest = NaN*ones(1,ndatasets);

Xinv = pinv(X);
XX1 = inv(X'*X);

if(nargout>7)
    resout = NaN(size(y));
end

for i=1:size(y,2)
    if sum(isnan(y(:,i)))>0
%     [b,bint,r,rint,stats] = regress(y(:,i),X);
        [b(:,i),bse] = regress(y(:,i),X);
        b(b(:,i)==0 & bse(:,1)==0 & bse(:,2)==0, i) = NaN;  % non-identifiable parameters
       
    % b2(:,i) = (X\y(:,i));
    else  % faster
        b(:,i) = (Xinv*y(:,i));
    end
    
    res = y(:,i)-X*b(:,i);
    if(nargout>7)
        resout(:,i) = res;
    end
    ndat = sum(~isnan(res));
    nparaTmp = sum(~isnan(b(:,i)));
    if ndat>nparaTmp+1;
        varest(i) =  1/(ndat-nparaTmp)* nansum(res.^2) ;
        var_post = (1-prior_weight(i))*varest(i) + prior_weight(i)*varprior(i);
    else
        varest(i) = NaN;
        if prior_weight(i)==1
            var_post = varprior(i);
        else
            var_post = NaN;
        end
    end

    C = var_post*XX1;
%     C = var_post/(X'*X);
    bSE(:,i) = sqrt(diag(C));

    sig_post(:,i) = sqrt(var_post);
    % p = X'*X./npara./varpost

    df = ndat-npara;

    tmax = max(abs( b(:,i)./bSE(:,i)),abs(- b(:,i)./bSE(:,i)));
    if sum(isnan(tmax))==0
        pval(:,i) = 2*(1-tcdf(tmax,df));
    else
        pval(:,i) = NaN;
    end
end
tstat = b./bSE;


