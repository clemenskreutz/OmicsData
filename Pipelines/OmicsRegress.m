function data = OmicsRegress(data,opts)

if iscell(data)
    for i=1:length(data)
        data{i} = OmicsRegress(data{i},opts);
    end
else
    
    label = data.label;
    O = data.O;
        
    res = struct;
    for i=1:length(opts.Design)
        design = opts.Design{i};
        reg_strength = opts.Regularization(i);
        
        warning('off','stats:regress:RankDefDesignMat');
        
        [res.X{i},res.xnames{i},res.grouplevels{i}] = DefineX(O,design);
        if sum(strcmp(res.xnames{i},str2fieldname(res.xnames{i}))==0)>0
            error('Define xnames that the can serve as fieldnames of a struct!')
        end
        [res.p{i},~,res.fold{i},res.varest{i},res.foldSE{i}] = regress(O,res.X{i});
        
        res.mean{i} = nanmean(O,2);
        
        use = ~isnan(res.varest{i}) & ~isinf(res.varest{i}) & res.varest{i}>1e-10;
        res.varestS{i} = NaN(size(res.varest{i}));
        res.varestS{i}(use) = smooth(res.mean{i}(use),sqrt(res.varest{i}(use)),1000,'lowess').^2;
        [~,iu] = unique(res.mean{i}(use));
        [~,iu2] = unique(res.mean{i}(~use));
        x = res.mean{i}(use);
        y = res.varestS{i}(use);
        xx = res.mean{i}(~use);
        tmp = NaN(size(xx));
        tmp(iu2) = interp1(x(iu),sqrt(y(iu)),xx(iu2),'linear','extrap').^2;
        res.varestS{i}(~use) = tmp;
        
        %% for features with less NaN, use only varest form those features:
        lessNaN = get(O,'propna')<0.2;
        res.varestS{i}(lessNaN) = smooth(res.mean{i}(lessNaN),sqrt(res.varest{i}(lessNaN)),1000,'lowess').^2;
        
        %% regularized regression
        [res.pr{i},~,res.foldr{i},res.foldrSE{i}] = regress_reg(O,res.X{i},res.varestS{i},reg_strength);
        
        % res.fdr{i} = FdrKorrekturMitR2(res.p{i},[],1);
        % res.fdrr{i} = FdrKorrekturMitR2(res.pr{i},[],1);
        [~,~,~,res.fdr{i}] =fdr_bh(res.p{i});
        [~,~,~,res.fdrr{i}]=fdr_bh(res.pr{i});
        
        res.label{i} = [label,', ',opts.Design{i},', PriorW=',num2str(reg_strength)];
        
        warning('on','stats:regress:RankDefDesignMat');
    end
    data.ana = res;
end