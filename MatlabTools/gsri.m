% [rest,erg] = gsri(p,w,doplot,meth,dogrenander)
% 
%   meth    'conservative'
%           'unbiased'
%   dogrenander   1 (default)
%               0

function [rest,erg] = gsri(p,w,doplot,meth,dogrenander)
if(~exist('w','var') | isempty(w))
    w = ones(size(p));
end
if(~exist('dogrenander','var') | isempty(dogrenander))
    dogrenander = 0;
end
if(~exist('doplot','var') | isempty(doplot))
    doplot = 0;
end
if(~exist('meth','var') | isempty(meth))
    if(length(p)<=250)
        meth='conservative';
    else
        meth='unbiased';
    end
end

if(length(p)<10)
    warning('warn:GSRI2',['gsri.m: Only ',num2str(length(p)),' p-values.'])
%     warning('Estimation with less than 10 p-values is not recommended.')
elseif(length(p)<=2)
    warning('warn:GSRI',['gsri.m: Only <=2 p-values.'])
    rest = 0;
    return
end

w = w/sum(w);

[p,idx] = sort(p);
w = w(idx);

erg.res = 1;
erg.mestSE = NaN;
erg.p = p;
erg.w = w;


% close all
dofit = true;
restalt = 0;
rest = 0;
iter = 0;
weg = [];
while(dofit)
    iter = iter+1;

    y = cumsum(w);
    x = p;
    
%     [y2,x2] = ecdf(p);
%     y2=y2(2:end);
%     x2=x2(2:end);    
%     [y',y2,x',x2]
    

    if(dogrenander==1)
        g = grenander(x);
        y = g.Finter;
    end
    weg = find(y<rest );

%     hold off
%     plot(x(weg),y(weg),'r.')
%     hold on
    y(weg)=[];
    x(weg)=[];
%     plot(x,y,'.')
%     axis([0,1,0,1])

    if(length(x)<=1)
        if(isempty(x))
            elm.m = 0;
        elseif(y==1 & x==1)
            elm.m = 0;
        else
            elm.m = (1-y)/(1-x);
        end
        erg.iter = iter;
        elm.mSE = NaN;
    else
        elm = lm_gsri_matlab(x,y);
        %         elm = lm_gsri(x,y);
    end

%         abplot(elm.m,1-elm.m);
%     drawnow
%     pause(1)

    if(doplot==1)
        plot(p,cumsum(w),'co')
        hold on
        plot(x,y,'bo');
        %     plot(X+1,b*(X+1),'k')
        plot([-.02,.02],[1-elm.m,1-elm.m],'r')
        axis([0,1,0,1])
        abplot(elm.m,1-elm.m);
        xlabel('p-value')
        ylabel('empirical cumulative density function')
        publ(2)
        hold off
    end

    %     axis([0,1,0,1])
    %     abplot(erg.m,1-erg.m);

    if(strcmp(meth,'conservative')==1)
        rest = 1-elm.m;
    elseif(strcmp(meth,'unbiased')==1) % 
        rest = 1-elm.m + (elm.m*(1-elm.m));
    else
        error('gsri.m: meth unknown.')
    end
    %     [rest,restalt]
    if(abs(restalt-rest)<.01 || iter>50 || rest<restalt)
%         disp(['Rest=',num2str(rest),', iter=',num2str(iter),', rest-restalt=',num2str(rest-restalt),', ',num2str(length(p)),' p-values, meth=',meth,' grenander=',num2str(dogrenander)])
        break
    end
    restalt = rest;
end
% drawnow
% pause(2)
erg.rest = rest;
erg.mestSE = diff(elm.mSE)/2;
if isempty(erg.mestSE)
    erg.mestSE = NaN;
end
erg.iter = iter;
erg.cdf_y = cumsum(w);
erg.cdf_x = p;

erg.pdf_x = linspace(0,1,100)';
% pp = csaps(erg.cdf_x,erg.cdf_y);
% erg.pdf_y = fnplt(pp,erg.pdf_x);

if exist('csaps')==2 % Curve fitting toolbox available
    [erg.cdf_y_spline] = csaps(erg.cdf_x,erg.cdf_y,.999,erg.pdf_x);
else
    pp = splinefit(erg.cdf_x,erg.cdf_y,3);
    erg.cdf_y_spline = ppval(pp,erg.pdf_x);
%     plot(diff(erg.cdf_y_spline))    
end
dx = diff(erg.pdf_x(1:2));
erg.pdf_y = interp1(mean([erg.pdf_x(1:end-1),erg.pdf_x(2:end)],2),diff(erg.cdf_y_spline)/dx,erg.pdf_x);

