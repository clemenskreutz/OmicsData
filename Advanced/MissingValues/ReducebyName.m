
function O = ReducebyName(O,name,str1)

% e.g. O = ReducebyName(O,'A_','Light')
% Reduces dataset to SampleNames which include 'A_'
% Creates/Saves design matrix X

if nargin<3
    error('OmicsData/ReducebyName.m requires at least 3 input arguments. ReducebyName(O,name,strpattern).')
end

dat = get(O,'data');
Names = get(O,'SampleNames');

reducedata = [];
rem = [];
for i=1:length(Names)
    if strfind(Names{i},name)
        reducedata = [reducedata i];
        if strfind(Names{i},str1)
            rem = [rem length(reducedata)];
        end
    end
end
O = O(:,reducedata);
%O = set(O,'data',dat,['Reduced by name (' name ')']);

%% Design matrix
% logreg compares 'Day' and 'Light'
X = zeros(length(reducedata),1);
X(rem) = 1;
O = set(O,'X',X,['Reduced by name (' name ')']);
% logreg for individual groups
% X = [ ones(length(rem),1); zeros(length(rem2),1) ];
% X(:,2) = flipud(X);
