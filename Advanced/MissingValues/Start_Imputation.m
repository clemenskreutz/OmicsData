
global O

% Load file
file = 'Data/proteinGroups7044_absmax.txt';  
 
O = OmicsData(file);
O = O(:,~all(isnan(O)));                      % delete columns/experiments with all nan
if max(O)>1000                                % data not logged yet? Log!
    O=log2(O);   
end
if ~checknan(O)                                  % no nans in data, so write zeros as nans
    dat = get(O,'data');                          
    dat(dat==0) = nan;  
    O = set(O,'data',dat,'Replaced 0 by nan.');
end

O = set(O,'deleteemptyrows',true);
O = set(O,'boot',5);

analysemissing
imputation

%imputation_original