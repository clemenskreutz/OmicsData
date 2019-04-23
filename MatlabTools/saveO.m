function saveO(O,file,matname)
global O
if ~exist('file','var') || isempty(file)
    file = get(O,'path');
    if ~exist('file','var') || isempty(file)
        file = get(O,'name');
    end
end
if ~exist('matname','var') || isempty(matname)
    matname = 'O';
end


[path,folder,~] = fileparts(file);
if ~exist([path filesep folder],'dir') % Create folder for data
    mkdir(path, folder)
end

set(O,'name',matname);
save([path filesep folder filesep matname '.mat'],'O');                    % Save OmicsData class
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