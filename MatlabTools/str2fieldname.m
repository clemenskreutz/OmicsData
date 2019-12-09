% str = str2fieldname(str)
% Konvertiert einen string so, dass er als Feldname eines Structs verwendet werden kann.
% Ersetzt  +-*/\|&, und Leerzeichen.
% 

function str = str2fieldname(str,rep)
if(~exist('rep','var') | isempty(rep))
    rep = '';
end

if(~iscell(str))
    str = {str};
    nocell=1;
else
    nocell=0;
end

for i=1:length(str)
    str{i} = strrep(str{i},':',rep);
    str{i} = strrep(str{i},'-',rep);
    str{i} = strrep(str{i},'+',rep);
    str{i} = strrep(str{i},'*',rep);
    str{i} = strrep(str{i},'/',rep);
    str{i} = strrep(str{i},'\',rep);
    str{i} = strrep(str{i},'|',rep);
    str{i} = strrep(str{i},'&',rep);
    str{i} = strrep(str{i},',',rep);
    str{i} = strrep(str{i},';',rep);
    str{i} = strrep(str{i},'#',rep);
    str{i} = strrep(str{i},'.',rep);
    str{i} = strrep(str{i},' ',rep);
    str{i} = strrep(str{i},'%',rep);
    str{i} = strrep(str{i},'>',rep);
    str{i} = strrep(str{i},'<',rep);
    str{i} = strrep(str{i},'(',rep);
    str{i} = strrep(str{i},'$',rep);
    str{i} = strrep(str{i},'^',rep);
    str{i} = strrep(str{i},')',rep);
    str{i} = strrep(str{i},']',rep);
    str{i} = strrep(str{i},'[',rep);
    str{i} = strrep(str{i},'~',rep);
    str{i} = strrep(str{i},'=',rep);
    if(sum(regexp(str{i},'\d')==1)>0)
        str{i} = ['f_',str{i}];
    end
end

if(nocell==1)
    tmp = str;
    clear str
    str = tmp{1};
end

 