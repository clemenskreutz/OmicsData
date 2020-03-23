
% Calls gsri2

function MNAR = MNARtest(data)

        m = nanmean(data,2);
        [~,idx] = sort(m);
        R = (1:length(m))';
        R(idx) = R;
        R = R-min(R);
        R = R./max(R);
        Rmatrix = R*ones(1,size(data,2));
        Rnan = Rmatrix(isnan(data));

        MNAR = gsri(Rnan,[],false)*100;
end