% res = WritePipelineResult(res,[file],[default])
% 
%   This function writes the result file containing %NA, mean, fold,
%   log2fold, min(log2fold), max(log2fold), p-values, min(p), max(p), fdr
%   for all xnames specified res.opts.out
% 
% res.data = OmicsRegress(res.data,res.opts.ana);
% res = Ana2Out(res);
% res = WritePipelineResult(res);

function res = WritePipelineResult(res,file,default)
if ~exist('file','var')  || isempty(file)
    file = 'WritePipelineResult';
end
if ~exist('default','var')  || isempty(default)
    default = 1;
end
if isnumeric(default)
    d = default;
else
    error('char specifying the default analysis are not yet implemented.')
end

nmax = length(res.out.IDs);

out = [];
colnames = cell(0);

out(1:nmax, end+1) = NaN;
out(:, end) = Runde(get(res.O,'antna'),2);
colnames{end+1} = ['Frac NaN in data'];

out(:, end+1) = nanmean(res.O,2);
colnames{end+1} = ['mean data'];

xnames = setdiff(fieldnames(res.out.pr),'label');

for ix=1:length(xnames)
    out(:, end+1) = log2fold( res.out.fold.(xnames{ix})(:,d));
    colnames{end+1} = ['fold ',xnames{ix}];
    
    out(:, end+1) = res.out.fold.(xnames{ix})(:,d);
    colnames{end+1} = ['log2-fold ',xnames{ix}];
    
    out(:, end+1) = nanmin(res.out.fold.(xnames{ix}),[],2);
    colnames{end+1} = ['min(log2fold) ',xnames{ix}];
    
    out(:, end+1) = nanmax(res.out.fold.(xnames{ix}),[],2);
    colnames{end+1} = ['max(log2fold) ',xnames{ix}];
    
    out(:, end+1) = res.out.pr.(xnames{ix})(:,d);
    colnames{end+1} = ['p ',xnames{ix}];
    
    out(:, end+1) = nanmin(res.out.pr.(xnames{ix}),[],2);
    colnames{end+1} = ['min(p) ',xnames{ix}];
    
    out(:, end+1) = nanmax(res.out.pr.(xnames{ix}),[],2);
    colnames{end+1} = ['max(p) ',xnames{ix}];
    
    out(:, end+1) = res.out.fdrr.(xnames{ix})(:,d);
    colnames{end+1} = ['FDR ',xnames{ix}];
end
%% Manuelles steuern der sorierung auf/absteigend:( -1=absteigend, 1=aufsteigend)
% whichOuts   = {'log2-fold 3m','log2-fold KO_2w','log2-fold KO_3m','min(p) KO_3m'};
% vorz        = [-1            , -1              , -1              , 1];
% vorz        = [-1            , 1];
vorz = ones(size(colnames));
ind_fold = contains(colnames,'fold');
vorz(ind_fold) = -1;

forsort = NaN(size(out,1),length(colnames)-2);
for i=3:length(colnames) % 1st two columns are not used for sorting
    tmp = out(:,i);
    if sum(tmp<0)>0
        tmp = abs(tmp);
    end
    
    if vorz(i)<0
        tmp = -tmp;
    end
    
    forsort(:,i-2) = rankasgn_fast(tmp);    
end

WriteWithColnames(res.O,[file,'.xls'],out,colnames,nanmean(forsort,2),[],',');

[~,res.out.rf] = sort(nanmean(forsort,2));



