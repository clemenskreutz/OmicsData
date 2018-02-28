% c = kendall(x,y)
% 
% Rank correlation calculated via kendalls tau (calculated via R function
% cor)

function c = kendall(x,y)

openR;
putRdata('x',x);
putRdata('y',y);
evalR('tau <- cor(x,y,method="kendall")')
c = getRdata('tau');
closeR;
