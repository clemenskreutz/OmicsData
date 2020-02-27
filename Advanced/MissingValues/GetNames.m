% Turn function names into explanatory names (eg for figures)
%
% Examples:
% names = GetNames(O)
% names = GetNames(cellarray)

function names = GetNames(algo)

if isobject(algo)
    algo = get(algo,'method_imput'); % if O is given
end
if ~iscell(algo)
    algo  = {algo};                  % if string is given
end

names = algo;                        % set default

for i=1:length(algo)

    if strcmp(algo(i),'midastouch') 
        names{i} = 'pmm with donor selection';

    elseif strcmp(algo(i),'pmm') 
        names{i}= 'predictive mean matching';
    elseif strcmp(algo(i),'rf') 
        names{i}= 'random forest';
    
    elseif strcmp(algo(i),'missForest')
        names{i}= 'random forest';
    
    elseif strcmp(algo(i),'norm')
        names{i}= 'normal';
    
    elseif  strcmp(algo(i),'impnorm') || strcmp(algo(i),'imp.norm')
        names{i}= 'normal';
    
    elseif strcmp(algo(i),'impNorm') || strcmp(algo(i),'Norm')
        names{i}= 'normal';
    
    elseif strcmp(algo(i),'ri') 
        names{i} = 'random indicator';
    
    elseif strcmp(algo(i),'sample') 
        names{i} = 'random sampling';
    
    elseif strcmp(algo(i),'cart')
        names{i}= 'classification/regression trees';
    
    elseif strcmp(algo(i),'knn') || strcmp(algo(i),'impute.knn')
        names{i}= 'k-nearest neighbor';
    
    elseif strcmp(algo(i),'Amelia')
        names{i} = 'Expectation maximization';
    
    elseif strcmp(algo(i),'regression') || strcmp(algo(i),'aregImpute')
        names{i}= 'additive regression';
    
    elseif strcmp(algo(i),'ppca') 
        names{i}= 'probabilistic pca';
    
    elseif strcmp(algo(i),'bpca')
        names{i}= 'bayesian pca';
    
    elseif strcmp(algo(i),'nipals')
        names{i}= 'nonlinear partial LS';
    
    elseif strcmp(algo(i),'nlpca')
        names{i}= 'nonlinear pca (neural net)';
    
    elseif strcmp(algo(i),'svd') || strcmp(algo(i),'svdImpute')
        names{i}= 'singular value decomp.';
    
    elseif strcmp(algo(i),'MinDet') 
        names{i}= 'minimal value';
    
    elseif strcmp(algo(i),'MinProb')
        names{i}= 'probabilistic minimal value';
    
    elseif strcmp(algo(i),'QRILC')
        names{i}= 'quantile regression';
    
    elseif strcmp(algo(i),'SVTApproxImpute') || strcmp(algo(i),'SVTImpute')
        names{i}= 'singular value threshold';
    
    elseif strcmp(algo(i),'SVDImpute')
        names{i}= 'singular value decomp.';
    
    elseif strcmp(algo(i),'kNNImpute')
        names{i}= 'k-nearest neighbor';
    
    elseif strcmp(algo(i),'lmImpute')
        names{i}= 'locally weighted LS';
    
    elseif strcmp(algo(i),'softImpute')
        names{i}= 'soft-thresholded svd';
    
    elseif strcmp(algo(i),'irmi')
        names{i}= 'iterative robust';
    
    elseif strcmp(algo(i),'Seq') || strcmp(algo(i),'impSeq') 
        names{i}= 'sequential';
    
    elseif strcmp(algo(i),'SeqRob') || strcmp(algo(i),'impSeqRob')
        names{i}= 'robust sequential';
    
    elseif strcmp(algo(i),'MIPCA')
        names{i}= 'multiple imputation pca';
    
    elseif strcmp(algo(i),'imputePCA')
        names{i}= 'pca';
    
    elseif strcmp(algo(i),'mi')
        names{i}= 'multiple iterative regression';
    
    end
end
