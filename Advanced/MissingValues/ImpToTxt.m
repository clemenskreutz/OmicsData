function ImpToTxt

global O

path = get(O,'path');

%% Get new filename = 'old filename+Imp'
[~,name] = fileparts(path);
if contains(name,'peptides','IgnoreCase',true)
    filename = strrep(name,'eptides','eptideImp');   % ignore first letter = ignore case
elseif contains(name,'protein','IgnoreCase',true)
    if contains(name,'proteinGroups','IgnoreCase',true)
        filename = strrep(name,'roteinGroups','roteinGroupImp');
    else
        filename = strrep(name,'rotein','roteinImp');
    end
else
    filename = [name 'Imp'];
end

%% Read original file and find pattern indices
raw = OmicsReadData(path);
ind = OmicsFindPattern(raw);

%% Replace intensity with imputed intensity
Imp = 10.^(get(O,'data'));
if size(Imp,3)>1
    error('ImpToTxt: Run imputation_original first, to impute original dataset with best algorithm.');
end
for i=1:length(ind)
    raw(2:end,ind(i)) = num2cell(Imp(:,i));
end

%% Write to *Imp.txt
T = cell2table(raw);
writetable(T,filename,'Delimiter',' ','WriteVariableNames',false);

%% Write just intensities to txt
% % header
% fid = fopen([filepath '/' filename], 'wt');
% for i=1:ind(1)
%     fprintf(fid, '%s\t', ['Intensity_' num2str(i)]);  
% end
% for i=ind(1):size(get(O,'data'),2)
%     fprintf(fid, '%s\t', ['Intensity_' num2str(i)]);  
% end
% fprintf(fid,'\n');  
% fclose(fid);
% 
% % data
% dlmwrite(filename,10.^(get(O,'data')),'delimiter','\t','precision',ceil(max(O)),'-append');