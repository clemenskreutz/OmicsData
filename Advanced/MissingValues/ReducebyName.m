
function [X,dat] = ReducebyName(O,j)

dat = get(O,'data');
Names = get(O,'SampleNames');
Short = {'A','B','C','D','E'};

rem = []; rem2=[];
for i=1:length(Names)
    if strncmp(Names{i},[Short{j} '_Day'],4) || strncmp(Names{i},[Short{j} '_Log'],4)
        rem = [rem i];
    elseif strncmp(Names{i},[Short{j} '_Light'],6)
        rem2 = [rem2 i];
    end
end
remges = [rem rem2];
dat = dat(remges,:);
X = [ ones(length(rem),1); zeros(length(rem2),1) ];
X(:,2) = flipud(X);
