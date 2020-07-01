% Normiert eine Matrix so, dass jede Zeile Mittelwert Null und
% Standardabweichung 1 hat.
% 
% [erg,mw,sd] = Normiere(dat,nurmw,removeInf)
%   bei nurmw == 0 wird Mw = 0, sd = 1 gesetzt (Default)
%   bei nurmw == 1 wird nur der Mittelwert gleich gesetzt. 
%   bei nurmw == 2 wird nur durch die Stdabw geteilt.
%   bei nurmw == -1 wird gar nichts gemacht !!
% 
%   removeInf   Default: 0 Sollen inf Werte auf NaN gesetzt werden?
% 
%   erg     Normierte Daten
%   mw      Der Mittelwert vor Normierung
%   sd      Die STandardabw. vor Normierung
% 
% Beispiel:
%   for donorm = [0,1,2]
%       d{i} = Normiere(dat,donorm);
%   end

function [erg,mw,sd] = Normiere(dat,nurmw,removeInf)
if(~exist('nurmw','var') || isempty(nurmw))
    nurmw = 0;
end
if(~exist('removeInf','var') || isempty(removeInf))
    removeInf = 0;
end

if(removeInf==1)
    dat(isinf(dat)) = NaN;
end

mw = nanmean(dat,2);
sd = nanstd(dat,[],2);

if(nurmw==1)
    erg = dat - mw * ones(1,size(dat,2)) ;
elseif(nurmw==2)
    erg = dat ./ (sd*ones(1,size(dat,2))) ;
elseif(nurmw==0)
    erg = dat - mw * ones(1,size(dat,2)) ;
    erg = erg ./ (sd*ones(1,size(dat,2))) ;
else
    erg = dat;
end

