% O = OmicsRenameSamples(O,pat,rep)
% 
%   Renaming samplenames by replacements, i.e. regexprep
% 
%   pat     pattern(s), i.e. string or cell of strings.
%           2nd argument of regexprep
%           Regular expressions are valid, see regexp.m
% 
%   rep     replacement(s), i.e. string or cell of strings.
% 
% See also regexp

function O = OmicsRenameSamples(O,pat,rep)

sn = get(O,'snames');
sn = regexprep(sn,pat,rep);
O = set(O,'snames',sn);

