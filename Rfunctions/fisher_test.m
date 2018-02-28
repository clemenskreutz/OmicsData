% Fisher's Exact Test for contingency tables calling the R function
% fisher.test
% 
%   Newer Matlab versions have the same functionality implemented as
%   fishertest.m
% 
% p = fisher_test(cont)
% 
%   cont    Matrix or cell of many matrices representing contingency tables
% 
% 
% p = fisher_test(cont,alternative)
% 
% alternative: indicates the alternative hypothesis and must be one of
%           'two.sided', 'greater' or 'less'. You can specify just
%           the initial letter.  Only used in the 2 by 2 case.
% 
% 
%   Examples:
% 
% p1 = fisher_test([10,2;3,3]);
% p2 = fisher_test([10,2;3,10]);
% [h,P1]=fishertest([10,2;3,3]);
% [h,P2]=fishertest([10,2;3,10]);

function p = fisher_test(cont,alternative);
if(~exist('alternative','var') | isempty(alternative))
    alternative = 'two.sided';
end
if(~isa(cont,'cell'))
    contCell{1} = cont;
else
    contCell = cont;
end

rstr = ['p <- fisher.test(cont, workspace = 500000,alternative="',alternative,'")$p.value'];

openR;

p = NaN*ones(length(contCell),1);
for i=1:length(contCell);
    putRdata('cont',contCell{i});
      
    evalR(rstr);
    p(i) = getRdata('p');
end
closeR;

