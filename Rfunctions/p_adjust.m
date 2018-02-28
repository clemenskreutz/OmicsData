% padj = p_adjust(p)
%
% padj = p_adjust(p,method,naomit)
%
% Calculation of adjusted p-values like FDR using the R function p.adjust
%
%   p           p-values
%               If a matrix is provided, then the adjustment (e.g. FDR) is
%               calculated for each column.
%
%   method      Adjustment method as used by R function p.adjust
%
%
%   naomit      If only ~isnan is used the calculate the adjusted p-values
%               Default: 0.
%               For some adjustmetns and/or newer verions of R, it does not
%               make a difference.
% 
% 
%   Examples:
% 
% padj = p_adjust(rand(1000,1));
% hist(padj,100)
% 
% padj = p_adjust(rand(1000,10).^4);
% hist(padj,100)

function padj = p_adjust(p,method,naomit)
if(~exist('method','var'))
    method = 'fdr';
end
if(~exist('naomit','var') | isempty(naomit))
    naomit = 0;
end

if(size(p,1)==1) % make a column
    p = p';
end

padj = NaN(size(p));

if(size(p,1)>1 && size(p,2)>1)
    for i=1:size(p,2)
        padj(:,i) = p_adjust(p(:,i),method,naomit);
    end
else
    
    for i=1:size(p,2)
        openR;
        if(naomit==1)
            notnan = find(~isnan(p(:,i)));
            padj(:,i) = NaN*ones(size(p(:,i)));
            if length(notnan)>10
                putRdata('p',p(notnan,i));
                evalR(sprintf('padj <- p.adjust(p,method="%s")',method));
                padj(notnan,i) = getRdata('padj');
            end
            
        else
            putRdata('p',p(:,i));
            evalR(sprintf('padj <- p.adjust(p,method="%s")',method));
            padj(:,i) = getRdata('padj');
        end
        closeR
    end
    
end
