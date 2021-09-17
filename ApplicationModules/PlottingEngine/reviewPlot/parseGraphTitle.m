function [ titleString ] = parseGraphTitle( titleString )
%parseGraphTitle substitutes meta data into graph title strings
%   MDRT's parseGraphTitle(str) looks for markup tags in the argument and
%   replaces those tags with data taken from the metadata file located in
%   each data set's 'data' folder.
%
%   Valid metadata markup tags are:
%
%   <operation>     inserts operation name
%   <procedure>     inserts MARS procedure name
%   <vehicle>       inserts "Vehicle Support" if true
%
%   Additional tags will be added in future releases
%


%% Markup Definition
% First column      defines the markup tag
% Second column     defines the metaData field
% Third column      defines kind of tag replacement
% Fourth column     defines what text will be inserted "if true"

tags = {
    '<operation>',       'operationName',    'str',      '';
    '<operationname>',   'operationName',    'str',      '';
    '<operation-name>',  'operationName',    'str',      '';
    '<procedure>',       'MARSprocedureName','str',      '';
    '<marsprocedure>',   'MARSprocedureName','str',      '';
    '<mars-procedure>',  'MARSprocedureName','str',      '';
    '<vehicle>',         'isVehicleOp',      'iftrue',   'Vehicle Support';
    '<vehiclesupport>',  'isVehicleOp',      'iftrue',   'Vehicle Support';
    '<vehicle-support>', 'isVehicleOp',      'iftrue',   'Vehicle Support';
    '<isvehicleop>',     'isVehicleOp',      'iftrue',   'Vehicle Support';
};



%% Constant definition

metaDataFileName = 'metadata.mat';


%% Load configuration struct and metaData

% config = MDRTConfig.getInstance;
% metaDataFile = fullfile(config.workingDataPath, metaDataFileName);

config = getConfig;
metaDataFile = fullfile(config.dataFolderPath, metaDataFileName);

    if exist(metaDataFile, 'file')

        load(metaDataFile);

    else

        % Fuck me, there isn't anything to load!?
        return

    end

%% Replace tags in titleString

for i = 1:size(tags,1)
    repStr = '';
    
    switch tags{i,3}
        case 'str'
            repStr = metaData.(tags{i, 2});
        case 'iftrue'
            if metaData.(tags{i,2})
                repStr = tags{i,4};
            end
        otherwise
    end
    
    titleString = regexprep(titleString, tags(i,1), repStr, 'ignorecase');
    
end


end

