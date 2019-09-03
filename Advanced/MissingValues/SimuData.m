function full = SimuDataLazar(npep,rep,mu,sigP,sigG,sige)

%% Simulate peptides
P = [normrnd(mu,sigP,npep,1)*ones(1,rep/2), normrnd(mu,sigP,npep,1)*ones(1,rep/2)]; % two groups of proteins
G = zeros(npep,rep);
G(1:round(0.2*npep),1:round(rep/2)) = normrnd(mu,sigG,1,round(rep/2)).*ones(round(0.2*npep),1);
G(round(0.2*npep)+1:round(0.2*npep)*2,round(rep/2)+1:end) = normrnd(mu,sigG,1,round(rep/2)).*ones(round(0.2*npep),1);
G = G(randperm(npep),:);  % distribute abundant peptides randomly
e = normrnd(0,sige,npep,rep);
pep = P+G+e;

%% Simulate proteins
npro = npep/2;
m = randi(npro,npep,1); % for each peptide assign protein ID
u=unique(m);
n=histc(m,u);
s = u(n ==1);               % get indices for single peptide
d = u(n > 1);               % get indices for more than one peptide
full = nan(npro,rep);
full(s,:) = pep(ismember(m,s),:);  % assign peptide intensity for single pep
for i=1:length(d)
    full(d(i),:) = nanmean(pep(m==d(i),:));  % assign mean peptide intensity if more than one
end
full = full(~all(isnan(full),2),:);