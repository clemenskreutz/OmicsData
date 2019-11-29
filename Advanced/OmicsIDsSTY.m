% O = OmicsIDsSTY(O)
% 
%   Adding IDs that are accessible via get(O,'IDs') and that are used as
%   default feature label in Tables for Phosphoproteomics data (STY,
%   MaxQuant)

function O = OmicsIDsSTY(O)
IDs = get(O,'IDs');

if ~isempty(IDs)
    warning('IDs are already available and now overwritten ...')
end

IDs = strcat(num2strArray(get(O,'id')),'_',get(O,'Proteins'),'_',get(O,'PositionsWithinProteins'));
O = set(O,'IDs',IDs);


