function CheckPattern(O)

dat = get(O,'data_original');
dat = dat(~all(isnan(dat),2),:);
A = get(O,'data_mis');
A = A(:,:,1);
A = A(~all(isnan(A),2),:);

nmisori = sum(sum(isnan(dat)))/size(dat,1)/size(dat,2)
nmispat = sum(sum(isnan(A)))/size(A,1)/size(A,2)

if abs(nmisori-nmispat) > 0.05 && abs(nmisori-nmispat)/nmisori > 0.2 && ~nmisori<0.01
    error('Number of MV in the simulated pattern differ strongly from the number of MV in the original data. Check it.')
end