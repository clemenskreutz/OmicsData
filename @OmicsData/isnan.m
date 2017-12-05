% Isnan = isnan(O)
% 
%   This function makes the same as isnan.m for the data in the object.

function out = isnan(O)

out = isnan(get(O,'data'));

