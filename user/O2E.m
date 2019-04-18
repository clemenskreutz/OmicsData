% Conversion of @OmicsData to @maExperiment object

function E = O2E(O)

E = maExperiment(get(O,'data'));
E = set(E,'IDs',get(O,'fnames'));
E = set(E,'hy',get(O,'snames'));



