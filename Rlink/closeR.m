function closeR
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
    
    delete('putRdata.mat')
    delete('putRdata_cellstr.mat')
% end
warning('on','MATLAB:DELETE:FileNotFound');

