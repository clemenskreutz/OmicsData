function output(file,matname)

global O

if ~exist('file','var') || isempty(file)
    file = get(O,'path');
end
if ~exist('matname','var') || isempty(matname)
    matname = 'O';
end

[path,folder,~] = fileparts(file);
if ~exist([path '/' folder],'dir') % Create folder for data
    mkdir(path, folder)
end

save([path '/' folder '/' matname '.mat'],'O');                    % Save OmicsData class
fprintf(['O saved in ' path '/' folder '/' matname '.mat\n'])


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