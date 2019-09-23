

function O = scaleO(O,str)

dat = get(O,'data');
dat = (dat - nanmean(dat(:))) / nanstd(dat(:));

if exist('str','var') && ~isempty(str)
    dat_scaleto = get(O,['data_' str],true);
    if isempty(dat_scaleto)
        dat_scaleto = get(O,str,true);
    end
    if isempty(dat_scaleto)
        fprintf('Data was normalized to N(0,1).\n')
    else
        dat = dat*nanstd(dat_scaleto(:)) + nanmean(dat_scaleto(:));
        fprintf(['Data was scaled to N( mean(' str '), var(' str ') ).\n'])
    end

else
    fprintf('Data was normalized to N(0,1).\n')
end

O = set(O,'data',dat,'Normalized');