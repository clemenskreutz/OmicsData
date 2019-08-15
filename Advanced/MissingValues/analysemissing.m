
function O = analysemissing(O)

% LogisticNanModelcomp(int,rowID,colID,rowint,colint,pepCount,SeqCov,lin,norm)
out = LogisticNanModel(O);
%LogisticNanModelPlot

O = deletemissing(O);

O = assignmissing(O,out);

saveO(O)