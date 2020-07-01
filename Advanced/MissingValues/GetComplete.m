%  O = GetComplete(O)
%
%  delete all features with (many) MV
%
%  if less than 50 features have no MV, one MV per feature is allowed
%  if less than 50 features have one MV, two MVs per feature are allowed
%  ...
%
%  O - @OmicsData object

function O = GetComplete(O)

if ~exist('O','var')
    error('MissingValues/GetComplete.m requires class O as input argument.')
end

O = set(O,'data_original',[]);          % Put in container so it stays original (always same size)  
dat = get(O,'data');
O = set(O,'data_original',dat,'Original dataset');


%% Delete all nan elements
if sum(~any(isnan(O),2))>size(O,1)/2
    O = O(~any(isnan(O),2),:);
    fprintf('All lines with missing values deleted.\n')  
else
    for i=2:size(O,2)
        if sum(sum(isnan(O),2)<i)>size(O,1)/2
            O = O(sum(isnan(O),2)<i,:);
            fprintf(['All lines with >' num2str(i-1) ' MV deleted.\n']) 
            break
        end
    end
    if i==size(O,2)
        for i=2:size(O,2)
            if sum(sum(isnan(O),2)<i)>size(O,1)/3
                O = O(sum(isnan(O),2)<i,:);
                fprintf(['All lines with >' num2str(i-1) ' MV deleted.\n']) 
                break
            end
        end
    end        
   % if i>size(O,2)/2
   %     warning('Many MVs. Does imputation make sense here?')
   % end
end
if size(O,1)==size(dat,1)
    warning('Complete/Known matrix not feasible. Kept original matrix as data default.')
else
    idx = ceil(rand(size(dat,1),1)*size(O,1));
    O = O(idx,:) + randn(size(idx)).*nanstd(O(idx,:));
end
%idx2 = randsample(size(O,1),size(dat,1)-size(O,1),true,sum(~isnan(O),2)/min(sum(~isnan(O),2)));
%O = [O; O(idx2,:) + nanstd(O(idx2,:)).*randn(length(idx2),size(O,2))];%/size(O,2);%sum(~isnan(O),2);
%dat = get(O,'data');
%O2 = O + dat*0.05.*randn(size(O)); 