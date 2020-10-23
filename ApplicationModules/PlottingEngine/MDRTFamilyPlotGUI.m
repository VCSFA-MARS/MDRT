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

% Constants
    onehr = 1/24;
    onemin = onehr/60;
    onesec = onemin/60;
    
    
plotConfig = cell2table(varargin{1}.Data);
plotConfig.Properties.VariableNames = {'use', 'name', 'path'};

dataFolders = plotConfig.path(plotConfig.use);


dataFileNames = {   '1016 RP1 FM-1016 Coriolis Meter Mon.mat' ;
                    '1017 RP1 FM-1017 Turbine Meter Mon.mat'  ;
                    '1014 RP1 PCVNC-1014 Globe Valve Mon.mat' ;
                    '1015 RP1 PCVNC-1015 Globe Valve Mon.mat'};

EventString = 'FGSE FLS Low Flow Fill Command';
EventFD = 'FLS LLFF Cmd';



% fix color matrix based on number of plots!

    recentColors =  [   0.0 0.0 0.9;
                        0.5 0.0 0.5;
                        0.0 0.5 0.0; ];
%                         0.9 0.0 0.0 ];
    length(dataFolders)

    for ci = 1:length(dataFolders)
        if ci <= length(recentColors )
            colors(ci, :) = recentColors(ci, :);
        else
            colors(ci, :) = [0.6 0.6 0.6];
        end
    end

    colors = num2cell(colors(end:-1:1,:) ,2 )

    
fig = makeMDRTPlotFigure;
%	Page setup for landscape US Letter
    graphsInFigure = 1;
    graphsPlotGap = 0.05;
    GraphsPlotMargin = 0.06;
    numberOfSubplots = numel(dataFileNames);

    legendFontSize = [8];

subPlotAxes = MDRTSubplot(  numberOfSubplots, ...
                            1,                      graphsPlotGap, ... 
                            GraphsPlotMargin,       GraphsPlotMargin);


                        
%% Get final sync time - from latest mission                        

    load( fullfile( dataFolders{end}, 'timeline.mat') );
    eventInd = find(ismember({timeline.milestone.String}, EventString), 1, 'first');

    tf = timeline.milestone(eventInd).Time;
    % If using t0 instead of a milestone you need different code!
    % tf=timeline.t0.time;


    for f = 1:numel(dataFolders)

        try

            load( fullfile( dataFolders{f},  'timeline.mat') );
            load( fullfile( dataFolders{f},  'metadata.mat') );

            eventInd = find(ismember({timeline.milestone.String}, EventString), 1, 'first');
            
            if ~ isempty(eventInd)

                to = timeline.milestone(eventInd).Time;

            %     deltaT = tf - timeline.t0.time;
                deltaT = tf - to;


                disp(sprintf('%s : DeltaT = %1.8f', metaData.operationName, deltaT))

                % Plot each FD in its own axes
                for a = 1:numel(dataFileNames)

                    load(fullfile(dataFolders{f}, dataFileNames{a}));

                    axes(subPlotAxes(a)); % 4918
                    hold on; 
                        % ht = plot(fd.ts.Time + deltaT, fd.ts.Data, ...
                        %     'Color',                colors{f}, ...
                        %     'DisplayName',          metaData.operationName);

                    ht = LinePlotReducer(@stairs, ...
                            fd.ts.Time + deltaT, ...
                            fd.ts.Data, ...
                            'Color',                colors{f}, ...
                            'DisplayName',          metaData.operationName);

                end

            else
                % No matching dude was found - skip that mission
            end

        catch
            % Unable to load metadata - no action
        end

    end


linkaxes(subPlotAxes, 'x')
dynamicDateTicks;

titleFormatString = '%s-%s Data for A230 Launches - %s';

for a = 1:numel(dataFileNames)

    load(fullfile(dataFolders{f}, dataFileNames{a}));
    axes(subPlotAxes(a));
    title(sprintf(titleFormatString, fd.Type, fd.ID, EventString));
    reviewPlotAllTimelineEvents(timeline)
    legend SHOW;
end



    end


