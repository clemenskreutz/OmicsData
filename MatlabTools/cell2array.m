% a = cell2array(c)
% 
%     KOnvertiert eine Zelle in einen Array gleicher Dimension.
function a = cell2array(c)
a = NaN*ones(size(c));
c = {c{:}};
cl = cellfun('length',c);

if(sum(cl==1)==length(cl))
    for i=1:length(c)
        try
            a(i) = c{i};
        catch
            c{i}
            length(c{i})
            class(c{i})
        end
    end
elseif(sum((cl==1) | cl==0)==length(cl))
    for i=1:length(c)
        if(~isempty(c{i}))
            a(i) = c{i};
        else
            a(i) = NaN;
        end
    end
else
    a = NaN*ones(1,sum(cl));
    ind = 0;
    for i=1:length(c)
        a(ind+(1:cl(i))) = c{i};
        ind = ind+cl(i);
    end
end

