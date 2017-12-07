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
dataPfad = [pfad,filesep,'Data',filesep,'dynamicrangebenchmark'];
if exist(dataPfad,'dir')
    cmds = [cmds, {'O = OmicsData([pfad,filesep,''Data'',filesep,''dynamicrangebenchmark'',filesep,''proteinGroups.txt'']);'}];
else
    fprintf('%s does not exist, skip this test.\n',dataPfad);
end

dataPfad = [pfad,filesep,'Data',filesep,'proteomebenchmark'];
if exist(dataPfad,'dir')
    cmds = [cmds, {'O = OmicsData([pfad,filesep,''Data'',filesep,''proteomebenchmark'',filesep,''proteinGroups.txt'']);'}];
else
    fprintf('%s does not exist, skip this test.\n',dataPfad);
end

dataPfad = [pfad,filesep,'Data',filesep,'PXD003813',filesep,'MaxQuant_Output1'];
if exist(dataPfad,'dir')
    cmds = [cmds, {'O = OmicsData([pfad,filesep,''Data'',filesep,''PXD003813'',filesep,''MaxQuant_Output1'',filesep,''proteinGroups_1.txt'']);'}];
else
    fprintf('%s does not exist, skip this test.\n',dataPfad);
end

dataPfad = [pfad,filesep,'Data',filesep,'PXD003813',filesep,'MaxQuant_Output1'];
if exist(dataPfad,'dir')
    cmds = [cmds, {'O = OmicsData([pfad,filesep,''Data'',filesep,''PXD003813'',filesep,''MaxQuant_Output1'',filesep,''proteinGroups_1.xls'']);'}];
else
    fprintf('%s does not exist, skip this test.\n',dataPfad);
end

dataPfad = [pfad,filesep,'Data',filesep,'PXD004816',filesep,'MaxQuant_Output'];
if exist(dataPfad,'dir')
    cmds = [cmds, {'O = OmicsData([pfad,filesep,''Data'',filesep,''PXD004816'',filesep,''MaxQuant_Output'',filesep,''proteinGroups.txt'']);'}];
else
    fprintf('%s does not exist, skip this test.\n',dataPfad);
end

dataPfad = [pfad,filesep,'Data',filesep,'PXD000485',filesep,'MaxQuantOutputValidationDataset'];
if exist(dataPfad,'dir')
    cmds = [cmds, {'O = OmicsData([pfad,filesep,''Data'',filesep,''PXD000485'',filesep,''MaxQuantOutputValidationDataset'',filesep,''proteinGroups.txt'']);'}];
else
    fprintf('%s does not exist, skip this test.\n',dataPfad);
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



