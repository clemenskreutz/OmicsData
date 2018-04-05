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
fprintf(['O saved in' name '.mat\n'])

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
          filename = sprintf('Figure%02d.png', f);
          print( fig, '-dpng', filename );
    end
    fprintf([num2str(length(h)) 'Figures saved in' filename '\n'])
    cd ..
end

cd(di)