% l = levels(df);
% Ermittelt die Levels l des discreten Faktors df.
% 
% [l,anz] = levels(df)
%   anz     Anzahl der entlevels l in df.

function [l,anz] = levels(df)

if(~isempty(df))
    if iscell(df) && sum(cellfun(@iscell,df))>0  % same cells are again cells
        same = NaN(length(df));
        for i1=1:length(df)
            for i2=(i1+1):length(df)
                if strcmp(class(df{i1}),class(df{i2}))~=1 % not same class
                    same(i1,i2) = 0;
                elseif isnumeric(df{i1})
                    same(i1,i2) = df{i1}==df{i2};
                elseif ischar(df{i1})
                    same(i1,i2) = strcmp(df{i1},df{i2});
                elseif iscell(df{i1}) 
                    same(i1,i2) = cellcmp(df{i1},df{i2});
                end
            end
        end
        drin = 1:length(df);
        indsame = find(sum(same(drin,drin)==1,1)>0);
        while ~isempty(indsame)
            drin = setdiff(drin,indsame(1));
            indsame = drin(find(sum(same(drin,drin)==1,1)));
        end
        l = df(drin);
        anz = NaN(size(df)); % not yet implemented
    elseif(iscell(df) && isnumeric(df{1})) % cell of numers
        dfarray = cell(size(df));
        for i=1:length(df)
            dfarray{i} = df{i}(:);
        end
        cl = cellfun(@length,dfarray);
        nums = ones(max(cl),length(cl))*(pi-3);  % ich wollte NaNs benützen, damit can unique jedoch nicht umgehen, nehme darum (pi-3) zum auffüllen bei ungleicher Länge
        for i=1:length(df)
            nums(1:cl(i),i) = dfarray{i};
        end
        [uni,ia,ib]=unique(nums','rows');
        l = df(ia);
        [~,anz] = levels(ib);
    elseif(iscell(df)) %strings
%     if(iscell(df)) %strings
		nan = find(cellempty(df));
		df(nan) = [];
        if(~isempty(df))
			l{1} = df{1};
			for i=2:length(df)
                if(isempty(find(strcmp(df{i},l))))
                    l{length(l)+1} = df{i};
                end
			end
            if(~isempty(nan))
                if(sum(cellfun(@ischar,df)~=1)>0)
                    l{end+1} = NaN;    
                end
            end
            l = sort(l);
        else
            l = {};
        end
	else  % numerisch
		nan = find(isnan(df));
		df(nan) = [];
        if(~isempty(df))
			l(1) = df(1);
			for i=2:length(df)
%                 if(isempty(find(abs(df(i)-l)<eps)))
                if(isempty(find(df(i)==l)))
                    l(length(l)+1) = df(i);
                end
			end
            if(~isempty(nan))
                l(end+1) = NaN;    
            end
            l = sort(l);
        else
            l = [];
        end
    end    
else
    l = [];
    anz = [];
end

if(nargout>1)
    if iscell(df) && isnumeric(df{1})
        % anz wurde oben schon berechnet
    elseif(iscell(df)) %strings
        anz = 0;
        for i=1:length(l)
            anz(i) = length(strmatch(l{i},df,'exact'));
        end
    else    %numerisch
        for i=1:length(l)
            if(~isnan(l(i)))
                anz(i) = nansum(l(i)==df);
            else
                anz(i) = sum(isnan(df));
            end            
        end
    end
end