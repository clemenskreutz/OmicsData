function deleteR
warning('off','MATLAB:DELETE:FileNotFound');
% try
    delete('evalR.R');
    delete('evalR.Rout');
    delete('evalR.rData');
    
    delete('getRdata.mat');
    delete('getRdata.mat.tmp');
    delete('getRdata.Rdata');
    delete('getRdata.R');
    delete('getRdata.Rout');
    
% end
warning('on','MATLAB:DELETE:FileNotFound');

