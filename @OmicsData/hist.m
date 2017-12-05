% Plotting a histogram of the data specified by O.config.default_data. In
% contrast to the normal histogram function hist.m, individual subplots are
% drawn for each sample
% 
% 

function varargout = hist(O,varargin)
if isempty(varargin)
    varargin{1} = 100;
end

dat = get(O,'data');
ns = size(dat,2);

% Proper font size
if ns<10
    fs = 10; 
elseif ns<17
    fs = 8;
elseif ns <31
    fs = 6;
else
    fs = 5;
end

snames = get(O,'snames');

subx = ceil(sqrt(ns));
suby = ceil(ns/subx);

xl = NaN(size(dat,2),2);
yl = NaN(size(dat,2),2);
for i=1:size(dat,2)
    indplot = ~isinf(dat(:,i));
    
    subplot(subx,suby,i)
    hist(dat(indplot,i),varargin{:});    
    if i==(suby*(subx-1)+1)
        xlabel(str2label(get(O,'default_data')),'FontSize',fs);
        ylabel('number of features','FontSize',fs);
    end
    title(str2label(snames{i}),'FontSize',fs);
    set(gca,'FontSize',fs)
    
    xl(i,:) = xlim;
    yl(i,:) = ylim;
end

xl = [min(xl(:,1)),max(xl(:,2))];
yl = [min(yl(:,1)),max(yl(:,2))];

for i=1:size(dat,2)
    subplot(subx,suby,i)
    xlim(xl);
    ylim(yl);
end

if nargout>0
    varargout{1} = out;
end
