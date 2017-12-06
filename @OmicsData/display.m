%   display(O)
% 
% This function controls the printed text in Matlab's command line if an
% @OmicsData Object is typed without semicolon
% 

function display(O)

fprintf('   Object of class @OmicsData with\n')
fprintf('   %i features, %i samples \n',get(O,'nfeatures'),get(O,'nsamples'));
ana = get(O,'analyses');
if isempty(ana)
    fprintf('   Type ''get(VARNAME)'' for inspecting the structure.\n\n');
else
    for i=1:length(ana)
        fprintf('Analysis %i applied to %s:  %s\n',i,ana{i}.datafield,ana{i}.description);
    end
end



