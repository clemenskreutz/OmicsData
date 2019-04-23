%   This function is for initialization purpose.
%   The global variable "global OPENR" is iniitalized and empty workspaces
%   are created.
% 
%   The path to the R executable has to be set by hand.
% 
% Example
%   openR
%   global OPENR
%   OPENR.Rexe = '\user\bin\R\R.exe'

function openR
global OPENR
OPENR = struct;
if exist('C:\Program Files\R\R-3.5.3\bin\x64\R.exe','file')
    OPENR.Rexe = '"C:\Program Files\R\R-3.5.3\bin\x64\R.exe"'; % evaluate R command R.home() to find this file
elseif exist('C:\Program Files\R\R-3.5.1\bin\x64\R.exe','file')
    OPENR.Rexe = '"C:\Program Files\R\R-3.5.1\bin\x64\R.exe"'; % evaluate R command R.home() to find this file
elseif exist('C:\Program Files\R\R-3.5.1\bin\i386\R.exe','file')
    OPENR.Rexe = '"C:\Program Files\R\R-3.5.1\bin\i386\R.exe"'; % evaluate R command R.home() to find this file
elseif exist('C:\Program Files\R\R-3.4.3\bin\x64\R.exe','file')
    OPENR.Rexe = '"C:\Program Files\R\R-3.4.3\bin\x64\R.exe"'; % evaluate R command R.home() to find this file
elseif exist('c:\Program Files\R\R-3.3.1\bin\i386\R.exe','file')
    OPENR.Rexe = '"C:\Program Files\R\R-3.3.1\bin\i386\R.exe"'; 
elseif exist('/usr/local/lib/R/bin','dir')
    OPENR.Rexe = '"/usr/local/lib/R/bin/R.exe"'; %"/usr/local/lib/R/Rscript.exe
else
    error('OmicsData\Rlink\openR.m: Change your home directory of R here. You can find the directory by R.home() in R.')
end
OPENR.libraries = {'R.matlab','amap'};

%% create empty workspaces
save putRdata
save putRdata_cellstr

warning('off','MATLAB:DELETE:FileNotFound');
delete('getRdata.mat')
warning('on','MATLAB:DELETE:FileNotFound');

