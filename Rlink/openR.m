%   This function is for initialization purpose.
%   The global variable "global OPENR" is iniitalized and empty workspaces
%   are created.
% 
%   The path to the R executable has to be set by hand.
% 
% Example
%   openR
%   global OPENR
%   OPENR.Rexe = '/user/bin/R/R.exe'

function openR
global OPENR
OPENR = struct;
if exist(['C:' filesep 'Program Files' filesep 'R'],'dir')
    version = dir(['C:' filesep 'Program Files' filesep 'R' filesep]);
    if exist(['C:' filesep 'Program Files' filesep 'R' filesep version(end).name filesep 'bin' filesep 'x64'],'dir')
        OPENR.Rexe = ['"C:' filesep 'Program Files' filesep 'R' filesep version(end).name filesep 'bin' filesep 'x64' filesep 'R.exe"'];
    elseif exist(['C:' filesep 'Program Files' filesep 'R' filesep version(end).name filesep 'bin' filesep 'i386'],'dir')
        OPENR.Rexe = ['"C:' filesep 'Program Files' filesep 'R' filesep version(end).name filesep 'bin' filesep 'i386' filesep 'R.exe"'];
    else
        error('OmicsData/Rlink/openR.m: Change your home directory of R here. You can find the directory by R.home() in R.')
    end
elseif exist([filesep 'usr' filesep 'local' filesep 'lib' filesep 'R'],'dir')
    if exist([filesep 'usr' filesep 'local' filesep 'lib' filesep 'R' filesep 'bin' filesep 'R.exe'],'dir')
        OPENR.Rexe = ['"' filesep 'usr' filesep 'local' filesep 'lib' filesep 'R' filesep 'bin' filesep 'R.exe"'];
    elseif exist([filesep 'usr' filesep 'local' filesep 'lib' filesep 'R' filesep 'Rscript.exe'],'dir')
        OPENR.Rexe = ['"' filesep 'usr' filesep 'local' filesep 'lib' filesep 'R' filesep 'Rscript.exe"']; 
    else
        error('OmicsData/Rlink/openR.m: Change your home directory of R here. You can find the directory by R.home() in R.')
    end
elseif exist('/usr/bin/R')==2
    OPENR.Rexe = '/usr/bin/R';
else
    error('OmicsData/Rlink/openR.m: Change your home directory of R here. You can find the directory by R.home() in R.')
end
OPENR.libraries = {'R.matlab','amap'};

%% create empty workspaces
save putRdata
save putRdata_cellstr

warning('off','MATLAB:DELETE:FileNotFound');
delete('getRdata.mat')
warning('on','MATLAB:DELETE:FileNotFound');

