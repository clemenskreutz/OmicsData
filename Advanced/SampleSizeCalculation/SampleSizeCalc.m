
% Load data
file = '..\3a_Franziska\txt\Phospho (STY)Sites.txt';
try
     load([pwd filesep 'O.mat'])
catch
     O = LoadWarscheid(file);
     save('O.mat','O')
end

% Chose setting
settings = {'p1','Whole'};

% Repeat whole experiment R1 or single experiments R1S1
a = (1:4).*ones(4,1); a2 = a';
pattern = ['real','R1','R2','R3','R4','S1','S2','S3','S4', strcat( strcat('R', cellstr(string(a(:))))' , strcat('S', cellstr(string(a2(:))))' )];

for s=1:length(settings)
    setting = settings{s};
    load O.mat O
    switch setting
        case 'Whole'
            O1 = O(:,contains(get(O,'hy'),'___1'));
            O2 = O(:,contains(get(O,'hy'),'___2'));  
            O3 = O(:,contains(get(O,'hy'),'___3'));   
            O1 = set(O1,'SampleNames',regexprep(get(O1,'SampleNames'),'___\d',''));
            O2 = set(O2,'SampleNames',regexprep(get(O2,'SampleNames'),'___\d',''));
            O3 = set(O3,'SampleNames',regexprep(get(O3,'SampleNames'),'___\d',''));
            O = [O1; O2; O3];
            O = set(O,'ProteinIDs',strcat('Row',cellstr(string(1:size(O,1))))');
        case 'p1'
            O = O(:,contains(get(O,'hy'),'___1'));
        case 'p2'
            O = O(:,contains(get(O,'hy'),'___2'));            
        case 'p3'
            O = O(:,contains(get(O,'hy'),'___3'));            
        otherwise 
            error('Setting %s unknown.',setting);
    end
    O = OmicsRemoveEmptyFeatures(O);
    O = ReplaceSamplenames(O);
    Oori = O;
    
    for pat = 1:length(pattern)
        O = Oori;
        if ~exist(setting,'dir')
            mkdir(setting)
        end
        % Imitate new experiments
        if ~contains(pattern(pat),'real')
            try
                load([setting filesep 'O' pattern{pat} '.mat'])
            catch
                O = O(:,contains(get(O,'SampleNames'),pattern{pat}));
                drin = find(sum(isnan(O),2)<size(O,2));
                Osim = O(drin,:);
                % Learn MV Pattern
                try
                    load([setting filesep 'out' pattern{pat} '.mat'])
                catch
                    out = LearnPattern(Osim); % takes some time
                    save([setting filesep 'out' pattern{pat} '.mat'], 'out')
                end
                % Simulate data
                %dat = randn(size(O,1),size(O,2))*nanstd(dat_original(:))+nanmean(O);
                %dat = SimuData(size(O,1),size(O,2),nanmean(nanmean(O)),nanstd(nanmean(O,2)),nanstd(nanmean(O)),nanstd(nanstd(O))); 
                Osim = GetComplete(Osim);
                Osim = Osim(ceil(rand(length(drin),1)*size(Osim,1)),:);
                Osim = AssignPattern(Osim,out,1);
                datsim = get(Osim,'data');
                dat = nan(size(O));
                dat(drin,:) = datsim;
                O = set(O,'data',dat,'Simulated pattern');
                save([setting filesep 'Osim' pattern{pat} '.mat'], 'O')
            end
            O = [Oori O];
        end
        


        %% Regression
        try
            load([setting filesep 'ps' pattern{pat} '.mat'])
        catch
            % Design Matrix
            [Xs,xnames] = O2X(O,'samples');
            [p,~,fold,varests,stats] = regress(O,Xs);
            [ps,~,folds] = regress_reg(O,Xs,nanmedian(varests),0.5);
            save([setting filesep 'ps' pattern{pat} '.mat'], 'ps','xnames')
            if contains(pattern(pat),'real')
                Oreg = invregress(Xs,fold);
                save([setting filesep 'Oreg.mat'],'Oreg')
            end
        end
    end
end

SampleSizePlot