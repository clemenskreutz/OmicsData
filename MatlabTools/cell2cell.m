% cout = cell2cell(c)
%
%   Ersetzt in Spalten
%       mit überwiegend Zahlen;
%       mit überwiegend Strings:
function cout = cell2cell(c,nheader)
if(~iscell(c))
    error('cell2cellstr requires a cell as input.')
end
if ~exist('nheader','var') || isempty(nheader)
    nheader = 0;
end

nnum = NaN(1,size(c,2));
nchar = NaN(1,size(c,2));
for j=1:size(c,2)
    nnum(j) = sum(cellfun(@isnumeric,c((nheader+1):end,j)))...
        -sum(cellfun(@isempty,c((nheader+1):end,j)));
    isNaN = zeros(size(c,1),1);
    for i=(nheader+1):size(c,1)
        if isnumeric(c{i,j})
            isNan(i) = isnan(c{i,j});
        else
            isNan(i) = 0;
        end
    end
    nnum(j) = nnum(j)-sum(isNan);
    nchar(j) = sum(cellfun(@ischar,c((nheader+1):end,j)));
end

cout = cell(size(c));
for i=1:size(c,1)    
    for j=1:size(c,2)
        if i<=nheader
            cout{i,j} = c{i,j};     
        elseif nnum(j)>nchar(j) % column with more numeric values
            if(isempty(c{i,j}))
                cout{i,j} = '';
            elseif ischar(c{i,j})
                if strcmp(lower(c{i,j}),'na')
                    c{i,j} = 'NaN';
                end
                cout{i,j} = str2num(c{i,j});
            else
                cout{i,j} = c{i,j};
            end
        else % column with more numeric values
            if(isempty(c{i,j}))
                cout{i,j} = '';
            elseif isnumeric(c{i,j})
                cout{i,j} = num2str(c{i,j});
            else
                cout{i,j} = c{i,j};
            end
        end
    end
end
