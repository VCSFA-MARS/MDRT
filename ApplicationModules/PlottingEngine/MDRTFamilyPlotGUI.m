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
setappdata(hs.fig, 'localDataIndex', localDataIndex);   % Retain local data index
setappdata(hs.fig, 'fdMasterList', localDataIndex(end).FDList);     % Set appdata for search bar

remoteDataIndex = [];
if ~isempty(config.remoteArchivePath)
  % Remote data index is configured. Load the index and prepare it to be
  % used.

  allowRemote = true;
  index_file = fullfile(config.pathToConfig, 'dataIndex.mat');
  if ~exist(index_file, 'file')
    allowRemote = false;

  else
    t = load(fullfile(config.pathToConfig, 'dataIndex.mat'));
    remoteDataIndex = t.dataIndex;
    setappdata(hs.fig, 'remoteDataIndex', remoteDataIndex); % Retain remote data index
  end
end


initTimelineData;


% ht = uitable('Data', availableDataSets, ...
hs.ht = uitable( ...
            'ColumnEdit',       [true, false, false], ...
            'Units',            'normalized', ...
            'Position',         [0.05 0.15 0.5 0.85], ...
            'CellEditCallback', @updateEventListbox);
        
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


%% Axes FD Selection Boxes


ebPos = [   0.594 0.65 0.374 0.057 ;
            0.594 0.55 0.374 0.057 ; ];
%             0.594 0.351 0.374 0.057 ;
%             0.594 0.222 0.374 0.057 ; ];
        
for n = 1:size(ebPos, 1)
    handleName = sprintf('searchBox%d', n);
    hs.(handleName) = uicontrol(hs.fig, ...
        'Style',                'edit', ...
        'Tag',                  'searchBox', ...
        'String',               '', ...
        'HorizontalAlignment',  'left',                             ...
        'KeyReleaseFcn',        {@updateSearchResults, 'popup'},    ...
        'Units',                'normalized',                       ...
        'Position',             ebPos(n,:)                ...
        );
        
    HLpos = ebPos(n,:);
    HLpos = HLpos - [0 0.5 0 0];
    HLpos(1,4) = 0.5;
    
    handleNameHL = sprintf('hitList%d', n);
    hs.(handleNameHL) = uicontrol(hs.fig,                           ...
        'Visible',              'off',                              ...
        'Style',                'listbox',                          ...
        'Tag',                  'listSearchResults',                ...
        'KeyPressFcn',          {@navigateSearchHits, hs.(handleName)},...
        'units',                'normalized',                       ...
        'position',             HLpos );        
        
    hs.(handleName).UserData = hs.(handleNameHL);   % Point search bar to popup list
    
end


%% Event Marker Selection List

    hs.EventListbox = uicontrol(hs.fig, ...
        'style',                'listbox', ...
        'units',                'normalized', ...
        'Position',             [0.594 0.25 0.374 0.257]) ;


%% Use T0 Checkbox

    hs.T0Checkbox = uicontrol(hs.fig, ...
        'style',                'checkbox', ... 
        'units',                'normalized', ...
        'position',             [0.594 0.15  0.37 0.057], ...
        'String',               'Synchronize at T0', ...
        'Enable',               'off');

    
    
setappdata(gcf, 'hs', hs);

updateEventListbox;

fixFontSizeInGUI(gcf, config.fontScaleFactor);

end


function updateEventListbox(~, ~)
% Re-populate the event selection box

    apd = getappdata(gcf);

    thisSetIndex = [apd.hs.ht.Data{:,1}]' ;

    if ~any(thisSetIndex)
        % Nothing selected, set list to blank
        apd.hs.EventListbox.String = '';
        apd.hs.T0Checkbox.Enable = 'off';
        return
    end

    if apd.isRemoteArchive
        thisTimelineCollection = apd.RemoteTimelines;
    else
        thisTimelineCollection = apd.LocalTimelines;
    end
    
    

    newList = '';
    for n = numel(thisSetIndex):-1:1
        if thisSetIndex(n)
            try
                newList = {thisTimelineCollection{n}.milestone.String}';
                setappdata(gcf, 'selectedTimeline', thisTimelineCollection{n});
            catch
                setappdata(gcf, 'selectedTimeline', []);
            end
            break
        else
            % Nothinkg
        end
    end

    % Update Event List Contents
    apd.hs.EventListbox.String = newList;
    thisValue = apd.hs.EventListbox.Value;
    
    if thisValue > numel(newList);
        apd.hs.EventListbox.Value = numel(newList);
    elseif ~thisValue
       apd.hs.EventListbox.Value = 1;
    end

    
    % Toggle T0 Checkbox Enable
    try 
        useT0 = thisTimelineCollection{n}.uset0;
    catch
        useT0 = false;
    end

    if useT0
        apd.hs.T0Checkbox.Enable = 'on';
    else
        apd.hs.T0Checkbox.Enable = 'off';
    end

end


function initTimelineData()
    % Loops through timeline files in archive data folders, attempts to
    % load and store in an array. This creates appdata variables called
    % LocalTimelines and RemoteTimelines

    apd = getappdata(gcf);
    
    % LoadLocalTimelines
    localTimelineFiles = fullfile({apd.localDataIndex.pathToData}', 'timeline.mat');
    LocalTimelines = {};
    for f = 1:numel(localTimelineFiles)

        try
            tempTL = load(localTimelineFiles{f} );
            LocalTimelines{f} = tempTL.timeline;
        catch
            % LocalTimelines(f) = []; % Not needed since assigning to index
            thisSet = apd.localDataIndex(f).metaData.operationName;
            fprintf('No timeline data loaded for local data: %d: %s\n', f, thisSet);
        end
    end

    % LoadRemoteTimelines
    RemoteTimelines = {};
    try
        remoteTimelineFiles = fullfile({apd.remoteDataIndex.pathToData}', 'timeline.mat');
        for f = 1:numel(remoteTimelineFiles)
            try
                tempTL = load(remoteTimelineFiles{f} );
                RemoteTimelines{f} = tempTL.timeline;
            catch
                % LocalTimelines(f) = []; % Not needed since assigning to index
                thisSet = apd.remoteDataIndex(f).metaData.operationName;
                fprintf('No timeline data loaded for remote data set %d: %s\n', f, thisSet);
            end
        end
    catch
        warning('No remote index file found. Run mdrt settings to initialize the remote repository')
    end
    
    
    

    setappdata(gcf, 'LocalTimelines',  LocalTimelines);
    setappdata(gcf, 'RemoteTimelines', RemoteTimelines);

end


function archiveButtonChanged(hobj, event)

    switch event.NewValue.Tag
        case 'rb_local'
            setappdata(gcf, 'isRemoteArchive', false);
            populateDataSetList(getappdata(gcf, 'localDataIndex'));
            dataIndex = getappdata(gcf, 'localDataIndex');
            setappdata(gcf, 'fdMasterList', dataIndex(end).FDList);
            
        case 'rb_remote'
            setappdata(gcf, 'isRemoteArchive', true);
            populateDataSetList(getappdata(gcf, 'remoteDataIndex'));
            dataIndex = getappdata(gcf, 'remoteDataIndex');
            setappdata(gcf, 'fdMasterList', dataIndex(end).FDList);
    end
    
    updateEventListbox

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

    apd = getappdata(gcf);

    % Get Use T0 Flag
    useT0 = false;
    if strcmpi(apd.hs.T0Checkbox.Enable, 'on')
        useT0 = apd.hs.T0Checkbox.Value;
    end
    
    % Get selected FD strings
    dataFileNames = {};
    dataFileNames = vertcat(dataFileNames, apd.hs.searchBox1.String);
    dataFileNames = vertcat(dataFileNames, apd.hs.searchBox2.String);
%     dataFileNames = strcat(dataFileNames, '.mat'); % Works on cell array of strings!

    for n = 1:numel(dataFileNames)
        dataFileNames{n} = apd.fdMasterList{ ismember(apd.fdMasterList, dataFileNames{n} ), 2 };
    end

    
    % Get selected event info
    if ~isempty(apd.selectedTimeline) && ~useT0;
        eventInd = apd.hs.EventListbox.Value;
        EventString =   apd.selectedTimeline.milestone(eventInd).String;
        EventFD =       apd.selectedTimeline.milestone(eventInd).FD;
    end
       
    
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

    colors = num2cell(colors(end:-1:1,:) ,2 );


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
        
        % Select the "Final Time" to calculate the time offsets
        if useT0
            tf = timeline.t0.time;
            EventString = 'T0';
        else
            eventInd = find(ismember({timeline.milestone.String}, EventString), 1, 'first');
            tf = timeline.milestone(eventInd).Time;
        end

        for f = 1:numel(dataFolders)
            
            timelineLoaded = false;
            metadataLoaded = false;
            datafileLoaded = false;

            try

                load( fullfile( dataFolders{f},  'timeline.mat') ); timelineLoaded = true;
                load( fullfile( dataFolders{f},  'metadata.mat') ); metadataLoaded = true;

                eventInd = find(ismember({timeline.milestone.String}, EventString), 1, 'first');
                
                if isempty(eventInd) && ~useT0
                    % Use milestone.FD to attempt to recover
                    fprintf('Unable to match event String "%s"\nAttempting to proceed with event FD "%s"\n', ...
                        EventString, EventFD)
                    eventInd = find(ismember( {timeline.milestone.FD}', EventFD), 1, 'first');
                end

                if ~isempty(eventInd) || useT0

                    if useT0
                        to = timeline.t0.time;
                    else
                        to = timeline.milestone(eventInd).Time;
                    end
                    
                    deltaT = tf - to;


                    disp(sprintf('%s : DeltaT = %1.8f', metaData.operationName, deltaT))

                    % Plot each FD in its own axes
                    for a = 1:numel(dataFileNames)
                        
                        datafileLoaded = false;

                        load(fullfile(dataFolders{f}, dataFileNames{a}));  datafileLoaded = true;

                        axes(subPlotAxes(a)); % 4918
                        hold on; 
                            % ht = plot(fd.ts.Time + deltaT, fd.ts.Data, ...
                            %     'Color',                colors{f}, ...
                            %     'DisplayName',          metaData.operationName);
                        if length(fd.ts.Time) > 250000
                            ht = LinePlotReducer(@stairs, ...
                                    fd.ts.Time + deltaT, ...
                                    fd.ts.Data, ...
                                    'Color',                colors{f}, ...
                                    'DisplayName',          metaData.operationName);
                        else
                            ht = stairs( ...
                                    fd.ts.Time + deltaT, ...
                                    fd.ts.Data, ...
                                    'Color',                colors{f}, ...
                                    'DisplayName',          metaData.operationName);
                        end

                    end

                else
                    % No matching dude was found - skip that mission
                end

            catch
                % Unable to load metadata - no action
                errormsg = '';
                if ~timelineLoaded
                    errormsg = strcat(errormsg, 'timeline.mat ');
                end
                if ~datafileLoaded
                    errormsg = strcat(errormsg, 'FD Data file ');
                end
                if ~metadataLoaded
                    errormsg = strcat(errormsg, 'metadata file ');
                end
                
                if ~metadataLoaded
                    fprintf('%s : Skipped. No matching: %s\n', dataFolders{f}, errormsg)
                else
                    fprintf('%s : Skipped. No matching: %s\n', metaData.operationName, errormsg)
                end
                
            end

        end


    linkaxes(subPlotAxes, 'x')
    dynamicDateTicks;

    titleFormatString = '%s-%s Data for A230 Launches - %s';
    
    for a = 1:numel(dataFileNames)

        load( fullfile( dataFolders{end},dataFileNames{a} ), '-mat' );
        axes(subPlotAxes(a));
        title(sprintf(titleFormatString, fd.Type, fd.ID, EventString));
        reviewPlotAllTimelineEvents(timeline)
        legend SHOW;
    end

end


