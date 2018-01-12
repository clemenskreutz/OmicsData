function output(O,file,name)

di = pwd;

if exist('file','var')                      % Go in data folder
    [filepath,foldername,~] = fileparts(file);
    cd(filepath)
    if ~exist(foldername,'dir')
        mkdir(foldername);
    end
    cd(foldername)
end
if ~exist('name','var') || isempty(name)
    name = 'workspace';
end
save([name '.mat'],'O');                    % Save OmicsData class

% Save open figures
h =  findobj('type','figure');
if isempty(h)
    warning('No figures to save.')
else
    if ~exist(['Figures' name],'dir')
        mkdir(['Figures' name]);
    end
    cd(['Figures' name])
    for f = 1:length(h)
          fig = figure(f);
          filename = sprintf('Figure%02d.pdf', f);
          print( fig, '-dpdf', filename );
    end
    cd ..
end

cd(di)