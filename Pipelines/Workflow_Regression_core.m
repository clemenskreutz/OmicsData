% res = Workflow_Regression_core(O,res)
% 
%   
function res = Workflow_Regression_core(O,res)

res.O = O;

%% Generate all Os
res.data = cell(0);
for i=1:length(res.opts.data.NaN_FilterThreshold)
    res.data{end+1} = struct;
    label = sprintf('No%i',i);
    Otmp = res.O;
    switch res.opts.data.NaN_FilterThreshold{i}
        case 'none'
            ifeat = 1:size(Otmp,1);
        otherwise
            [Otmp,ifeat] = OmicsRemoveEmptyFeatures(Otmp,res.opts.data.NaN_FilterThreshold{i});
            label = [label,', NaN ',num2str(res.opts.data.NaN_FilterThreshold{i})];
    end
    res.data{end}.ifeat = ifeat;
    
    switch res.opts.data.FilterSamples{i}
        case 'none'
            isamp = 1:size(O,2);
        otherwise           
            error('opts.data.FilterSamples ''%s'' unknown',res.opts.data.FilterSamples{i});
    end
    res.data{end}.isamp = isamp;
    
    switch res.opts.data.Imputation{i}
        case 'none'
        case 'OmicsMice'
            label = [label,', MICE'];
            Otmp = OmicsMice(Otmp);
        case 'OmicsMice2'
            label = [label,', MICE'];
            Otmp = OmicsMice(Otmp,[],2);
        case 'OmicsMice3'
            label = [label,', MICE'];
            Otmp = OmicsMice(Otmp,[],3);
        case 'OmicsMice4'
            label = [label,', MICE'];
            Otmp = OmicsMice(Otmp,[],4);
        case 'OmicsMice5'
            label = [label,', MICE'];
            Otmp = OmicsMice(Otmp,[],5);
        otherwise
            error('Imputation method ''%s'' unknown.',res.opts.data.Imputation{i})
    end    

    switch res.opts.data.NormalizationMethod{i}
        case 'none'
        case 'OmicsMbqn'
            Otmp = OmicsMbqn(Otmp);
            label = [label,', MBQN'];
        otherwise
            error('Normalization unknown');
    end
    
    res.data{end}.O  = set(Otmp,'name',get(Otmp,'name'),label);
    res.data{end}.label  = label;
end
%%
res.data = OmicsRegress(res.data,res.opts.ana);
    
% save(['res_',res.suffix,'_',datestr(now,30)],'res');


%% Write Result Summary:
res = Ana2Out(res);
save res_tmp res
res = WritePipelineResult(res,['WritePipelineResult_',res.opts.ana.Design{1}]);

% if setting ==5
%     res = pas_WriteResult_Aug2018(res,res.suffix,whichOuts,1:3);    
% else
%     res = pas_WriteResult_May2017(res,res.suffix,whichOuts);
% end

% %% Write Single Result-Value for all analyses:
% pas_WriteOneField(res,'fold',1,res.suffix);
% pas_WriteOneField(res,'foldr',1,res.suffix);
% pas_WriteOneField(res,'pr',1,res.suffix);
% 


