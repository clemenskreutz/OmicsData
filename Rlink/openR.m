%   This function is for initialization purpose.
%   The global variable "global OPENR" is iniitalized and empty workspaces
%   are created.
% 
%   The path to the R executable has to be set by hand.
% 
% Example
%   openR
%   global openR
%   openR.Rexe = '/user/bin/R/R.exe'

function openR
global OPENR
OPENR = struct;
OPENR.Rexe = '"c:\Program Files\R\R-3.3.1\bin\i386\R.exe"'; % evaluate R command R.home() to find this file
OPENR.libraries = {'R.matlab','amap'};

%% create empty workspaces
save putRdata
save putRdata_cellstr

warning('off','MATLAB:DELETE:FileNotFound');
delete('getRdata.mat')
warning('on','MATLAB:DELETE:FileNotFound');

