%   Initializes the OmicsData toolbox, e.g. adding path etc.
% 
% 
% Example for calling the function:
%   >> addpath('PATH_TO_THE_OMICSDATA_FOLDER')
%   >> OmicsData


function OmicsInit

%% Folders to be added: (If new folders are added to the project, specify them here:
subfolders = {'Advanced','Data','Development','MatlabTools','Subfunctions','Tools'};


%% Adding subfolders to Matlab's search path:
w = which('OmicsInit');
Path = w(1:end-length('OmicsInit.m'));

for i=1:length(subfolders)
    path_i = [Path,filesep,subfolders{i}];
    if ~exist(path_i,'dir')
        error('Folder % is not found as a subfolder below %s.',path_i,Path);
    end
    
    addpath(path_i);

end







