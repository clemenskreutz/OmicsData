% ok = OmicsTests(beaktime)
%
% This function implements some basic tests and calls to check and
% illustrate the package.
% 
%   breaktime   pause between each command, provides some time for the user
%               to look at the results
%               Default: breaktime=1
%               The fastest possibility is breaktime=0.

function ok = OmicsTests(beaktime)
if ~exist('beaktime','var') || isempty(beaktime)
    beaktime = 0;
end

OmicsInit

close all
pfad = fileparts(which('OmicsInit'));

cmds = {...
    'O = OmicsData(randn(1000,10))',...
    'get(O)',...
    'fieldnames(O)',...
    'fieldnames(O,''all'')',...
    'hist(nanmean(O,2),100); drawnow',...
    'hist(nanmedian(O,2),100); drawnow',...
    'hist(nanstd(O,[],2),100); drawnow',...
    'hist(get(O,''nna''),100); drawnow',...
    'hist(get(O,''propna''),100); drawnow',...
    '[O,O,O]',...
    '[O;O;O]',...
    'image([O;O])',...    
    };


%% Try reading different real data sets: (if available)
dataPfad = [pfad,filesep,'TestData'];
if ~exist(dataPfad,'dir')
    error('Folder TestData not found.');
else
    delete(sprintf('%s%s*.mat',dataPfad,filesep));    
end

d = dir(dataPfad);
files = {d.name};
files = files(strmatch('Test',files));

for i=1:length(files)
    cmd_tmp = sprintf('O = OmicsData(''%s'','''',1);',[dataPfad,filesep,files{i}]);
    disp(cmd_tmp);
    cmds = [cmds, {cmd_tmp}];
end


%% Additional commands with real data (if available)
cmds = [cmds, {
    'O2 = log2(O);',...
    'O3 = quantilenorm(O2)',...
    'boxplot(O3);drawnow',...
}];




ok = 1;
for i=1:length(cmds)
    fprintf('>> %s\n',cmds{i});
    try
        eval(cmds{i})    
    catch
        warning('Command ''%s'' failed.',cmds{i});
        % for solving errors, set a breakpoint here.
        ok = 0;
    end
    if beaktime>0
        pause(beaktime)
    end
end



