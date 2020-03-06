
function MNAR = MNARtest(data)

    mv = sum(sum(isnan(data)))/size(data,1)/size(data,2);

    %% MeanMis
    n_mis_row_rel = sum(isnan(data),2)/size(data,2);
    meandat = round(nanmean(data,2),1);

    mi = nanmin(meandat);
    ma = nanmax(meandat);
    mstep = mi:0.1:ma;

    c=1;
    meanmis = nan(round((ma-mi)*10+1),length(n_mis_row_rel));
    for k=mstep
        d = n_mis_row_rel(meandat==k);
        meanmis(c,1:length(d)) = d;
        c=c+1;
    end
     mis = nanmean(meanmis.')';
     mis(isnan(mis)) = [];
     m = (1:length(mis))'/length(mis);
     
     % y of linear mv quantile
     f = fit(m(m<mv),mis(m<mv),'poly1');
     % minus mv null
     MNAR = f.p2-nanmean(mis(m>mv));

end