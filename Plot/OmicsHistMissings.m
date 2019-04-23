% OmicsHistMissings(O)
% 
%   This function plots a histogram of the fraction of missing values over
%   samples 

function OmicsHistMissings(O)
hist(sum(isnan(O))/get(O,'nf'),100);
xlabel('Missing Fraction')
ylabel('# Samples');
title('Frequency of Missing Values');

