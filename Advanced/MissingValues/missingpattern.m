
function O = missingpattern(O)


%% Get pattern of missing values
out = LogisticNanModel(O);
LogisticNanModelPlot(out);

%% delete missing values
O = deletemissing(O);

%% assign missing values
O = assignmis(O);