% O = OmicsAdjust(O,X,coef,[doplot])
% 
%   O       @OmicsData
% 
%   X       Design matrix 
%           nsamples x ncoef
% 
%   coef    The coefficient estimated with the design matrix, 
%           nfeatures x ncoef
% 
%   doplot  [false]
% 
%   This function adjusts data according to the outcome of a linear model.
%   The predicted numbers are subtracted, the adjusted data coincides with
%   residuals.
%   
%   A typical example is estimating batch effects as nuisance parameters
%   and then using these feature-specific estimates to adjust the data.
% 
% Example:


function O = OmicsAdjust(O,X,coef,doplot)
if ~exist('doplot','var') || isempty(doplot)
    doplot = false;
end

pred = NaN(size(coef,1),size(X,1));
for i=1:size(coef,1)
    pred(i,:) = X*coef(i,:)';
end

dat = get(O,'data');
res = dat-pred;
O = set(O,'data',res,sprintf('Adjusted, size(X)=(%i,%i)',size(X,1),size(X,2)));

if doplot
    plot(dat,res,'.');
    xlabel('before adjusting')
    ylabel('after adjusting');
end
