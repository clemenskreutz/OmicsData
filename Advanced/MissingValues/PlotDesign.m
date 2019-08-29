
function PlotDesign(out,isna)


y = repmat(sum(isna,2)./size(isna,2),size(isna,2),1);   
nprot = size(isna,1)*size(isna,2);
npred = size(out.X,2)-(size(isna,1)+size(isna,2));
yhat = glmval( out.b, out.X(1:nprot,:), 'logit');

y = y(1:size(isna,1));
yhat = yhat(1:size(isna,1));
nprot = size(isna,1);
figure
for i=1:npred
    subplot(2,npred,i)
    plot(out.X(1:nprot,i),y,'b.') 
    title(out.typenames{i+1})
    if strcmp(out.typenames{i+1},'Peptides')
        xlim([0 100])
    end
    subplot(2,npred,i+npred)
    plot(out.X(1:nprot,i),yhat,'r.')
    title(['p = ' num2str(out.stats.p(i+1))])
    if strcmp(out.typenames{i+1},'Peptides')
        xlim([0 100])
    end
end