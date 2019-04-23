% O = ReducebyName(O,pattern)
% 
% Filtering of the dataset to SampleNames which include a pattern.
% 
%   pattern     a pattern which is searched via strfind in the SampleNames
% 
% Example:
% O = OmicsReducebyName(O,'A_')

function O = OmicsReducebyName(O,pattern)

if nargin<2
    error('OmicsData/ReducebyName.m requires at least 2 input arguments. ReducebyString(O,name).')
end

drin = find(~cellfun(@isempty,strfind(get(O,'snames'),pattern)));
O = O(:,drin);
