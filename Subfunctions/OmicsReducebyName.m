
function O = OmicsReducebyName(O,name)
% e.g. O = ReducebyName(O,'A_')
% Reduces dataset to SampleNames which include 'A_'

if nargin<2
    error('OmicsData/ReducebyName.m requires at least 2 input arguments. ReducebyString(O,name).')
end

drin = find(~cellfun(@isempty,strfind(get(O,'snames'),name)));
O = O(:,drin);
