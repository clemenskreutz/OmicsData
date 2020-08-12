function [xnames,b,bSE,X] = FilterRegression(O,xnames,b,bSE,X,pattern)

[~,~,raw]=xlsread('..\Samples_R5.xlsx');

%% Filter Predictors
c=[];
for i=1:length(pattern)
    if any(contains(xnames,pattern{i}))
        c = [c find(contains(xnames,pattern{i}))];
    end
end
%% Filter samples
Names = get(O,'SampleNames');
H_time = [raw{2:end,3}]';
M_time = [raw{2:end,4}]';
L_time = [raw{2:end,5}]';
S = regexp(raw{2:end,2},'[0-9]','match');

for i=1:length(H_time)
    idxhm(i) = [contains(Names,[H_time(i) '/' M_time(i)]), contains(Names,[M_time(i) '/' H_time(i)])];
    idxhl(i) = [contains(Names,[H_time(i) '/' L_time(i)]), contains(Names,[L_time(i) '/' H_time(i)])];
    idxml(i) = [contains(Names,[M_time(i) '/' L_time(i)]), contains(Names,[L_time(i) '/' M_time(i)])];
    predhm(i) = contains(xnames,['Sample' S]) | contains(xnames,['Time' H_time(i)]) | contains(xnames,['Time' M_time(i)]);
end

b = b(:,c);
bSE = bSE(:,c);
X = X(:,c);
xnames = xnames(c);

'end'


% % Shorten Sample repitions
% if any(contains(pattern,'Time'))
%     idxt = contains(pattern,'Time');
%     t = str2double(regexp(pattern{idxt},'[0-9]','match'));
% end
% if any(contains(pattern,'Light'))
%     if exist('t','var') && ~isempty(t)
%         idxl = get(O,'lsign')==-1 & get(O,'ltime')==t;
%     else
%         idxl = get(O,'lsign')==-1;
%     end
% end