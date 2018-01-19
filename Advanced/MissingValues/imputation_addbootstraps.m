function O = imputation_addbootstraps(O)

if ~exist('O','var')
    error('OmicsData object has to be passed in to function imputation_addbootstraps.m.')
end
% Get variables from class
Y = get(O,'data_imput');
dataset = get(O,'dataset');

% more than 1 dataset ?
if size(dataset,2)>1
    for i=1:size(dataset,2)
        for j=1:size(dataset{i},2)
            Y(:,:,i) = Y(:,:,i)+Y(:,:,j);     % Add up datasets
        end
    end
end