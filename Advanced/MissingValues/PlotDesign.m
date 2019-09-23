
function PlotDesign(out,isna,path)


y = repmat(sum(isna,2)./size(isna,2),size(isna,2),1);   
nprot = size(isna,1)*size(isna,2);
npred = size(out.X,2)-(size(isna,1)+size(isna,2));
yhat = glmval( out.b(1:size(out.X,2)+1), out.X(1:nprot,:), 'logit');

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
    title(['p = ' num2str(out.stats(end).p(i+1))])
    if strcmp(out.typenames{i+1},'Peptides')
        xlim([0 100])
    end
end

[filepath,name] = fileparts(path);
if ~exist([filepath filesep name],'dir')
    mkdir([filepath filesep name])
end
delete([filepath filesep name filesep name '_Design']);
print([filepath filesep name filesep name '_Design'],'-dpng','-r100');