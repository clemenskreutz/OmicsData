function [O,out] = DIMA(O)

out = LearnPattern(O);
O = set(O,'out',out);

O = GetComplete(O);

O = AssignPattern(O);

saveO(O)