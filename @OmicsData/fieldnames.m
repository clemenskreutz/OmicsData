% fn = fieldnames(O)
%   
%   returns the fieldnames at the first level
% 
% fn = fieldnames(O,'all')
% 
%   returns all fieldnames recursively, e.g. 
%    data
%    data.Experiment
%    data.Intensity
%    data.LFQIntensity
%    data.MS_MSCount
%    data.Peptides
%    data.Razor_UniquePeptides
%    data.SequenceCoverage___
%    data.UniquePeptides
%    ID
%    info
%    info.pwd
%    info.time
%    info.date
%       ...

function fn = fieldnames(O,option)

fn = fieldnames(struct(O));

if nargin>1
    if strcmp(option,'all')
        for f=1:length(fn)
            if isstruct(O.(fn{f}))
                fn2 = fieldnames(O.(fn{f}));
                fn = [fn;strcat(fn{f},'.',fn2)];
                for f2=1:length(fn2)
                    if isstruct(O.(fn{f}).(fn2{f2}))
                        fn3 = fieldnames(O.(fn{f}).(fn2{f2}));
                        fn = [fn;strcat(fn{f},'.',fn2{f2},'.',fn3)];
                        
                        if sum(structfun(@isstruct,O.(fn{f}).(fn2{f2})))>0
                            error('Only implemented down to three nested struct. Improve the code by using a while loop.')
                        end
                    end
                end
            end
        end
    else
        error('OmicsData/fieldnames.m: option ''%s'' unknown',option);
    end    
end
