% OmicsBoxplotMeanMissings(O,nbin)
% 
%   This function produces a boxplot of the median intensities 
%   for the features depending on proportion of missing values.
% 
%   It is the inverse depection which is produced by OmicsBoxplotMissings
% 
%   nbin    the number of boxes, i.e. the number of bins for the medians
% 
% See also OmicsBoxplotMissings

function OmicsBoxplotMeanMissings(O,nbin)
if ~exist('nbin','var') || isempty(nbin)
    nbin = 20;
end

m = nanmedian(O,2);
antna = sum(isnan(O),2)./get(O,'ns');

[antna2,rf] = sort(antna);
m2 = m(rf); % sorted according to antna

anzProBin = ceil(length(m)/nbin);
m2matrix = NaN(anzProBin,nbin);

binnames = cell(1,nbin);
for i=1:nbin
    ind = (i-1)*anzProBin + (1:anzProBin);
    ind(ind>length(m)) = []; 

    binnames{i} = sprintf('%.2f',nanmean(antna2(ind)));
    m2matrix(1:length(ind),i) = m2(ind);
end

boxplot(m2matrix,'labels',binnames,'labelorientation','inline');
set(gca,'YGrid','on','LineWidth',1.5,'FontSize',9);
xlabel('isnan');
ylabel('median')
title(strrep(get(O,'name'),'_','\_'));

