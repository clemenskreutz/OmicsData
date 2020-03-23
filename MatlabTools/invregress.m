function y = invregress(X,b)

if size(X,2) < size(b,2)
    disp('regress.m: Intercept is added.');
    X = [ones(size(X,1),1),X]; % 1st column Intercept hinzufuegen
end
if size(X,2) ~= size(b,2)
    warning('No multiple linear regression performed. Design matrix and coefficients have different sizes. check it.')
    return
end

try
    b(isnan(b)) = 0;
    for i=1:size(b,1)
        y(i,:) = b(i,:)*X';
    end
catch
    save error
    rethrow(lasterror)
end