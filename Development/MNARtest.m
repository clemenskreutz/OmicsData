
% Calls gsri2

function MNAR = MNARtest(O)

    m = nanmean(O,2);
    [~,idx] = sort(m);
    R = (1:length(m))';
    R(idx) = R;
    R = R-min(R);
    R = R./max(R);
    Rmatrix = R*ones(1,size(O,2));
    Rnan = Rmatrix(isnan(O));
    if length(Rnan)<10
        MNAR = nan;
    else
        MNAR = gsri(Rnan,[],false)*100;
    end
end