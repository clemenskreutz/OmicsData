function [xnames,b,bSE,p,X] = Regression(O,exp,plt)   

%% Regression
[X,xnames] = O2X(O,'RSLT',false);
% dat = get(O,'data');
% b = nan(size(X,2),size(X,1));
% bSE = b;
% for i=1:size(O,1)
%     [b(:,i),bint,~,~,stats] = regress(dat(i,:)',X);
%     bSE(:,i) = sqrt(size(dat,2))*(bint(:,2)-bint(:,1))/sqrt(3.92);
%     p(i) = stats(3);
% end
[~,~,~,varests] = regress(O,X);
[p,~,b,~,bSE] = regress_reg(O,X,nanmedian(varests),0.5);
if exist('exp','var') && ~isempty(exp)
    save([exp filesep 'p.mat'], 'p','b','bSE','xnames','X')
end

if exist('plt','var') && ~isempty(plt) && plt
    figure
    hist(ps)
    xlabel('p-values')
    legend(xnames)
    print(gcf,[exp filesep 'Hist'],'-dpng');
end

%         for i=1:length(ps)
%             for j=1:size(ps{i},2)
%                 WriteWithColnames(OmicsFilterColsSTY(Onew),[exp filesep pattern '.txt'],get(Onew,'data'),get(Onew,'SampleNames'),ps)
%             end
%         end