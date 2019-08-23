% res = Ana2Out(res)
% 
% This function collects results in res.data.ana as specified in
% res.opts.out
% This step is required in order to reformat the outcomes for calculation
% of min, max etc of the results (e.g. of p-values).
% 
% 
% Example:
% res = Ana2Out(res)
% res.opts.out
% 
% ans = 
% 
%   struct with fields:
% 
%         p: {}
%        pr: {'LR'  'HR'}
%      fold: {}
%     foldr: {'LR'  'HR'}
%       fdr: {}
%      fdrr: {'LR'  'HR'}
% 
% res.out
% 
% ans = 
% 
%   struct with fields:
% 
%       IDs: {1992×1 cell}
%        pr: [1×1 struct]
%     foldr: [1×1 struct]
%      fdrr: [1×1 struct]
% 
% res.out.pr
% 
% ans = 
% 
%   struct with fields:
% 
%     label: {1×12 cell}
%        LR: [1992×12 double]
%        HR: [1992×12 double]

function res = Ana2Out(res)


res.out = struct;
res.out.IDs = get(res.O,'IDs');


fn = fieldnames(res.opts.out);
for f=1:length(fn)
    xnames = res.opts.out.(fn{f});
    if ~isempty(xnames)
        res.out.(fn{f}) = struct;
    end
    for ix=1:length(xnames)
        res.out.(fn{f}).label = cell(0);
        res.out.(fn{f}).(xnames{ix}) = NaN(length(res.out.IDs),0);
        for d=1:length(res.data)
            [~,ia,ib] = intersect(res.out.IDs,get(res.data{d}.O,'IDs'),'stable');
            for a=1:length(res.data{d}.ana.(fn{f}))
                ind = strmatch(xnames{ix},res.data{d}.ana.xnames{a},'exact');
                if ~isempty(ind)
                    res.out.(fn{f}).label{end+1} = res.data{d}.ana.label{a};
                    res.out.(fn{f}).(xnames{ix})(:,end+1) = NaN;
                    res.out.(fn{f}).(xnames{ix})(ia,end) = res.data{d}.ana.(fn{f}){a}(ib,ind);
                end
            end
        end
    end
end

    