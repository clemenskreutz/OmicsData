
function X = GetDesignMatrix(O)


Names = get(O,'SampleNames');
Short = {'A','B','C','D','E'};
X = zeros(length(Names),2,length(Short));

for j = 1:length(Short)
    rem = []; rem2=[];
    for i=1:length(Names)
        if strncmp(Names{i},[Short{j} '_Day'],4) || strncmp(Names{i},[Short{j} '_Log'],4)
            rem = [rem i];
        elseif strncmp(Names{i},[Short{j} '_Light'],6)
            rem2 = [rem2 i];
        end
    end
    X(rem,1,j) = 1;
    X(rem2,2,j) = 1;
end
