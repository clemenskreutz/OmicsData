% s = num2strArray(n, force)
% Konvertiert einen Array von Zahlen in eine Zelle von strings
% 
%   force   sollen strings ohne Fehlermeldung so gelassen werden?

function s=num2strArray(n,force,format)
if(~exist('force','var') | isempty(force))
    force = 0;
end
if(~exist('format','var') | isempty(format))
    format = '%d';
end

if(min(size(n))==2)
    s = cell(size(n));
    for i=1:size(n,2)
        tmp = num2strArray(n(:,i));
        for j=1:length(tmp)
            s{j,i} = tmp{j};
        end
    end
elseif(min(size(n)>2))
    s = cell(size(n));
    for i=1:size(n,2)
        s(:,i) = num2strArray(n(:,i),force);
    end
%     error('num2strArray: The case min(size(n)>2 is not yet implemnted.')
else
    if(size(n,2)==1)
        s = cell(length(n),1);
    else
        s = cell(1,length(n));
    end

    if(force==0)
        for i=1:length(n)
            s{i}=num2str(n(i),format);
        end
    else
        if(iscell(n))
            for i=1:length(n)
                if(isnumeric(n{i}))
                    s{i}=num2str(n{i},format);
                else
                    s{i} = n{i};
                end
            end
        else
            s = num2strArray(n);
        end
    end
end