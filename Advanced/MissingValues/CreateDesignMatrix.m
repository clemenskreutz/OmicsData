
function O = CreateDesignMatrix(O,str1)

% e.g. O = CreateDesignMatrix(O,'A_','Light')
% Creates/Saves design matrix X
% includes 1s at SampleNames = str1

if nargin<2
    error('OmicsData/CreateDesignMatrix.m requires at least 2 input arguments. CreateDesignMatrix(O,name).')
end

dat = get(O,'data');
Names = get(O,'SampleNames');

rem = [];
for i=1:size(dat,2)
    if strfind(Names{i},str1)
        rem = [rem i];
    end
end

%% Design matrix
% logreg compares str1 against control (glmfit automatically includes intercept)
X = zeros(size(dat,2),1);
X(rem) = 1;
O = set(O,'X',X);

% logreg for individual groups
% X(:,2) = flipud(X);