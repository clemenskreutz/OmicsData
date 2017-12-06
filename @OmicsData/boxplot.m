% boxplot(O)
% 
%   boxplot von get(O,'data') über versch. Arrays

function boxplot(O)

dat = get(O,'data');
snames  = str2label(get(O,'snames'));
ns = get(O,'ns');

% Proper font size
if ns<10
    pos = [500   438   560   420]; 
elseif ns<=20
    pos = [500   438   750   420];
elseif ns<=50
    pos = [500   438   850   420];
elseif ns <=70
    pos = [500   438   950   420];
else % more than 60
    pos = [100   438   1600   420];
end


boxplot(dat,'labels',snames,'labelorientation','inline');

set(gca,'YGrid','on','LineWidth',1.5)

xlabel('sample','FontSize',10);
ylabel(str2label(get(O,'default_data')),'FontSize',10);

set(gcf,'Position',pos);


