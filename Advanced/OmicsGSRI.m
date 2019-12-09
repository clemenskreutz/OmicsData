function [rest,erg] = OmicsGSRI(O,anno,p,minanz,file,vgl_names)

if size(anno,1)==1
    anno = anno';  % make column
end

[~,~,ib] = unique(anno,'stable');

%% Translate anno into the required "shape"
goids = cell(size(anno));
gonames = cell(size(anno));
for i=1:length(anno)
    goids{i} = [ib(i)];
    gonames{i} = {anno{i}};
end

E = O2E(O);  % conversion to @maExperiment
E = set(E,'goids',goids);
E = set(E,'gonames',gonames);
E = set(E,'symbol',get(O,'Proteins'));

[rest,erg] = GSRI(E,p,minanz,file,vgl_names);

