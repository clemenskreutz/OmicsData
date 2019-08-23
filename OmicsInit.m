%   Initializes the OmicsData toolbox, e.g. adding path etc.
% 
% 
% Example for calling the function:
%   >> addpath('PATH_TO_THE_OMICSDATA_FOLDER')
%   >> OmicsData


function OmicsInit

%% Folders to be added: (If new folders are added to the project, specify them here:
subfolders = {'Advanced','Data','Development','MatlabTools','Pipelines','Plot','Rlink','Rfunctions','Subfunctions','Tools','user'};


%% Adding subfolders to Matlab's search path:
w = which('OmicsInit');
Path = w(1:end-length('OmicsInit.m')-1  );

for i=1:length(subfolders)
    path_i = [Path,filesep,subfolders{i}];
    if ~exist(path_i,'dir')
        mkdir(Path,subfolders{i});
%         error('Folder % is not found as a subfolder below %s.',path_i,Path);
    end
    
    addpath(genpath(path_i));

end







