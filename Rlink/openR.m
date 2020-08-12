%   This function is for initialization purpose.
%   The global variable "global OPENR" with paths to the R executable and 
%   libraries is initialized and empty workspaces are created.
% 
%   The path to the R executable is set automatically or can be specified
%   by the user:
% path      - path to the executable R.exe
% libpath   - path to the R libraries
% 
% Example:
%   path = '/usr/local/lib/R/bin/R.exe';
%   libpath = '~/R_library';
%   openR(path,libpath)
%   evalR('dat <- c(5,5,5)')
%   dat = getRdata('dat');
%   closeR

function openR(path,libpath)

global OPENR
OPENR = struct;

<<<<<<< HEAD
if exist(['C:' filesep 'Program Files' filesep 'R'],'dir')
    version = dir(['C:' filesep 'Program Files' filesep 'R' filesep]);
    if exist(['C:' filesep 'Program Files' filesep 'R' filesep version(end).name filesep 'bin' filesep 'x64'],'dir')
        OPENR.Rexe = ['"C:' filesep 'Program Files' filesep 'R' filesep version(end).name filesep 'bin' filesep 'x64' filesep 'R.exe"'];
    elseif exist(['C:' filesep 'Program Files' filesep 'R' filesep version(end).name filesep 'bin' filesep 'i386'],'dir')
        OPENR.Rexe = ['"C:' filesep 'Program Files' filesep 'R' filesep version(end).name filesep 'bin' filesep 'i386' filesep 'R.exe"'];
    else
        error('OmicsData/Rlink/openR.m: Change your home directory of R here. You can find the directory by R.home() in R.')
    end
elseif exist('/usr/bin/R')==2 % eg knechte
    OPENR.Rexe = '/usr/bin/R'; 
    OPENR.myLibPath = '~/R_library';
elseif exist('R_libs','dir') || exist('R_library','dir') % eg bwcluster
    OPENR.Rexe = 'R'; 
    OPENR.myLibPath = 'R_libs';
elseif exist('../../R_libs','dir') || exist('../../R_library','dir') % eg bwcluster
    OPENR.Rexe = 'R'; 
    OPENR.myLibPath = '../../R_libs';
elseif exist([filesep 'usr' filesep 'local' filesep 'lib' filesep 'R'],'dir')
    if exist([filesep 'usr' filesep 'local' filesep 'lib' filesep 'R' filesep 'bin' filesep 'R.exe'],'dir')
        OPENR.Rexe = ['"' filesep 'usr' filesep 'local' filesep 'lib' filesep 'R' filesep 'bin' filesep 'R.exe"'];
    elseif exist([filesep 'usr' filesep 'local' filesep 'lib' filesep 'R' filesep 'Rscript.exe'],'dir')
        OPENR.Rexe = ['"' filesep 'usr' filesep 'local' filesep 'lib' filesep 'R' filesep 'Rscript.exe"']; 
=======
%% Set R path
if exist('path','var') && exist(path,'dir') 
    path = [path filesep 'R.exe'];
end
if ~exist('path','var') || ~exist(path,'file')
    % Standard Windows path
    if exist(['C:' filesep 'Program Files' filesep 'R'],'dir')
        version = dir(['C:' filesep 'Program Files' filesep 'R' filesep]);
        if exist(['C:' filesep 'Program Files' filesep 'R' filesep version(end).name filesep 'bin' filesep 'x64'],'dir')
            OPENR.Rexe = ['"C:' filesep 'Program Files' filesep 'R' filesep version(end).name filesep 'bin' filesep 'x64' filesep 'R.exe"'];
        elseif exist(['C:' filesep 'Program Files' filesep 'R' filesep version(end).name filesep 'bin' filesep 'i386'],'dir')
            OPENR.Rexe = ['"C:' filesep 'Program Files' filesep 'R' filesep version(end).name filesep 'bin' filesep 'i386' filesep 'R.exe"'];
        else
            error('OmicsData/Rlink/openR.m: Change your home directory of R here. You can find the directory by R.home() in R.')
        end
    % Standard linux path
    elseif exist([filesep 'usr' filesep 'local' filesep 'lib' filesep 'R'],'dir')
        if exist([filesep 'usr' filesep 'local' filesep 'lib' filesep 'R' filesep 'bin' filesep 'R.exe'],'dir')
            OPENR.Rexe = ['"' filesep 'usr' filesep 'local' filesep 'lib' filesep 'R' filesep 'bin' filesep 'R.exe"'];
        elseif exist([filesep 'usr' filesep 'local' filesep 'lib' filesep 'R' filesep 'Rscript.exe'],'dir')
            OPENR.Rexe = ['"' filesep 'usr' filesep 'local' filesep 'lib' filesep 'R' filesep 'Rscript.exe"']; 
        else
            error('OmicsData/Rlink/openR.m: Change your home directory of R here. You can find the directory by R.home() in R.')
        end
        if ~exist(libpath,'var') || ~exist(libpath,'dir')
            OPENR.myLibPath = '~/R_library';
        end
    % Knechte
    elseif exist('/usr/bin/R','file')
        OPENR.Rexe = '/usr/bin/R'; 
        if ~exist(libpath,'var') || ~exist(libpath,'dir')
            OPENR.myLibPath = '~/R_library';
        end
    % BWcluster
    elseif exist('R_lib','file') || exist('R_library','file')
        OPENR.Rexe = 'R'; 
        OPENR.myLibPath = 'R_lib';
>>>>>>> d8671062bf0008d5dc457cee80560c43597f1bec
    else
        error('OmicsData/Rlink/openR.m: Define your home directory of R in openR(path). You can find the directory by R.home() in R.')
    end
else
    OPENR.Rexe = path;
end
if ~strcmp(OPENR.Rexe(1),'"')
    OPENR.Rexe = ['"' OPENR.Rexe '"']; % to be excecutable via command line
end

%% Set library path
if exist('libpath','var') && exist(libpath,'dir')
    OPENR.myLibPath = libpath;
end

%% Set default R packages
OPENR.libraries = {'R.matlab'}; % ,'amap'

%% create empty workspaces
save putRdata
save putRdata_cellstr

warning('off','MATLAB:DELETE:FileNotFound');
delete('getRdata.mat')
warning('on','MATLAB:DELETE:FileNotFound');

