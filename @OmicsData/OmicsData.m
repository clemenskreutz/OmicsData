% Konstruktor der Klasse OmicsData
% 
% O = OmicsData(file_or_data, name)
% 
%   name    Name of the project
% 
% 
%   Examples:
%   O = OmicsData;   % empty Object

function O = OmicsData(file_or_data, name)    
if ~exist('name','var') || isempty(name)
    name = '';
end

if(~exist('file_or_data','var') || isempty(file_or_data))  % load default data set
    O = OmicsData(OmicsStruct);
    
elseif(isstruct(file_or_data)) %Konvertierung von Struct zu Klasse
    % Es wird schon eine Structur �bergeben, die dann in die Klasse
    % umgewandelt wird.
    Ostruct = file_or_data;
    O = class(Ostruct,'OmicsData');   

elseif(isnumeric(file_or_data)) % Falls Datenmatrix �bergeben wurde oder Gr��e einer Matrix (f�r Zufallsdaten)
    data = file_or_data;    
    Ostruct = OmicsStruct;
    Ostruct.data.(Ostruct.config.default_data) = data;
    O = OmicsData(Ostruct);

else  % filename for reading
    file = file_or_data;
%     w = which('OmicsData');
    
    [pfad,filename,ext] = fileparts(file);
    if isempty(pfad)
        [pfad,filename,ext] = fileparts(which(file));
    end
    matfile = [pfad,filesep,filename,'.mat'];

    if exist(matfile,'file')
        fprintf('Load data from %s (if not intended remove/rename this workspace).\n',matfile);
        tmp = load(matfile);
        data = tmp.data;
        rownames = tmp.rownames;
        colnames = tmp.colnames;
    else
        % Read data here
        fprintf('Read data from: %s ...\n',file);
        [data, rownames, colnames] = OmicsReadDataMaxQuant(file);
        [data, rownames, colnames] = OmicsData2Datamatrix(data,rownames);
        save(matfile,'data','rownames','colnames');
        fprintf('Save data to %s ...\n',matfile);
    end
    
	
	if(isempty(name)) % falls []
		name = '';
	end
    

    O = OmicsStruct;			
	O.name  = name;		
    O.data = data;
    O.cols = rownames; % rownames are columns
    O.rows.SampleNames = colnames; % columnnames are rows
    
	O = class(O,'OmicsData');
	
	end    
	
end

