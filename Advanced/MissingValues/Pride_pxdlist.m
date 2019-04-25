files = dir('D://PrideData/**/*proteinGroups*.txt');  
fid = fopen('pxdlists.txt','w');
fid2 = fopen('start_pride_peptides.sh','w');    
fprintf(fid2,'%s\n','#!/bin/bash');
for i=1:length(files)
    folders = strsplit(files(i).folder,'\');
    PXDidx = find(contains(folders,'PXD'));
    fprintf(fid,'%s\n',folders{PXDidx});
    fprintf(fid2,'%s %s %s %s\n','bash get_pride_peptides.sh 1',folders{PXDidx-2},folders{PXDidx-1},folders{PXDidx});
end
fclose(fid);
fclose(fid2);
    