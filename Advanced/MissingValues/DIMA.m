function O = DIMA(O)

out = LearnPattern(O);

O = GetComplete(O);

O = AssignPattern(O,out);