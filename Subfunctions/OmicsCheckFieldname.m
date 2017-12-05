function ok = OmicsCheckFieldname(fname)
tmp = struct;
try
    tmp.(fname) = 1;
    ok = 1;
catch
    ok = 0;
end
