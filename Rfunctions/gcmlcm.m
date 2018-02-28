% gg = gcmlcm(x,y)
% 
%   gcmlcm computes the greatest convex minorant (GCM) or the least concave
%   majorant (LCM) of a piece-wise linear function. 
%   The GCM is obtained by isotonic regression of the raw slopes, whereas
%   the LCM is obtained by antitonic regression. See Robertson et al.
%   (1988). 
% 
%   Robertson, T., F. T. Wright, and R. L. Dykstra. 1988. Order restricted
%   statistical inference. John Wiley and Sons. 
% 
% Example:
% x = 1:100;
% y = rand(1,100);
% plot(x,y,'.')
% gg = gcmlcm(x,y);
% plot(gg.x,gg.y,'k');



function gg = gcmlcm(x,y)

openR;
global OPENR
OPENR.libraries{end+1} = 'fdrtool';

putRdata('x',x);
putRdata('y',y);
evalR('gg = gcmlcm(x,y)');
gg.x = rterm('gg$x.knots');
gg.y = rterm('gg$y.knots');

closeR


