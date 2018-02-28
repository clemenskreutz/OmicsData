% This example illustrates the functionality of the Rlink
% 
% The FDR calculation implemented in R as p.adjust is evoked.


addpath('E:\clemens\Repositories\OmicsData\Rlink');

openR

global OPENR
OPENR.Rexe = '"c:\Program Files\R\R-3.3.1\bin\i386\R.exe"' % windows syntax
OPENR.libraries{end+1} = 'anotherLibrary'; % add a library which is loaded via require(...) in R. It has to be installed.

p = rand(1000,1).^4;
putRdata('pvalues',p);
evalR('pfdr <- p.adjust(pvalues)');
fdrs = getRdata('pfdr');

subplot(2,1,1)
hist(p,100)
subplot(2,1,2)
hist(fdrs,100)



