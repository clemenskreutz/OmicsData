% OmicsBoxplotMissings(O,nbin)
% 
%   This function produces a boxplot of the proportion of missing values
%   for the features depending on the median measurment
% 
%   It is the inverse depection which is produced by OmicsBoxplotMeanMissings
% 
%   nbin    the number of boxes, i.e. the number of bins for the medians
% 
% See also OmicsBoxplotMeanMissings

function OmicsBoxplotMissings(O,nbin)
if ~exist('nbin','var') || isempty(nbin)
    nbin = 20;
end

m = nanmedian(O,2);
antna = sum(isnan(O),2)./get(O,'ns');

[m2,rf] = sort(m);
antna2 = antna(rf); % sorted according to m
anzProBin = ceil(length(m)/nbin);
antna2matrix = NaN(anzProBin,nbin);

binnames = cell(1,nbin);
for i=1:nbin
    ind = (i-1)*anzProBin + (1:anzProBin);
    ind(ind>length(m)) = []; 

    binnames{i} = sprintf('%.2f',nanmean(m2(ind)));
    antna2matrix(1:length(ind),i) = antna2(ind);
end

boxplot(antna2matrix,'labels',binnames,'labelorientation','inline');
set(gca,'YGrid','on','LineWidth',1.5,'FontSize',9);
xlabel('median')
ylabel('isnan');
title(strrep(get(O,'name'),'_','\_'));

