function [O,out] = DIMA(O)

out = LearnPattern(O);

O = GetComplete(O);

O = AssignPattern(O,out);

saveO(O)