function O = OmicsPre(O)

dat_load = get(O,'data');
O = set(O,'data_load',[]);              % Put in container, so always keeps size
O = set(O,'data_load',dat_load,'data from file');

if max(O)>100                                % data not logged yet? Log!
    O=log2(O);   
end
%% Nans?
if ~checknan(O)                                  % no nans in data, so write zeros as nans
    dat = get(O,'data');                          
    dat(dat==0) = nan;  
    O = set(O,'data',dat,'Replaced 0 by nan.');
end
O = O(:,~all(isnan(O)));                      % delete columns/experiments with all nan
    
