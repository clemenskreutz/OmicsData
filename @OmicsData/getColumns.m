% 
function [colvals,colnames] = getColumns(O,format)

%% all columns from @OmicsData
cols = get(O,'cols');
colnames = fieldnames(cols);
colvals = cell(get(O,'nf'),length(colnames));


switch format
    case 'char'
        for f=1:length(colnames)
            if iscell(cols.(colnames{f}))
                colvals(:,f) = cols.(colnames{f});
            elseif isnumeric(cols.(colnames{f}))
                colvals(:,f) = num2strArray(cols.(colnames{f}));
            end
        end
end


