
function [rem,rem2,rem3,rem4] = PerfectlySeparated(O,sep)

if ~exist('O','var')
    error('MissingValues/PerfectlySeparated.m requires class O as input argument.')
end
if ~exist('sep','var') || isempty('sep')
    sep = false;
end

dat = get(O,'data');
dat(dat==0)=nan;
dat = isnan(dat);
rem = []; rem2 = []; 

if ~isfield(O,'X') % Whole data matrix
    
    if ~sep  %Find perfectly separated   
        for i=1:size(dat,2)
            if ( all(dat(i,1:15) == 0) && all(dat(i,15:30)==1) )
                rem = [ rem i];
            elseif ( all(dat(i,1:15) == 1) && all(dat(i,15:30)==0) )
                rem2 = [ rem2 i];
            end
        end
        
    else  % Find row of EITHER Light/Heavy which are all isnan==0 || isnan==1
        rem3 =[]; rem4 =[];
        for i=1:size(dat,2)
            if       all(dat(i,1:15) == 0)
                rem = [ rem i];
            elseif   all(dat(i,1:15) == 1)
                rem2 = [ rem2 i];
            elseif   all(dat(i,15:30) ==0) 
                rem3 = [ rem3 i];
            elseif   all(dat(i,15:30) ==1) 
                rem4 = [ rem4 i];
            end
        end
    end

else  % Separated by Sample Name
    
    X = get(O,'X');
    rem = zeros(1,1);
    
    for k=1:size(X,3)
        loc = find(X(:,1,k)==1);
        loc2 = find(X(:,2,k)==1);
        re = []; re2 = [];
        for i=1:size(dat,1)
            if ( all(dat(i,loc) == 0) && all(dat(i,loc2)==1) )
                re = [re i];
            elseif ( all(dat(i,loc) == 1) && all(dat(i,loc2)==0) )
                re2 = [ re2 i];
            end
        end
        if ~isempty(re)
            rem(1:length(re),k) = re;
        end
        if ~isempty(re2)
            rem2(1:length(re2),k) = re2;
        end
    end
end
