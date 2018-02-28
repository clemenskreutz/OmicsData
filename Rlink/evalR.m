%   evalR(cmd)
% 
%   cmd     a command line in R syntax
% 
%   This function only collects R commands. They are executed if getRdata
%   or putRdata is called next time.

function evalR(cmd)

global OPENR
if ~isfield(OPENR,'cmd')
    OPENR.cmd = {cmd};
else
    OPENR.cmd{end+1} = cmd;
end



