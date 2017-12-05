% O = OmicsNewID
% 
%   This function generates an Identifier which can be used to quickly
%   check whether two OmicsData sets contain the same data.
% 
%   It is called if the data is changed (e.g. by normalization) or
%   filtered (e.g. with respect to features or samples).

function O = OmicsNewID(O)
O = set(O,'ID',dec2hex(round(rand*1e15)));
