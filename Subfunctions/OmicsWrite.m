function OmicsWrite(O,outfile,varargin)

if nargin<1
    error('OmicsWrite.m: Have to pass in Omics class O to write OmicsClass O in .xls.')
end
if nargin<2
    outfile = 'OmicsWriteData.xls';
end
if strcmp(outfile(end-3:end),'.xls') || strcmp(outfile(end-4:end),'.xlsx') || strcmp(outfile(end-3:end),'.csv')
else, outfile = [outfile '.xls'];
end

data = get(O,'data');
SampleNames = get(O,'SampleNames');
ProteinNames = get(O,'Proteinnames');

if nargin>3 && ~isempty(varargin)
    for i=1:2:size(varargin)
        if isstring(varargin{i}) || ischar(varargin{i})
          SampleNames = [SampleNames, varargin(i)];
        else
            error('OmicsWrite.m: Expected string as input. Each extra variable has to be named first.')
        end
        if isnumeric(varargin{i+1}) && ( size(varargin{i+1},1) == size(data,1) )
            data = [data, varargin{i+1}];
        else
            error('OmicsWrite.m: Expected vector of size(dat,1) to define a Protein parameter.')
        end
    end
end

xlswrite(outfile,SampleNames,'Sheet1','B1');
xlswrite(outfile,ProteinNames,'Sheet1','A2');
xlswrite(outfile,data,'Sheet1','B2');

if nargin>3 && ~isempty(varargin)
    fprintf('OmicsWrite.m wrote data matrix')
    for i=1:2:size(varargin)
        fprintf([', ' varargin{i}])
    end
    sprintf([' columnwise in ' outfile '.\n'])
else
    fprintf(['OmicsWrite.m wrote data matrix in ' outfile '.\n'])
end