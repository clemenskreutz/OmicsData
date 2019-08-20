
file ='Data/dataset_lena.txt';         % Load proteinGroups.txt

O = OmicsData(file);                         % Write in class O
O = log2(O);   
O = O(1:500,1:5);

%% Simulate pattern
O = set(O,'deleteemptyrows',true);           % delete rows with all nan
O = set(O,'npat',5);						 % how many pattern simulations
O = DIMA(O);