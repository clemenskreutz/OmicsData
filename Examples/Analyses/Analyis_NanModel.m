%% Reading data (has be adapted on other computers
OmicsInit
O = OmicsData('E:\clemens\Repositories\OmicsData\Data\dynamicrangebenchmark\proteinGroups_ck.xlsx');

O = log2(O);
%% Calculationg the Nan model
out = LogisticNanModel(O);

%% plotting the results
close all

for t=1:length(out.type_names)
    figure
    plotdat = out.b;
    plotdat(out.type~=t) = NaN;
    plotdat = plotdat(sum(~isnan(plotdat),2)>0,:);
    if size(plotdat,2)>1
        boxplot(plotdat')
    else
        [~,rf] = sort(median(plotdat,2));
        for i=1:2
            subplot(2,1,i)
            if i==2
                plotdat = plotdat(rf,:);
            end
            if length(plotdat)<=50
                errorbar(1:length(plotdat),plotdat,out.stats.se(out.type==t),'o')
            else
                plot(1:length(plotdat),plotdat,'o-')
            end
            if i==1
                title([out.type_names{t},', unsorted']);
            else
                title('sorted')
            end
        end
    end
    set(gcf,'Position',[570  180  560  700]);
end

