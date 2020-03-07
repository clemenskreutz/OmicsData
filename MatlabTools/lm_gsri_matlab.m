% erg = lm_gsri_matlab(x,y)
% 
%   m   

function erg = lm_gsri_matlab(x,y)

if(size(x,1)==1)
    x=x';
end
if(size(y,1)==1)
    y=y';
end

X = x-1;
[b,bint]=regress(y-1,X);
% y-1 = X*b
% save lm_gsri

% b = X\(y-1); 


% b-b2

% close all

erg.m = b;
erg.res = (y-1-X*b);
erg.mSE = bint;


