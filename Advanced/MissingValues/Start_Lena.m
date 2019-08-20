
file ='Data/dataset_lena.txt';         % Load proteinGroups.txt

O = OmicsData(file);                         % Write in class O
O = log2(O);   
O = O(1:500,1:5);

O = DIMA(O);