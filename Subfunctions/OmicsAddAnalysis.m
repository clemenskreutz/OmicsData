%   O = OmicsAddAnalysis(O,descr)
% 
% This function should be used to add analysis annotation to O.analyses
% 
%   Example:

function O = OmicsAddAnalysis(O,descr)

ana = get(O,'analyses');

newana = struct;
newana.datafield = get(O,'default_data');
newana.description = descr;
ana{end+1} = newana;

O = set(O,'analyses',ana);
