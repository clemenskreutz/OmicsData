function c = clusterdata(O,varargin)

if ~exist('varargin','var')
    varargin = ',"linkage","ward","maxclust",4';
end

if size(O,3)>1
    dat = get(O,'data');
    for i=1:size(O,3)
        c = clusterdata(dat(:,:,i),'linkage','ward','maxclust',4);
    end
else
    c = clusterdata(get(O,'data'),'linkage','ward','maxclust',4);
end
 