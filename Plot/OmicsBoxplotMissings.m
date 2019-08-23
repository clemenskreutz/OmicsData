% OmicsBoxplotMissings(O,[nbin],[option])
% 
%   This function produces a boxplot of the proportion of missing values
%   for the features depending on the median measurment
% 
%   It is the inverse depection which is produced by OmicsBoxplotMeanMissings
% 
%   nbin    the number of boxes, i.e. the number of bins for the medians
% 
%   option  x-values, e.g. 'mean', 'median'
% 
% See also OmicsBoxplotMeanMissings

function OmicsBoxplotMissings(O,nbin,option)
if ~exist('nbin','var') || isempty(nbin)
    nbin = 20;
end
if ~exist('option','var') || isempty(option)
    option = 'median';
end

switch(option)
    case 'median'        
        x = nanmedian(O,2);
    case 'mean'        
        x = nanmean(O,2);
    otherwise
%         error('Option %s unknown.',option);
        x = get(O,option);
end

antna = sum(isnan(O),2)./get(O,'ns');

[m2,rf] = sort(x);
antna2 = antna(rf); % sorted according to x
anzProBin = ceil(length(x)/nbin);
antna2matrix = NaN(anzProBin,nbin);

binnames = cell(1,nbin);
for i=1:nbin
    ind = (i-1)*anzProBin + (1:anzProBin);
    ind(ind>length(x)) = []; 

    binnames{i} = sprintf('%.2f',nanmean(m2(ind)));
    antna2matrix(1:length(ind),i) = antna2(ind);
end

boxplot(antna2matrix,'labels',binnames,'labelorientation','inline');
set(gca,'YGrid','on','LineWidth',1.5,'FontSize',9);
xlabel(option)
ylabel('isnan');
title(strrep(get(O,'name'),'_','\_'));

