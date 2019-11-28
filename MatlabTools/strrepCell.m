% s = strrepCell(s,pat,rep)
%    strrep für viele Paare aus Pattern und Replacement.
%
% s = strrepCell(s,pat,rep, exact)
%
%   s       string oder Zelle von strings
%   pat     Zelle aus Patterns, z.B. {'.',',','_'}
%   rep     Zelle aus Strings mit Replacements, z.B. {' ','-',' '}
%   exact   Default: 0. Andernfalls muss das pattern exact mit s
%           übereinstimmen.
%
%  length(pat) must be equal to length(rep).
%  Die Reihenfolge kann evtl eine Rolle spielen.
%
% Bsp:
% strrepCell('Maus',{'Maus','Katze','Eva'},{'Tier','Tier','Mensch'},1)
% strrepCell({'Maus','Eva'},{'Maus','Katze','Eva'},{'Tier','Tier','Mensch'},1)

function sout = strrepCell(s,pat,repl,exact)
if(~iscell(pat))
    error('pattern must be a cell of strings.')
end
if(~exist('exact','var') | isempty(exact))
    exact = 0;
end

if(~exist('repl','var') | isempty(repl))
    repl = '';
end


if(~iscell(s))
    scell = {s};
else
    scell = s;
end

if(~iscell(repl))
    Rep = repl;
    repl = cell(size(pat));
    for i=1:length(repl)
        repl{i}=Rep;
    end
elseif(length(pat) ~= length(repl)) && (length(s) ~= length(repl))
    if length(pat)==1
        for i=2:length(repl)
            pat{i} = pat{1};
        end
    else
        error('length(pattern) ~= length(replacement)')
    end
end

if(exact==0)
    for is = 1:length(scell)
        if length(pat)==1
            scell{is} = strrep(scell{is},pat,repl{is});
        else
            for i=1:length(pat)
                if(~isempty(scell{is}))
                    scell{is} = strrep(scell{is},pat{i},repl{i});
                end
            end
        end
    end
else
    for is = 1:length(scell)
        for i=1:length(pat)
            if(length(scell{is})==length(pat{i}))
                scell{is} = strrep(scell{is},pat{i},repl{i});
            end
        end
    end
end

if(~iscell(s))
    sout = scell{1};
else
    sout = scell;
end