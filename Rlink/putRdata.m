%   putRdata(varname,val)
% 
%   This function is used to push variables to the R-workspace
% 
%   varname     the variable name used in R

function putRdata(varname,val)
if ~ischar(varname)
    error('putRdata(varname,val)')
end


evalR_writeAndExecute  % execute R commands if they are in the buffer

ftmp = @(x)x;

evstr = sprintf('%s = feval(ftmp,val);',varname);

if iscell(val) && any(cellfun(@ischar,val))
    evstr2 = sprintf('save(''putRdata_cellstr.mat'',''%s'',''-append'');',varname);
else    
    evstr2 = sprintf('save(''putRdata.mat'',''%s'',''-append'');',varname);
end

eval(evstr);
eval(evstr2);


% tmp.(varname)=val;
% struct2Rmatlab(tmp,'openR.mat');