% boxplot(O)
% 
%   boxplot von get(O,'data') über versch. Arrays
% 
% The code can be extended by providing faktor as a variable.
% This faktor controls the postion in vertical direction of the labels.

function boxplot(O)

dat = get(O,'data');
snames  = str2label(get(O,'snames'));
ns = get(O,'ns');

faktor = 1;
% Proper font size
if ns<10
    fs = 10;
    pos = [500   438   560   420]; 
elseif ns<=20
    fs = 9;
    pos = [500   438   750   420];
elseif ns<=50
    fs = 8;
    faktor = 0.9;
    pos = [500   438   850   420];
elseif ns <=70
    faktor = 0.8;
    fs = 7;
    pos = [500   438   950   420];
else % more than 60
    faktor = 0.7;
    fs = 6;
    pos = [100   438   1600   420];
end
boxplot(dat,'labels',snames,'labelorientation','inline');
set(gca,'YGrid','on','LineWidth',1.5,'FontSize',9);
hlabel = findobj(gca,'FontSize',10);
yl = ylim;
for i=1:length(hlabel)
    set(hlabel(i),'FontSize',fs);
    pos = get(hlabel(i),'Position');
%     ex = get(hlabel(i),'extend');
    pos(2) = yl(1)-faktor*(yl(1)-pos(2));
    set(hlabel(i),'Position',pos);
end

xlabel('sample','FontSize',10);
ylabel(str2label(get(O,'default_data')),'FontSize',10);
title(get(O,'name'))
% set(gcf,'Position',pos);


