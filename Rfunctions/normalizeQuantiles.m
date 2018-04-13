% This function uses the normalizeQuantiles function of the limma package

function xnorm = normalizeQuantiles(x)

openR
putRdata('x',x)
evalR('require(limma)');
evalR('xnorm <- normalizeQuantiles(x)')
xnorm = getRdata('xnorm');

