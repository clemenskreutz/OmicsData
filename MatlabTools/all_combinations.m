%   out = all_combinations(s,interactions)
% 
% This function is useful if many simulations should be performed with all
% simulation-parameter combinations.
% 
%   s       a struct containing the parameters to be evaluated (only once)
% 
%   interactions Default: 1 (all combinations, including interactions)
%           0: the first value of each field s.(field) is interpreted as
%           the default value and no interaction-combinations are
%           evaluated.
% 
%   out     the corresponding struct containing the values of the
%           parameters multiply.
% 
% 
% Example: 
% s.threshold = [1,0.2];
% s.normArgs = {{'Percentile',[0,90]},{''},'Quantile'}
% all_combinations(s,0)
% all_combinations(s,1)


function out = all_combinations(s,interactions)
if(~exist('interactions','var') | isempty(interactions))
   interactions = 1;
end

fn = fieldnames(s);
lev = cell(size(fn));
nlev = NaN*ones(size(fn));
for i=1:length(fn)
%     try
    [lev{i}] = levels(s.(fn{i}));
%     catch
%     [lev{i}] = levels(s.(fn{i}));
%     end
    nlev(i) = length(lev{i});    
end

if(interactions==1)
    ncond = prod(cellfun('length',lev));
else
    ncond = sum(cellfun('length',lev));
end    
disp(['all_combinations ',num2str(ncond),' different parameter combinations.' ])


%%
if(interactions==1)
    for i=1:length(nlev)
        args{i} = 1:nlev(i);
    end
    combis = combvec(args{:});
    
    % initialization, 1st value
    for i=1:length(fn)
        if iscell(s.(fn{i}));
            out.(fn{i}) = cell(0);
        else
            out.(fn{i}) = [];
        end
    end
    
    % filling
    for i=1:size(combis,1)
        for j = 1:size(combis,2)
            out.(fn{i}) = [out.(fn{i}),s.(fn{i})(combis(i,j))];
        end
    end
%% old implementation
%     for i=1:length(fn)
%         out.(fn{i}) = s.(fn{i})(1);
%     end
%     % filling
%     for i1=1:length(fn) % prop, die variiert wird´
%         nold = length(out.(fn{i1}));
%         for j=2:nlev(i1)
%             if isnumeric(s.(fn{i1}))
%                 out.(fn{i1}) = [out.(fn{i1}),s.(fn{i1})(j)*ones(1,nold)];
%             else
%                 for k=1:nold
%                     out.(fn{i1}) = [out.(fn{i1}),s.(fn{i1})(j)];
%                 end
%             end
%             
%             for i2 = 1:length(fn)  % prop die gefuellt wird
%                 if(i2~=i1)
%                     out.(fn{i2}) = [out.(fn{i2}),out.(fn{i2})];
%                 end
%             end
%         end
%     end
else % each field is varied individually without interaction-like combinations
%%
    for i=1:length(fn)
        out.(fn{i}) = s.(fn{i})(1);
    end

    sdefault = struct;
    for i=1:length(fn) % prop, die variiert wird
        sdefault.(fn{i}) = s.(fn{i})(1);
    end

    out = sdefault;
    for i=1:length(fn) % prop, die variiert wird
        for j=2:nlev(i)            
            for i2 = 1:length(fn)  % prop die gefuellt wird
                if(i2==i)
                    out.(fn{i2}) = [out.(fn{i2}),s.(fn{i2})(j)];
                else
                    out.(fn{i2}) = [out.(fn{i2}),s.(fn{i2})(1)];
                end
            end
        end
    end
end
