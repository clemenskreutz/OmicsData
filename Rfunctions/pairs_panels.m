% pairs_panels(x,names,filename,varargin)
% 
% This function makes the pairs.panel plot (similar to plotmatrix.m) which
% is only available in R.
% 
% x         data matrix
% 
% names     column names (=variable names)
% 
% filename  filename for png
% 
% varargin
%           'method'    'spearman'
% 
% Example:
% pairs_panels(Xall{1},xnamesAll{1},'pairs_panels','method','spearman');

function pairs_panels(x,names,filename,varargin)
if ~exist('filename','var') || isempty(filename)
    filename = 'pairs_panels';
end

method = 'pearson'; % alternatively: spearman, kendall

for i=1:2:length(varargin)
    if ischar(varargin{i+1})
        eval([varargin{i},'=''',varargin{i+1},''';'])
    else
        eval([varargin{i},'=',varargin{i+1},';'])
    end
end

[~,file]=fileparts(filename);
filename = [file,'.png'];  % add '.png'

openR
global OPENR
OPENR.libraries{end+1} = 'psych';

putRdata('x',x);
putRdata('names',names);
putRdata('filename',filename);
putRdata('method',method);

evalR('colnames(x) <- names');
evalR('png(filename,width=1600,height=1000)');
evalR('pairs.panels(x,method=method,cex.labels=2)')
evalR('dev.off()');
x = getRdata('x'); % required in order to execute the code
closeR;



