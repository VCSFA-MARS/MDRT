%% Valve Survey Script
%
%   The VSS analyzes data for valve tuning, positioning, and timing.
%   Graphical output is provided for ease of review. Text-based output is
%   provided at the Matlab console for more detailed review and
%   documentation.
%
%   Future implementations will produce retrieval files and initiate a
%   retrieval over the network.
%



%% Constants

remoteServer    = 'fcsdev3' ;
indexFileName   = 'AvailableFDs.mat' ;


%% Prompt user for data set - start with set selected in 'review'
%   pth is set as the path to the data folder (contains .mat files)

config = MDRTConfig.getInstance;
[pth, fldr, b] = fileparts(config.userWorkingPath);
questStr = ['Generate plot from data set in ', fldr];

result = questdlg(questStr, 'Continue with data set', ...
            'Yes', 'Select New', 'Quit', 'Yes');

switch result
    case 'Yes'     
        
    case 'Select New'
        hbox = msgbox('Select the ''data'' folder that contains the .mat files.', 'Directions');
        uiwait(hbox, 5);
        defaultpath = config.dataArchivePath;
        pth = uigetdir(defaultpath); % No checking implemented yet!;
        
        if ~ pth
            disp('Quitting Valve Analysis tool');
            return
        end
        
        
    case 'No'    
        disp('Quitting plot tool');
        return
        
    otherwise
        disp('Unknown selection');
        return
end


%% Load AvailableFDs if it exists

AvailFDFullFileName = fullfile(pth, indexFileName);

if exist( AvailFDFullFileName, 'file');
    contents = whos('-file', AvailFDFullFileName);
    
    index = find(~cellfun('isempty',strfind({contents(:).name}, 'FDList')));
        
    load(AvailFDFullFileName);
   
else
    disp('No suitable AvailFD file found');
    return
end

%% Find all valve data

mustHave = 'Damper|Positioner|Valve|[D|P]CVN[OC]|RV';
mustNotHave = { 'Close|Open|Var|Percent|Pump|Fan|__' };
excludeValves = { 'RV-000[15678]|WDS PCR|Shut-Out'} ;

propSearch = {' Mon' };

l_allValves = ~cellfun('isempty',regexp(FDList(:,1), mustHave));
l_toExclude = ~cellfun('isempty',regexp(FDList(:,1), mustNotHave));
l_notValves = ~cellfun('isempty',regexp(FDList(:,1), excludeValves));

l_allValves = l_allValves & ~l_toExclude & ~l_notValves ;

FDList(l_allValves, 1)

l_proportional = ~cellfun('isempty',regexp(FDList(:,1), propSearch));
l_proportional = l_allValves & l_proportional;
i_proportional = find(l_proportional);

FDList(l_proportional, 1)

l_propCmd = ~cellfun('isempty', regexp(FDList(:,1), 'Cmd Param'));
l_propCmd = l_allValves & l_propCmd ;
i_propCmd = find(l_propCmd);

FDList(l_propCmd, 1)

%% Load Valve Data into Structures

valveData = struct;


for i = 1:length(i_proportional)
    load( fullfile(pth, FDList{i_proportional(i),2}) );
    valveData(i).pos = fd;
end

%% Plot Proportional Valves



for i = 1:length(i_proportional)
    
    
    
    
    
    
    
end









