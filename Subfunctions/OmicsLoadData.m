function OmicsLoadData(file)

global O

if ~exist('file','var') || isempty('file')
    file = 'Data/dataset02_tbrucei_ATOM_depletome_proteins_christian.txt';
end
if isnumeric(file)
    if file==1
        filex = 'Data/dataset01_yeast_oxICAT.xlsx';
        O = OmicsData(filex);
    elseif file==2
        filex = 'Data/dataset02_tbrucei_ATOM_depletome_proteins_christian.txt';
        O = OmicsData(filex);
        O = O(:,1:size(get(O,'data'),2)-1);
    else
        filex = 'Data/dataset03_mouse_comparison_of_cell_lines_proteins_lena.xlsx';
        O = OmicsData(filex);
        O = O(:,7:size(get(O,'data'),2));
    end
else
    O = OmicsData(file);
end