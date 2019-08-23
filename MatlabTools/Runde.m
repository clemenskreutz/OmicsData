% Rundet auf n signifikante Stellen
% y=Runde(x,n)
function y=Runde(x,n)
if(isnumeric(x))
    y = NaN*ones(size(x));
else
    y = x;
end

vorz = sign(x);
x = abs(x);

for i=1:length(x(:))
	if(x(i)~=0)
		ordn = ceil(log10(x(i)));
	else
	 	ordn = 0;
	end
	tmp = x(i)*10^(n-ordn);
	tmp = round(tmp)/10^(n-ordn);
	y(i)= tmp;
end

y = y.*vorz;
