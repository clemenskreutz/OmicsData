function O = imputation_clear(O,move)

if ~exist('O','var')
    error('MissingValues/imputation_clear.m requires class O as input variable.')
end

if exist('move','var')
    if move && ~isempty(get(O,'method_imput'))
        O = set(O,'data_imput_sim',get(O,'data_imput'));
        O = set(O,'method_imput_sim',get(O,'method_imput'));
        O = set(O,'time_imput_sim',get(O,'time_imput'));
    end
end

O = set(O,'data_imput',[]);
O = set(O,'method_imput',{});
O = set(O,'time_imput',{});