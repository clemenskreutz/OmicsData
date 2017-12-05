% lab = str2label(str)
%   
%   Entfernt Unterstriche, und konvertiert "e-00" zu "e-"
% 
%   str     string oder cell of strings

function lab = str2label(str)
if(iscell(str))
    for i=1:length(str)
        lab{i} = str2label(str{i});
    end
    if(size(str,2)==1)
        lab = lab';
    end    
else        
    lab = strrep(str,'^','');
    lab = strrep(lab,'_',' ');
    lab = strrep(lab,'e-00','e-');
    lab = strrep(lab,'e-0','e-');
    lab = strrep(lab,'e+000','');
    lab = strrep(lab,'e+00','e+');
    lab = strrep(lab,'e+0','e+');
    lab = regexprep(lab,'e\+$','');
    lab = regexprep(lab,'e\+\s','');
    lab = strrep(lab,'.000000e','e');
    lab = strrep(lab,'.100000e','.1e');
    lab = strrep(lab,'.200000e','.2e');
    lab = strrep(lab,'.300000e','.3e');
    lab = strrep(lab,'.400000e','.4e');
    lab = strrep(lab,'.500000e','.5e');
    lab = strrep(lab,'.600000e','.6e');
    lab = strrep(lab,'.700000e','.7e');
    lab = strrep(lab,'.800000e','.8e');
    lab = strrep(lab,'.900000e','.9e');
end