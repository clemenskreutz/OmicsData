
function O = OmicsReducebyName(O,name)

% e.g. O = ReducebyName(O,'A_')
% Reduces dataset to SampleNames which include 'A_'

if nargin<2
    error('OmicsData/ReducebyName.m requires at least 2 input arguments. ReducebyString(O,name).')
end

dat = get(O,'data');
Names = get(O,'SampleNames');

reducedata = [];
for i=1:length(Names)
    if strfind(Names{i},name)
        reducedata = [reducedata i];
    end
end
dat = dat(:,reducedata);
O = set(O,'data',dat,['Reduced by name (' name ')']);
