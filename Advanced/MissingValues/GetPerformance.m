% O = GetPerformance(O,[ttestrun,ttestcriteria])
%
% Calls O = GetTable(O) to calculate performance measures and writes in O.Table
% Calls O = GetRankTable(O) to sort imputation algorithms and writes in O.RankTable
%
% ttestrun - boolean if ttest should be performed to calculate RMSEttest
% ttestcriteria - boolean if RMSEttest should be performance criteria

function O = GetPerformance(O,ttestrun,ttestcriteria)

if ~exist('ttestrun','var') || isempty(ttestrun)
    ttestrun = true;
end
if ~exist('ttestcriteria','var') || isempty(ttestcriteria)
    ttestcriteria = false;
end
if ttestcriteria
    ttestrun = true; % has to run if is criterion
end

% Create performance tables
O = GetTable(O);
if ttestrun
    O = set(O,'data',get(O,'data_original'),'original'); % cluster by original dataset
    O = RMSEttest(O,2);  
end
O = GetRankTable(O,ttestcriteria);