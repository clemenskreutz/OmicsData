% saves OmicsData object O in a MATLAB® formatted binary file (MAT-file)
%
% O       - @OmicsData object
% file    - filepath to save [path of data file]
% matname - filename         ['O']
%
% Example:
% saveO(O,'C:\Users\Janine\Documents\Test','Otest')

function saveO(O,file,matname)

if ~exist('file','var') || isempty(file)
    file = get(O,'path');
end
if ~exist('matname','var') || isempty(matname)
    matname = 'O';
end
if strcmp(file(end),filesep)
    file = file(1:end-1);
end

[path,folder,~] = fileparts(file);
if ~exist([path filesep folder],'dir') % Create folder for data
     mkdir(path, folder)
end

O = set(O,'name',matname);
if isempty(path)
    save([folder filesep matname '.mat'],'O');
else
    save([path filesep folder filesep matname '.mat'],'O');                    % Save OmicsData class
end
fprintf('%s%s%s%s%s%s%s\n','O saved in ', path, filesep, folder, filesep, matname, '.mat')


% Save open figures
% h =  findobj('type','figure');
% if isempty(h)
%     warning('No figures to save.')
% else
%     if ~exist(['Figures' name],'dir')
%         mkdir(['Figures' name]);
%     end
%     cd(['Figures' name])
%     for f = 1:length(h)
%           fig = figure(f);
%           filename = sprintf('Figure%02d.png', f);
%           print( fig, '-dpng', filename );
%     end
%     fprintf([num2str(length(h)) 'Figures saved in' filename '\n'])
%     cd ..
% end