% p = OmicsVartest2(O,O2)

function p = OmicsVartest2(O,O2)

d = get(O,'data');
d2 = get(O2,'data');

p = NaN(size(d,1),1);
if sum(abs(size(d)-size(d2)))>0
    error('Dimensions of the two @OmicsData sets does not coincide.');
end

for i=1:size(d,1)
    [~,p(i)] = vartest2(d(i,:),d2(i,:));
end
