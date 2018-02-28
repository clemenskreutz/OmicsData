% Maximum-likelihood fitting of univariate distributions allowing
% parameters to be held fixed if desired. 
% 
% fitdistr(x, densfun, start, varargin)
% 
%   x           A numeric vector.
%   densfun     Either a character string or a function returning a density evaluated at its first argument.
%               Distributions:
%               'beta', 'cauchy', 'chi-squared', 'exponential', 'f', 'gamma', 
%               'log-normal', 'lognormal', 'logistic', 'negative binomial', 
%               'normal', 't', 'uniform' and 'weibull' are recognised, case being ignored.
%               DEFAULT: 'normal' 
%   start       A struct giving the parameters to be optimized with initial values. 
%               This can be omitted for some of the named distributions.
%               Check R manual of fitdistr (MASS package) for details.
% 
%   Check ?fitdistr in R for further optione, e.g. for fixing parameters
%   via upper/lower bounds.
% 
% Examples:
% x = random('chi2',10,[1000,1]);
% erg = fitdistr(x)
% 
% hist(x)
% erg = fitdistr(x,'chi-squared',struct('df',1));  

function erg = fitdistr(x, densfun, start)
if(~exist('densfun','var') || isempty(densfun))
    densfun = 'normal';
end
if(size(x,1)==1)
    x=x';
end


openR;

global OPENR
OPENR.libraries{end+1} = 'MASS';

putRdata('x',x);
putRdata('densfun',densfun);
if(~exist('start','var') | isempty(start))
    evalR('erg <- fitdistr(x,densfun)');   
else
    if(~isa(start,'struct'))
        error('fitdistr.m: start muss als struct übergeben werden.')
    else
        f = fieldnames(start);
        evalR('start = list()')
        for i=1:length(f)
            putRdata(f{i},start.(f{i}));
            evalR(['start$',f{i},' <-',f{i}])
        end
%         evalR('save.image("test.RData")')
        try
            evalR('erg <- fitdistr(x,densfun,start=start)');   
        catch
            disp('fistdistr.m: Providing initial values did not work.')
            evalR('erg <- fitdistr(x,densfun)');               
        end
    end
end

evalR('est <- erg$estimate')
evalR('sdest <- erg$sd')
evalR('names <- names(erg$estimate)')

erg.SE  = getRdata('sdest');
erg.est = getRdata('est');
erg.names = getRdata('names');
closeR;



