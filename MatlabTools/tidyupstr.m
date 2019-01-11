
function T = tidyupstr(T)

if istable(T)
    ar = T.Properties.VariableNames;
else
    ar = T;
end

for i=1:length(ar)
    idx = strfind(ar{i},'_');
    if isempty(idx)
        idx=0;
    end
    ar{i} = ar{i}(idx+1:end);
    [~,uniidx] = unique(ar);
    if length(uniidx)<length(ar)
        ar{i} = [ar{i} '2'];
    end
end

if istable(T)
    T.Properties.VariableNames = ar;
else
    T = ar;
end
