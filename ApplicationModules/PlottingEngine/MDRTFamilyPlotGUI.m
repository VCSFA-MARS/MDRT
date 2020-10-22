function MDRTFamilyPlotGUI()

config = MDRTConfig.getInstance;

hs.fig = figure('NumberTitle',  'off', ...
            'ToolBar',          'none', ...
            'MenuBar',          'none');
        
        guiSize = [672 387];
        hs.fig.Position = [hs.fig.Position(1:2) guiSize];
        hs.fig.Name = 'Multi-Mission Comparison Plotter';
        hs.fig.NumberTitle = 'off';
        hs.fig.MenuBar = 'none';
        hs.fig.ToolBar = 'none';
        hs.fig.Tag = 'familyPlotGUI';        
        
setappdata(hs.fig, 'isRemoteArchive', false);
setappdata(hs.fig, 'selectedRootPath', config.dataArchivePath);
setappdata(hs.fig, 'indexFilePath', config.dataArchivePath);

%% Configuration to allow running on multiple machines


% Load local archive by default
allowRemote = false;
t = load(fullfile(config.dataArchivePath, 'dataIndex.mat'));
localDataIndex = t.dataIndex;
setappdata(hs.fig, 'localDataIndex', localDataIndex);

remoteDataIndex = [];
if ~isempty(config.remoteArchivePath)
	% Remote data index is configured. Load the index and prepare it to be
	% used.
    allowRemote = true;
    t = load(fullfile(config.pathToConfig, 'dataIndex.mat'));
    remoteDataIndex = t.dataIndex;
end
setappdata(hs.fig, 'remoteDataIndex', remoteDataIndex);



% ht = uitable('Data', availableDataSets, ...
hs.ht = uitable( ...
            'ColumnEdit',       [true, false, false], ...
            'Units',            'normalized', ...
            'Position',         [0.05 0.15 0.5 0.85] );
        
setappdata(gcf, 'hs', hs);
populateDataSetList(localDataIndex)        
        
hs.hb = uicontrol('Style',         'pushbutton', ...
            'Units',            'normalized', ...
            'Position',         [0.05 0.025 0.9, 0.1], ...
            'String',           'Generate Comparison Plot', ...
            'Callback',         {@generatePlot, hs.ht});
        
        
        
%% Archive Selection Controls
    
hs.bg = uibuttongroup('Visible',    'on',...
        'Title',            'Archive Selection', ...
        'Position',         [0.6000 0.8000 0.3750 0.2000], ...
        'SelectionChangedFcn',  @archiveButtonChanged);

hs.r1 = uicontrol(hs.bg,'Style',   'radiobutton', ...
        'String',               'Local Archive', ...
        'Tag',                  'rb_local', ...
        'Units',                'normalized', ...
        'Position',             [0.1000 0.1000 0.4000 0.9000], ...
        'HandleVisibility',     'off');    

if allowRemote    
    hs.r2 = uicontrol(hs.bg,'Style',   'radiobutton', ...
        'String',               'Remote Archive', ...
        'Tag',                  'rb_remote', ...
        'Units',                'normalized', ...
        'Position',             [0.5000 0.1000 0.4000 0.9000], ...
        'HandleVisibility',     'off');        
end
        
end      

function archiveButtonChanged(hobj, event)

    switch event.NewValue.Tag
        case 'rb_local'
            populateDataSetList(getappdata(gcf, 'localDataIndex'));
        case 'rb_remote'
            populateDataSetList(getappdata(gcf, 'remoteDataIndex'));
    end

end

function populateDataSetList(dataIndex)
    hs = getappdata(gcf, 'hs');
    availableDataSets = cell(length(dataIndex), 3);


    for i = 1:length(dataIndex)

        opnames{i, 1} = dataIndex(i).metaData.operationName;
        datapaths{i, 1} = dataIndex(i).pathToData;
        usedata{i,1} = true;

    end

    availableDataSets = { usedata{:}; opnames{:}; datapaths{:} }';

    hs.ht.Data = availableDataSets;
end




function generatePlot(event, obj, varargin)
%% Plot FD configuration and logic


plotConfig = cell2table(varargin{1}.Data);
plotConfig.Properties.VariableNames = {'use', 'name', 'path'};

dataFolders = plotConfig.path(plotConfig.use);




dataFileName1 = '4918 Ghe PT-4918 Press Sensor Mon.mat';
dataFileName2 = '4934 Ghe PT-4934 Press Sensor Mon.mat';

EventString = 'Charge Chilled Helium Bottles';
EventFD = 'GHe-W Charge Cmd';

% Constants
onehr = 1/24;
onemin = onehr/60;
onesec = onemin/60;

fig = makeMDRTPlotFigure;


% fix color matrix based on number of plots!

recentColors =  [   0.0 0.0 0.9;
                    0.5 0.0 0.5;
                    0.9 0.0 0.0 ];
length(dataFolders)
                
for ci = 1:length(dataFolders)
    if ci <= length(recentColors )
        colors(ci, :) = recentColors(ci, :);
    else
        colors(ci, :) = [0.6 0.6 0.6];
    end
end

colors = num2cell(colors(end:-1:1,:) ,2 )

% 
% 
% colors = {      [0.6 0.6 0.6];
%                 [0.6 0.6 0.6];
%                 [0.6 0.6 0.6];
%                 [0.6 0.6 0.6];
%                 [0.6 0.6 0.6];
%                 [0.6 0.6 0.6];
%                 [0.6 0.6 0.6];
%                 [0.9 0.0 0.0];
%                 [0.5 0.0 0.5];
%                 [0.0 0.0 0.9]...
%              };



%	Page setup for landscape US Letter
        graphsInFigure = 1;
        graphsPlotGap = 0.05;
        GraphsPlotMargin = 0.06;
        numberOfSubplots = 2;

        legendFontSize = [8];

subPlotAxes = MDRTSubplot(numberOfSubplots,1,graphsPlotGap, ... 
                                GraphsPlotMargin,GraphsPlotMargin);


% load(timelines{1});
load( fullfile( dataFolders{end}, 'timeline.mat') );


% ismember({timeline.milestone.FD}, 'GHe-W Charge Cmd')
eventInd = find(ismember({timeline.milestone.String}, EventString), 1, 'first');

tf = timeline.milestone(eventInd).Time;

% tf=timeline.t0.time;



htop = [];
hbot = [];


for f = 1:numel(dataFolders)

    try

        load( fullfile( dataFolders{f},  'timeline.mat') );
        load( fullfile( dataFolders{f},   dataFileName1) );
        load( fullfile( dataFolders{f},  'metadata.mat') );

        eventInd = find(ismember({timeline.milestone.String}, EventString), 1, 'first');

        if ~ isempty(eventInd)

            to = timeline.milestone(eventInd).Time;

        %     deltaT = tf - timeline.t0.time;
            deltaT = tf - to;


            disp(sprintf('%s : DeltaT = %1.8f', metaData.operationName, deltaT))


            axes(subPlotAxes(1)); % 4918
                hold on; 
%                 ht = plot(fd.ts.Time + deltaT, fd.ts.Data, ...
%                     'Color',                colors{f}, ...
%                     'DisplayName',          metaData.operationName);
                
                ht = LinePlotReducer(@stairs, ...
                                        fd.ts.Time + deltaT, ...
                                        fd.ts.Data, ...
                                        'Color',                colors{f}, ...
                                        'DisplayName',          metaData.operationName);
                                    fdT =fd;

            axes(subPlotAxes(2)); % 4919
                hold on;
                % load(loxdata{f});
                load( fullfile( dataFolders{f},   dataFileName2) );
%                 hb = plot(fd.ts.Time + deltaT, fd.ts.Data, ...
%                     'Color',                colors{f}, ...
%                     'DisplayName',          metaData.operationName);
                
                hb = LinePlotReducer(@stairs, ...
                                        fd.ts.Time + deltaT, ...
                                        fd.ts.Data, ...
                                        'Color',                colors{f}, ...
                                        'DisplayName',          metaData.operationName);

                htop = vertcat(htop, ht);
                hbot = vertcat(hbot, hb);

        else
            % No matching dude was found - skip that mission
        end

    catch
        % Unable to load metadata - no action
    end

end


linkaxes(subPlotAxes, 'x')
dynamicDateTicks;

titleFormatString = '%s-%s Data for A230 Launches - Charging';

axes(subPlotAxes(1));
title(sprintf(titleFormatString, fdT.Type, fdT.ID));
reviewPlotAllTimelineEvents(timeline)
legend SHOW;

axes(subPlotAxes(2));
title(sprintf(titleFormatString, fd.Type, fd.ID));
reviewPlotAllTimelineEvents(timeline)

legend SHOW;


    end


