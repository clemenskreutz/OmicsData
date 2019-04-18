%   OmicsStruct
% 
% Generates a struct template which can be converted to @OmicsData

function O = OmicsStruct

O = struct;

O.analyses = cell(0);       % documentation of analysis steps

O.cols = struct;            % annotation as columns (info for features)

O.config = OmicsConfigStruct;       % Configuration parameters
O.config.default_col = 'ProteinIDs';        % default field of annotation in the column format
O.config.default_row = 'SampleNames';       % default field of annotation in the row format
O.config.default_data = 'LFQIntensity';     % default field of annotation in the matrix format

O.container = struct;       % for additional info
O.data = struct;            % data in the format nfeatures x nsamples

O.ID   = [];    % used as an Identifier which should be altered whenever the data is changed

O.info.pwd  = pwd;
O.info.time = datestr(now,30);   % date when the data struct was initialized
O.info.date = date;
O.info.path = {};

O.name = '';    % Name of the data-set
O.rows = struct;


