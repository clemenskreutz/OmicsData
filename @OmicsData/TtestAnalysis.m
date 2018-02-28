%   result = TtestAnalysis(O,grouping,writeOrFile,varequal,paired)
%
%   t-test including calculation of FDR and fold-change.
%   This function uses the matlab function ttest2.m
%
%   O   @OmicsData
% 
%   grouping    Cell of indices indicating the replicates.
%                   {array1, array2}
%               If a cell of cells is used, several comparisons are made.
%                   {{array1, array2}, {array3, array4}, ...}
%
%   write       Saving the result as a table?
%               Default: write=0 (no)
%               In case of writing, one can also use file name,
%               e.g. write = 'filename'
%
%   varequal    T-test with the assumption of having equal variances
%               Default: 1.
%               As a tendency, this option should be chosen for small
%               number of replicates.
%               Since variances are "difficult" to estimate, unequal
%               variances requires more replicates to obtain a reproducible
%               ranking of features.
%
%   paired      Default: 0.
%
%   result      struct with the following fields:
%               result.p    = p-value of the t-test
% 				result.fdr = False discovery rates calcualted from p-values
% 				result.fold = fold change  (Gruppe 1 - 2 Gruppe2)
% 				result.log  = explanation "which samples were compared?"
% 				result.p_wilcoxon    = p-Wert wilcoxon test
% 				result.pfdr_wilcoxon = fdr for wilcoxon p-values
%
% Example:
% resEqVar   = ttestAnalysis(O,{[1:3],[4:6]});          % equal variances
% resUneqVar = ttestAnalysis(O,{[1:3],[4:6]},[],[],0);  % unequal variances


function result = TtestAnalysis(O,grouping,write,varequal,paired)
if ~iscell(grouping)
    error('TtestAnalysis.m: grouping has to have the following structure: {array1, array2} or {{array1, array2}, {array3, array4}, ...}')
elseif ~iscell(grouping{1})
    uncell = 1;
    grouping = {grouping}; % convert {array1, array2} in {{array1, array2}}
else
    uncell = 0;
end

if(~exist('write','var') || isempty(write))
    write = 1;
end
if(~exist('varequal','var') || isempty(varequal))
    varequal = 1;
    disp('TtestAnalysis: equal variances assumed.')
elseif varequal==1
    disp('TtestAnalysis: equal variances assumed.')
else
    disp('TtestAnalysis: UNequal variances assumed.')
end
if(~exist('paired','var') || isempty(paired))
    disp('UNpaired T-Test ...')
    paired = 0;
elseif(paired==1)
    disp('Paired T-Test ...')
    ng = cellfun(@length,grouping);
    if(length(unique(ng))~=1)
        error('TtestAnalysis.m: For a paired t-test, all groups have to have the same number of samples.')
    end
end

if(varequal==1)
    varstr = '';
else
    varstr = 'unequal';
end

dat = get(O,'data');

samplenames = get(O,'samplenames');
nf          = get(O,'nf');
ns          = get(O,'ns');
name        = get(O,'name');

fold    = cell(size(grouping));
p       = cell(size(grouping));
q       = cell(size(grouping));
fdr     = cell(size(grouping));
fdrBH   = cell(size(grouping));
pwilc   = cell(size(grouping));
pfdrwilc= cell(size(grouping));
T       = cell(size(grouping));
CI      = cell(size(grouping));
updown  = cell(size(grouping));
Log     = cell(size(grouping));
notNaN1 = cell(size(grouping));
notNaN2 = cell(size(grouping));
notNaNrel = cell(size(grouping));

for itest = 1:length(grouping)
    if length(grouping{itest})~=2
        error('')
    elseif isempty(grouping{itest}{1})
        error('grouping{%i}{1} is empty.',itest)
    elseif isempty(grouping{itest}{2})
        error('grouping{%i}{2} is empty.',itest)
    else
        dat1 = dat(:,grouping{itest}{1});
        dat2 = dat(:,grouping{itest}{2});
        
        fold{itest} = nanmean(dat1,2) - nanmean(dat2,2);
        Log{itest} = ['Samples ',sprintf('%i, ',grouping{itest}{1}),' vs. ' sprintf('%i, ',grouping{itest}{2})];

        if strcmp(varstr,'unequal')==1
            nanok = find(sum(~isnan(dat1),2)>=1 & sum(~isnan(dat2),2)>=1 & (sum(~isnan(dat1),2)+sum(~isnan(dat2),2))>=3 ...
                & nanstd(dat1,[],2)>0 & std(dat2,[],2)>0 );
        else
            datExceptOne = sort([dat1,dat2],2);
            nanok = find(sum(~isnan(dat1),2)>=1 & sum(~isnan(dat2),2)>=1 & (sum(~isnan(dat1),2)+sum(~isnan(dat2),2))>=3 ...
                & nanstd(datExceptOne(:,2:end),[],2)>0 );
        end
        try
            p{itest} = NaN*ones(size(dat1,1),1);
            T{itest} = NaN*ones(size(dat1,1),1);
            if(paired==1)
                [~,p{itest}(nanok), ci, stats] = ttest(dat1(nanok,:),dat2(nanok,:),[],[],2);
            else
                [~,p{itest}(nanok), ci, stats] = ttest2(dat1(nanok,:),dat2(nanok,:),[],[],varstr,2);
            end
            T{itest}(nanok) = stats.tstat;
            CI{itest}(nanok,:) = ci;
        catch
            save catch
            error(lasterr)
        end
                
        [fdr{itest},q{itest},fdrBH{itest}] = fdr_calculations(p{itest});
        
        if(size(dat1,2) + size(dat2,2) <=12)
            didWilcox = 0;
            pwilc = cell(0);
            pfdrwilc = cell(0);
        else
            didWilcox = 1;
            try
                pwilc{itest} = NaN*ones(size(dat1,1),1);
                pfdrwilc{itest} = NaN*ones(size(dat1,1),1);
                for i=1:length(nanok)
                    d1 = dat1(nanok(i),:);
                    d2 = dat2(nanok(i),:);
                    [pwilc{itest}(nanok(i),1)] = ranksum(d1(~isnan(d1)),d2(~isnan(d2))); %,'method','exact'
                end
            catch
                pwilc{itest}=NaN*ones(size(dat1,1),1);
                pfdrwilc{itest}=NaN*ones(size(dat1,1),1);
                warning(lasterr)
            end
        end
        
        updown{itest} = 2.^abs(fold{itest}).*sign(fold{itest});
        if((~isempty(write) && write~=0) || ischar(write))
            if(isnumeric(write))
                fid = fopen([Log{itest},'_',date,'.log'],'w');
            else
                fid = fopen([write,Log{itest},'_',date,'.log'],'w');
            end
            fprintf(fid,'%s\n',date);
            fprintf(fid,'%s\n',name);
            fprintf(fid,'%d Features \n',nf);
            fprintf(fid,'%d Samples \n\n',ns);
            for ih = 1:length(grouping{itest}{1})
                fprintf(fid,'%s\n',samplenames{grouping{itest}{1}(ih)});
            end
            fprintf(fid,'\n  vs. \n \n');
            for ih = 1:length(grouping{itest}{1})
                fprintf(fid,'%s \n',samplenames{grouping{itest}{2}(ih)});
            end
            fclose(fid);
            if(isnumeric(write))
                filename = [Log{itest},'_',varstr,date];
            else
                filename = [write,' ',Log{itest},'_',varstr,date];
            end
            try
                notNaN1{itest} = sum(~isnan(dat1),2);
                notNaN2{itest} = sum(~isnan(dat2),2);
                notNaNrel{itest} = (sum(~isnan(dat1),2)+sum(~isnan(dat2),2))/(size(dat1,2)+size(dat2,2));
                if(didWilcox==1)
                    WriteWithColnames(O,[filename,'.xls'],[p{itest},fdr{itest},fold{itest},updown{itest},pwilc{itest},pfdrwilc{itest},notNaNrel{itest},notNaN1{itest},notNaN2{itest}],...
                        {'p','fdr',['log fold ',strrep(Log{itest},'_vs_','-')],['Up-/down fold'],'p Wilcoxon','fdr Wilcoxon','not NaN [relative]','not NaN group1','not NaN in group2'},-fold{itest},[],',');
                    % WriteWithColnames(O,[Log{itest},'_',date,'.xls'],[p{itest},fdr{itest},fold{itest}],{'p','fdr',['fold ',strrep(Log{itest},'_vs_','-')]});
                else
                    WriteWithColnames(O,[filename,'.xls'],[p{itest},fdr{itest},fold{itest},updown{itest},notNaNrel{itest},notNaN1{itest},notNaN2{itest}],...
                        {'p','fdr',['log fold ',strrep(Log{itest},'_vs_','-')],['Up-/down fold'],'not NaN [relative]','not NaN group1','not NaN in group2'},-fold{itest},[],',');
                end
            catch
                save error
                error(lasterr)
            end
            figure
            scatterimage(fold{itest},p{itest},linspace(-1,1,100),linspace(0,1,100));
            set(gca,'FontSize',14);
            xlabel('fold  g1 - g2');
            ylabel('p');
            title(strrep(Log{itest},'_',' '));
            PrintToPng(gcf,filename);
        end
    end  % else (grouping has correct form)
end % loop over all groupings/different tests settings

result.p    = p;
result.q    = q;
result.fdr = fdr;
result.fold = fold;
result.updown = updown;
result.log  = Log;
result.p_wilcoxon    = pwilc;
result.pfdr_wilcoxon = pfdrwilc;
result.t    = T;
result.CI   = CI;
result.notNaNrel = notNaNrel;
result.notNaN1 = notNaN1;
result.notNaN2 = notNaN2;

if uncell
    fn = fieldnames(result);
    for f =1:length(fn)
        if iscell(result.(fn{f})) && ~isempty(result.(fn{f}))
            result.(fn{f}) = result.(fn{f}){1};
        end
    end
end

