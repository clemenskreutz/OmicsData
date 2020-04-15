% evalR_writeAndExecute
% 
%   This function is called in putRdata and getRdata to execute R commands
%   which are collected and buffered by evalR commands. Usually, this
%   function is NOT directly called by the user.
% 
%   The reason for buffering is that it is faster to execute serveral R
%   commands together.

function evalR_writeAndExecute
global OPENR

if isfield(OPENR,'cmd')
    fid = fopen('evalR.R','w');
    fprintf(fid,'%s\n',['setwd("',strrep(pwd,filesep,'/'),'")']);
    
    if isfield(OPENR,'myLibPath') && ~isempty(OPENR.myLibPath) && exist(OPENR.myLibPath,'file')  
        fprintf(fid,'%s\n',['.libPaths("',OPENR.myLibPath,'")']); % my own library
    end
    for i=1:length(OPENR.libraries)
        fprintf(fid,'require(%s)\n',OPENR.libraries{i});
    end
    fprintf(fid,'rm(list=ls())\n');
    fprintf(fid,'\n');
    
    fprintf(fid,'%s\n','if(!file.exists("evalR.Rdata"))');
    fprintf(fid,'%s\n','    save.image(file="evalR.Rdata")');
    
    fprintf(fid,'%s\n','data_putRdata <- readMat("putRdata.mat")');
    fprintf(fid,'%s\n','attach(data_putRdata)');
    
    fprintf(fid,'%s\n','cellstrs <- readMat("putRdata_cellstr.mat")');
    fprintf(fid,'%s\n','for (i in 1:length(cellstrs)){');
    fprintf(fid,'%s\n','    tmp <- cellstrs[[i]]');
    fprintf(fid,'%s\n','    cellstrs[[i]] <- array()');
    fprintf(fid,'%s\n','    for (j in 1:length(tmp)){');
    fprintf(fid,'%s\n','        cellstrs[[i]][j] <- tmp[[j]][[1]]');
    fprintf(fid,'%s\n','        }');
    fprintf(fid,'%s\n','    }');
    fprintf(fid,'%s\n','attach(cellstrs)');
    fprintf(fid,'rm(i)\n');
    fprintf(fid,'rm(j)\n');
    
    %fprintf(fid,'%s\n','load("evalR.rData")');
    
    fprintf(fid,'\n\n#####  cmds  #####\n');
    for i=1:length(OPENR.cmd)        
        fprintf(fid,'%s\n',OPENR.cmd{i});
        %disp(['R >   ',OPENR.cmd{i}])
    end
    fprintf(fid,'#####  cmd  #####\n\n\n');
    
    fprintf(fid,'%s\n','varnames <- unique(setdiff(ls(),c("data_putRdata","tmp","cellstrs")))'); % al variables which were previously in evalR.mat and are newly calculated (by cmd)
    % fprintf(fid,'print(varnames)\n');
    fprintf(fid,'%s\n','save(file="evalR.Rdata",list=varnames)');
    
    fclose(fid);
    
    %fprintf('Starting execution now ... ')
    cmd = sprintf('%s CMD BATCH --vanilla --slave "%s%sevalR.R"',OPENR.Rexe,pwd,filesep);
    status = system(cmd);

    %fprintf(' finished.\n');    
    OPENR = rmfield(OPENR,'cmd');
end

