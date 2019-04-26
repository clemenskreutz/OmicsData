% erg = limma(dat,X,coefs,meth)
% 
%   dat
% 
%   X       Design matrix
%           dat(i,:)' = X*p(i,:)
% 
%   coefs   Interesting parameters
%           X(:,coefs)*p(coefs)
% 
%   meth    'ls' (least squares) [Default]
%           'robust'
% 
% Example:
% dat = randn(100,6)
% X = [ones(6,1),[zeros(3,1);ones(3,1)]];
% erg = limma(dat,X);
% 
% m1=mean(dat(:,1:3),2);
% plot(m1,erg.coefficients(:,1),'.')
% m2=mean(dat(:,4:6),2);
% plot(m2-m1,erg.coefficients(:,2),'.')
% [dummy,p,ci,stats] = ttest2(dat(:,1:3)',dat(:,4:6)',[],[],'equal');

function erg = limma(dat,X,coefs,meth)
if(~exist('coefs','var') | isempty(coefs))
    coefs = 1:size(X,2);
end
if(~exist('meth','var') | isempty(meth))
    meth = 'ls'; % ordinary least squares
    %     meth = 'robust';
end

openR;
global OPENR
OPENR.libraries{end+1} = 'limma';

evalR('require(limma)')
putRdata('dat',dat);
putRdata('X',X);

% try
    evalR('fit <- lmFit(dat,design=X)');
% catch
%     saveRimage('error')
%     error(lasterr)
% end
evalR('fit <- eBayes(fit)')
evalR('coeffs <- coefficients(fit)');
erg.coefficients = getRdata('coeffs');
erg.X = X;
% erg.coefs = cell(size(coefs))
for i=1:length(coefs)
    evalR(['erg <- as.data.frame(fit[,',num2str(coefs(i)),'])'])
    
    evalR('tmp_coef <- erg[,"coefficients"]');
    evalR('tmp_df_res <- erg[,"df.residual"]');
    evalR('tmp_sigma <- erg[,"sigma"]');
    evalR('tmp_stdev <- erg[,"stdev.unscaled"]');
    evalR('tmp_s2 <- erg[,"s2.post"]');
    evalR('tmp_t <- erg[,"t"]');
    evalR('tmp_p <- erg[,"p.value"]');
    evalR('tmp_F <- erg[,"F"]');
    evalR('tmp_Fp <- erg[,"F.p.value"]');

    erg.coefs.coef{coefs(i)}= getRdata('tmp_coef');
    erg.coefs.df_residual{coefs(i)}= getRdata('tmp_df_res');
    erg.coefs.sigma{coefs(i)}= getRdata('tmp_sigma');
    erg.coefs.stdev_unscaled{coefs(i)}= getRdata('tmp_stdev');
    erg.coefs.s2_post{coefs(i)}= getRdata('tmp_s2');
    erg.coefs.t_mod{coefs(i)}= getRdata('tmp_t');
    erg.coefs.t_mod_pvalue{coefs(i)}= getRdata('tmp_p');
    erg.coefs.f{coefs(i)}= getRdata('tmp_F');
    erg.coefs.f_pvalue{coefs(i)}= getRdata('tmp_Fp');
end
closeR;


