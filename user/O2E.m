% Conversion of @OmicsData to @maExperiment object

function E = O2E(O)

E = maExperiment(get(O,'data'));
fnames = get(O,'fnames');
IDs = get(O,'IDs');
if length(strmatch('Row',fnames))>0.5*length(fnames) && ~isempty(IDs)
    fnames = IDs;
end
E = set(E,'IDs',fnames);
E = set(E,'hy',get(O,'snames'));



