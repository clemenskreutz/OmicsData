% [p,t,fold,varest,stats] = regress(O,X)
%
%   X       design matrix   [nsamples x nEffects]
%
%   ind_ftest   @cell, each cell entry is an array of indices indicating
%   the columns over which an F-test is applied.
%
%   Regression function for design matrix X applied to each row (feature)
%   of the data.
%   Features with too many NaNs are not analyzed (result=NaN).
%
%   Attention:
%   The analysis is always performed with an intercept term.
%   If the intercept columns is missing, it is added.
%
%
% [p,t,fold,varest,stats] = regress(O,X,ind_ftest)
%

function [p,t,fold,varest,stats] = regress(O,X,ind_ftest)
if(~exist('ind_ftest','var') || isempty(ind_ftest))
    ind_ftest = cell(0);
elseif(~iscell(ind_ftest))
    ind_ftest = {ind_ftest};
end

y = get(O,'data');
if(size(y,2) ~= size(X,1))
    error('@OmicsData/regress.m: size(data,2) ~= size(X,1)')
end

if(sum(sum(abs(X),1)==size(X,1))==0)
    disp('regress.m: Intercept is added.');
    interAdded = 1;
    Xinter = [ones(size(X,1),1),X]; % 1st column Intercept hinzufuegen
else
    Xinter = X;
    interAdded = 0;
end

try
    %         [b,~,~,~,stats] = regress(y(drin,:)',Xinter);
    [b,bSE,pval,dummy,fstat,vest,C,Res] = regress_reg(y',Xinter,0,0);
    res = Res';
    
%     for i=1:size(y,1)
%         fold(:,i) = regress(y(i,:)',Xinter);
%             b(isnan(bSE))=NaN;
%             fstat = stats(2);
%             vest  = stats(4)
%             pval  = stats(3);
%     end
catch
    save error
    rethrow(lasterror)
end
varest = vest';
if(interAdded==1)
    p = pval(2:end,:)';
    t = fstat(2:end,:)';
    fold = b(2:end,:)';
    foldSE = bSE(2:end,:)';
else
    p = pval(1:end,:)';
    t = fstat(1:end,:)';
    fold = b(1:end,:)';
    foldSE = bSE(1:end,:)';
end


F = cell(size(ind_ftest));
P_ftest = cell(size(ind_ftest));
for i=1:length(ind_ftest)
    warning('implementation not perfect. Check p-value calculation for F-Test.')
    
    
    Xtmp = Xinter(:,setdiff(1:size(Xinter,2),ind_ftest{i}));
    Xtmp = [Xtmp,sum(Xinter(:,ind_ftest{i}),2)];
%     warning('stats:regress:RankDefDesignMat','off')
    [b,bSE,pval,dummy,fstat,vest,C,Res] = regress_reg(y',Xtmp,0,0);
%     warning('stats:regress:RankDefDesignMat','on')
    
    T = fold(:,ind_ftest{i})./foldSE(:,ind_ftest{i});
    T = T - mean(T,2)*ones(1,size(T,2));
    BGSS = sum((T).^2,2);
    %         WGSS = sum(res.^2,2);
    WGSS = sum(Res'.^2,2);
    %         F{i} = (BGSS./(length(ind_ftest{i})-1))  ./  (WGSS./(size(res,2)-size(fold,2)));
    %         P_ftest{i} = 1-fcdf(F{i},length(ind_ftest{i})-1,size(res,2)-size(fold,2));
    F{i} = (BGSS./(length(ind_ftest{i})-1))  ./  (WGSS./(size(res,2)-size(Xtmp,2)));
    P_ftest{i} = 1-fcdf(F{i},length(ind_ftest{i})-1,size(res,2)-size(Xtmp,2));
end

stats.foldSE = foldSE;
stats.F = F;
stats.P_ftest = P_ftest;




