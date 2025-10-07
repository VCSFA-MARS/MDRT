function compareDrainBack
%% compareDrainBack generates plots of a specific event across multiple data sets.
%
%   Each event is visualized as two subplots:
%       - top: Pressure sensors
%       - bot: Valve positions/commands
%
%   Each figure/page will contain up to three events, as 3 columns of two
%   subplots, for a total of 6 subplots per page.
%
%   Every matching event instance that is found will generate one pair of
%   subplots. 
%
%   Launching the tool opens a GUI dialog that allows you to edit the
%   datasets that will be included and to customize the FDs that are
%   included in each subplot.

%% Constant Defs

DEFAULT_INTERVAL = '15m';

%% Create tool window

config = MDRTConfig.getInstance;

windowName = 'Historical Comparison - All Instances across missions';

    hs.fig = figure;
            guiSize = [672 387];
            hs.fig.Position = [hs.fig.Position(1:2) guiSize];
            hs.fig.Name = windowName;
            hs.fig.NumberTitle = 'off';
            hs.fig.MenuBar = 'none';
            hs.fig.ToolBar = 'none';
            hs.fig.Tag = 'importFigure';



%% Create UI Elements


hs.mis = uicontrol( 'style',                'edit', ...
                    'max',                  20, ...
                    'min',                  1, ...
                    'Units',                'normalized', ...
                    'position',             [0.077 0.61 0.708 0.336], ...
                    'HorizontalAlignment',  'left', ...
                    'FontUnits',            'normalized' ...
                    );

hs.top = uicontrol( 'style',                'edit', ...
                    'max',                  20, ...
                    'min',                  1, ...
                    'Units',                'normalized', ...
                    'position',             [0.077 0.39 0.708 0.163], ...
                    'HorizontalAlignment',  'left', ...
                    'FontUnits',            'normalized' ...
                    );

hs.bot = uicontrol( 'style',                'edit', ...
                    'max',                  20, ...
                    'min',                  1, ...
                    'Units',                'normalized', ...
                    'position',             [0.077 0.167 0.708 0.163], ...
                    'HorizontalAlignment',  'left', ...
                    'FontUnits',            'normalized' ...
                    );

hs.evt = uicontrol( 'style',                'edit', ...
                    'Units',                'normalized', ...
                    'position',             [0.077 0.058 0.708 0.049], ...
                    'HorizontalAlignment',  'left', ...
                    'FontUnits',            'normalized' ...
                    );

hs.int = uicontrol( 'style',                'edit', ...
                    'Units',                'normalized', ...
                    'position',             [0.808 0.75 0.159 0.05], ...
                    'HorizontalAlignment',  'left', ...
                    'String',               DEFAULT_INTERVAL, ...
                    'FontUnits',            'normalized' ...
                    );


hs.mlt = uibuttongroup("Title",             'Plot Mode', ...
                       'Units',                'normalized', ...
                       'Position',          [0.808 0.44 0.159 0.27]);

hs.ps1 = uicontrol('Parent',                hs.mlt, ...
                    'Style',                'radiobutton', ...
                    'String',               'AllTogether', ...
                    'Units',                'normalized', ...
                    'Position',             [0.05, 0.05, 0.9, 0.4], ...
                    'HorizontalAlignment',  'left' ...
                    );

hs.ps2 = uicontrol('Parent',                hs.mlt, ...
                    'Style',                'radiobutton', ...
                    'String',               'Individual', ...
                    'Units',                'normalized', ...
                    'Position',             [0.05, 0.55, 0.9, 0.4], ...
                    'HorizontalAlignment', 'left', ...
                    'Value',                1 ...
                    );

hs.run = uicontrol( 'style',                'pushbutton', ...
                    'String',               'Generate Plots', ...
                    'Units',                'normalized', ...
                    'position',             [0.808 0.058 0.159 0.336], ...
                    'HorizontalAlignment',  'center', ...
                    'Callback',             {@generatePlots, ...
                                              hs.mis, ...
                                              hs.top, ...
                                              hs.bot, ...
                                              hs.evt, ...
                                              hs.ps1, ...
                                              hs.int}, ...
                    'FontUnits',            'normalized' ...
                    );
                
%% Load Archive Data to Populate Initial Values                

    setappdata(hs.fig, 'isRemoteArchive', false);
    setappdata(hs.fig, 'selectedRootPath', config.dataArchivePath);
    setappdata(hs.fig, 'indexFilePath', config.dataArchivePath);

    % Load local archive by default
    allowRemote = false;
    t = load(fullfile(config.dataArchivePath, 'dataIndex.mat'));

    localDataIndex = t.dataIndex;
    setappdata(hs.fig, 'localDataIndex', localDataIndex);   % Retain local data index
    setappdata(hs.fig, 'fdMasterList',   localDataIndex(end).FDList);


    remoteDataIndex = [];
    if ~isempty(config.remoteArchivePath)
        % Remote data index is configured. Load the index and prepare it to be
        % used.

        allowRemote = true;
        t = load(fullfile(config.pathToConfig, 'dataIndex.mat'));
        remoteDataIndex = t.dataIndex;
    end
    setappdata(hs.fig, 'remoteDataIndex', remoteDataIndex); % Retain remote data index

%% Hard-coded presets

    dataFiles = { '5903 GN2 PT-5903 Press Sensor Mon.mat';
                  '5070 GN2 PT-5070 Press Sensor Mon.mat' };

    valveFiles = {'2031 LO2 DCVNC-2031 State.mat';
                  '2097 LO2 DCVNC-2097 State.mat';
                  '2029 LO2 PCVNO-2029 Globe Valve Mon.mat'};

    eventFD = 'LOLS Topoff Cmd';

%% Pre-populate mission list

    hs.mis.String = {localDataIndex.pathToData}';
    hs.top.String = dataFiles;
    hs.bot.String = valveFiles;
    hs.evt.String = eventFD;








end

function generatePlots(~, ~, dataFolders, dataFiles, valveFiles, eventFD, rbtnOverlay, timeIntEdit)

dataFolders = dataFolders.String;
dataFiles = dataFiles.String;
valveFiles = valveFiles.String;
eventFD = eventFD.String;
isOverlay = logical(rbtnOverlay.Value);
isValvePlot = false;
interval_str = timeIntEdit.String;

PageTitles = sprintf('%s Comparison Across Missions', eventFD);
fprintf('Plot all events on one axis: %s\n', mat2str(isOverlay))

%% Constants

onehr = 1/24;
onemin = onehr/60;
onesec = onemin/60;

%% Iterate across data sets and plan plots

DataSet = struct;
PlotParam = [];

for dfi = 1:numel(dataFolders)
    commandCounter = 0;
    metaFile = fullfile(dataFolders{dfi}, 'metadata.mat');
    timeFile = fullfile(dataFolders{dfi}, 'timeline.mat');
    
    ms = load(metaFile);
    ts = load(timeFile);
    
    DataSet(dfi).datafolder = dataFolders{dfi};
    DataSet(dfi).metadata = ms.metaData;
    DataSet(dfi).timeline = ts.timeline;
    DataSet(dfi).Mission = ms.metaData.operationName;
    
    TheseValves = [];
    for fdi = 1:numel(valveFiles);
        load(fullfile(dataFolders{dfi}, valveFiles{fdi})) ;
        TheseValves = vertcat(TheseValves, fd);
    end
    
    DataSet(dfi).ValveFDs = TheseValves;
    
    ThesePTs = [];
    for fdi = 1:numel(dataFiles);
        load(fullfile(dataFolders{dfi}, dataFiles{fdi}));
        ThesePTs = vertcat(ThesePTs, fd);
    end
    
    DataSet(dfi).PTFDs = ThesePTs;
    
    
    
	MFds={ts.timeline.milestone.FD}';
    sfInd = find(ismember(MFds, eventFD));
    
    interval = parse_duration_string(interval_str);

    % lead_in = 2 * onesec;
    % lead_out = 10 * onesec;
    % 
    % lead_in = -30 * onesec;
    % lead_out = 15 * onemin;
    
    lead_in = interval / 30;
    lead_out = interval;

    for ei = 1:numel(sfInd)
        % Build plot parameter for each found event
        ThisPlot = struct;
        ThisPlot.event = ts.timeline.milestone(sfInd(ei));
        ThisPlot.Title = sprintf('%s : %s %d', DataSet(dfi).Mission, eventFD, ei);
        ThisPlot.legend_str = sprintf('%s %d', DataSet(dfi).Mission, ei);
        ThisPlot.dsi = dfi;
        ThisPlot.te = ThisPlot.event.Time;
        ThisPlot.t0 = ThisPlot.te - lead_in;
        ThisPlot.tf = ThisPlot.te + lead_out;
        
        
        PlotParam = vertcat(PlotParam, ThisPlot);
        
        commandCounter = commandCounter + 1;
    end
    
    fprintf('Found %2d events in %s\n', commandCounter, DataSet(dfi).Mission)
    
end
    
%% Generate Figures and Subplots

if isOverlay
    [axHandles, figHandles, axPairArray] = makeManyMDRTSubplots(1*2, PageTitles, 'newStyle', true , 'mdrtpairs', true);
    axPairArray   = repmat(axPairArray, numel(PlotParam),1);
    % axPairArray = reshape(axHandles, numel(PlotParam),1,2);
    figHandles  = repmat(figHandles, numel(PlotParam),1);
    
else
    [axHandles, figHandles, axPairArray] = makeManyMDRTSubplots(numel(PlotParam)*2, PageTitles, 'newStyle', true , 'mdrtpairs', true);
end

%% Generate Plots
event_collection = [];
for pi = 1:numel(PlotParam)
    
    topAx = axPairArray(pi, 1);
    botAx = axPairArray(pi, 2);

    topFDs = {};
    botFDs = {};
    
    thisPlot = PlotParam(pi);
    thisDataSet = DataSet(thisPlot.dsi);
    
    
    % Muscle Pressure Plots: Top Axes
        
    for p = 1:numel(thisDataSet.PTFDs)
        if isOverlay
            tempFD = thisDataSet.PTFDs(p);
            offset = thisPlot.t0 - min([PlotParam.t0]);
            
            tempFD.ts.Time = tempFD.ts.Time - offset;
            topAx.addFD(tempFD, 'DisplayName', thisPlot.legend_str);
            topFDs = vertcat(topFDs, tempFD.FullString);
        else
            topAx.addFD( thisDataSet.PTFDs(p) );
        end
    end
    

    dynamicDateTicks(topAx.hAx);
    setDateAxes(topAx.hAx, 'XLim', [thisPlot.t0 thisPlot.tf] ) ;
    setDateAxes(topAx.hAx, 'YLim', [0, 100]);

%     
    
    if ~ isOverlay
        topAx.title = thisPlot.Title;
        event_collection = vertcat( event_collection, ...
            MDRTEvent.eventFromMilestone(thisPlot.event, ...
                topAx, [], false, 0) );
    end
    
    % Valve Position Plots: Bottom Axes
    if isValvePlot
        valveStateBar({thisDataSet.ValveFDs.FullString}', botAx.hAx, ...
            'DataFolder', thisDataSet.datafolder)
        
        for s = 1:numel(thisDataSet.ValveFDs)
            botAx.addFD(thisDataSet.ValveFDs(s));
        end
    end

    for p = 1:numel(thisDataSet.ValveFDs)
        if isOverlay
            tempFD = thisDataSet.ValveFDs(p);
            offset = thisPlot.t0 - min([PlotParam.t0]);
            
            tempFD.ts.Time = tempFD.ts.Time - offset;
            botAx.addFD(tempFD, 'DisplayName', thisPlot.legend_str);
            botFDs = vertcat(botFDs, tempFD.FullString);
        else
            botAx.addFD( thisDataSet.ValveFDs(p) );
        end
    end
    
    
    % Set Axes limits
	dynamicDateTicks(botAx.hAx);
    setDateAxes(botAx.hAx, 'XLim', [thisPlot.t0 thisPlot.tf] ) ;
    setDateAxes(botAx.hAx, 'YLim', [-1, 160]);
       
    if ~ isOverlay
        botAx.title = thisPlot.Title;
        event_collection = vertcat( event_collection, ...
        MDRTEvent.eventFromMilestone(thisPlot.event, botAx, [], false, 0) );
    end

    
%                 
    
    linkaxes([axPairArray(pi,:).hAx]', 'x');

    legend(botAx.hAx);
    legend(topAx.hAx);
    
end

% Build Axes Title Strings from FD list. Still some failure modes!
if isOverlay

    top_event = MDRTEvent.eventFromMilestone(thisPlot.event, topAx, [], false, 0);
    bot_event = MDRTEvent.eventFromMilestone(thisPlot.event, botAx, [], false, 0);
    
    top_listen = addlistener(topAx.hAx.XRuler,'MarkedClean',@top_event.AxisLimitsChanged);
    bot_listen = addlistener(botAx.hAx.XRuler,'MarkedClean',@bot_event.AxisLimitsChanged);
    
    
    % addlistener(topAx.hAx,'XLim','PostSet', top_event.AxisLimitsChanged);
    % addlistener(botAx.hAx,'XLim','PostSet', bot_event.AxisLimitsChanged);

    topFDs = unique(topFDs);
    botFDs = unique(botFDs);

    topFinds = {};
    botFinds = {};

    for n = 1:numel(topFDs)
        thisFullString = topFDs{n};
        if max( logical( regexp( thisFullString, '\w-\d{4,5}' ) ))
            reEx = '(?<=\w+-)(\d{4,5})';
            thisFind = regexp( thisFullString, reEx, 'match' );
            topFinds = vertcat(topFinds, thisFind);
        end
    end

    for n = 1:numel(botFDs)
        thisFullString = botFDs{n};
        if max( logical( regexp( thisFullString, '\w-\d{4,5}' ) ))
            reEx = '(?<=\w+-)(\d{4,5})';
            thisFind = regexp( thisFullString, reEx, 'match' );
            botFinds = vertcat(botFinds, thisFind);
        end
    end

    topAx.title = strjoin(topFinds, ', ');
    botAx.title = strjoin(botFinds, ', ');
end

assignin('base', 'axPairArray', axPairArray);

return
%% Save all these damn plots

if isunix
    homeDir = getenv('HOME');
else
    homeDir = getenv('HOMEDIR');
end

path = fullfile(homeDir, 'Downloads');

for f = axPairArray(1).hAx.Parent.Number:axPairArray(end).hAx.Parent.Number
    
    fh = figure(f);
    
    sth = findobj(fh,'Tag','suptitle');
    graphTitle = sth.Children.String;
    
    defaultName = regexprep(graphTitle,'^[!@$^&*~?.|/[]<>\`";#()]','');
    defaultName = regexprep(defaultName, '[:]','-');
    
    
    saveas(fh, fullfile(path, defaultName),'pdf');
    
end



PlotTitleString = sprintf('%s Flight Comparison', eventFD);

end