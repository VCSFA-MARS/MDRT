function varargout = plotGraphFromGUI(graph, timeline, varargin)
%% plotGraphFromGUI is a function for the MARS data tool GUI
% --> changes by Paige 8/1/16 -- changing secodn input from options structure to timeline structure
% --- > make sure am passing timeline 
% function varargout = plotGraphFromGUI(graph, options)
% function varargout = plotGraphFromGUI(graph, timeline)
%
%   takes a graph structure and an options structure
%
%   runs the MARS data plotting engine for the given graph structure with
%   the passed options structure. if options is left blank, uses default
%   values to be defined leter
%
% Supported Key/Value pairs:
%
%     newValvePlot, valveBarPlot: [true|false|'on'|'off'|'true'|'false']
%         - toggles the use of the bar-style valve plots. When used, all FDs in 
%           a subplot should be valve data
%     reducePlot, useReducePlot: [true|false|'on'|'off'|'true'|'false']
%         - toggles the use of 'reducePlot' for easier browsing of high-frequency
%           data sets
%     disableOldEvents, useMdrtEvents: [true|false|'on'|'off'|'true'|'false']
%         - toggles the use of original event markers or the class-based MDRTEvents
%
% Counts, 10-7-14 - Spaceport Support Services

% Read in the plot info
% TODO: implement error checking?

% temporary hack for non-timeline plots
    useTimeline = true;
    isUseOriginalEventMarkers = true;
    
% temporary hack to handle giant data sets
    isReduceThisPlot = true;
    ENABLE_REDUCE = true; % Default value for argument (passed)
    
% Flag to supress warning dialogs
    supressWarningDialogs = false;

% Number of points in FD to trigger "reduce plot" routine
    reducePlotThresholdLength = 1500000;
    
% Flag to enable/disable the new valve plots (bar style)    
    ENABLE_NEW_VALVE_PLOT = false;
    

if any(size(varargin))
    if numel(varargin) == 1 && iscell(varargin(1))
        varargin = varargin{1};
    end
    for n = 1:2:numel(varargin)
        key = lower(varargin{n});
        val = varargin{n+1};
        
        switch key
            case {'newvalveplot', 'valvebarplot'}
                if islogical(val)
                    ENABLE_NEW_VALVE_PLOT = val;
                elseif ischar(val) || iscellstr(val)
                    if iscellstr(val)
                        val = val{1};
                        switch lower(val)
                            case {'on', 'yes', 'true', 'use'}
                                ENABLE_NEW_VALVE_PLOT = true;
                            case {'off', 'no', 'false', 'not'}
                                ENABLE_NEW_VALVE_PLOT = false;
                        end
                    end
                end
            case {'reduceplot', 'usereduceplot'}
                if islogical(val)
                    ENABLE_REDUCE = val;
                elseif ischar(val) || iscellstr(val)
                    if iscellstr(val)
                        val = val{1};
                        switch lower(val)
                            case {'on', 'yes', 'true', 'use'}
                                ENABLE_REDUCE = true;
                            case {'off', 'no', 'false', 'not'}
                                ENABLE_REDUCE = false;
                        end
                        debugout(sprintf('ENABLE_REDUCE = %s', mat2str(ENABLE_REDUCE)))
                    end
                end
            case {'disableoldevents', 'usemdrtevents'}
                if islogical(val)
                    isUseOriginalEventMarkers = val;
                elseif ischar(val) || iscellstr(val)
                    if iscellstr(val)
                        val = val{1};
                    end
                    switch lower(val)
                        case {'on', 'yes', 'true', 'use'}
                            isUseOriginalEventMarkers = false;
                        case {'off', 'no', 'false', 'not'}
                            isUseOriginalEventMarkers = true;
                    end
                end
                if strcmpi(val, 'usemdrtevents') % Flip value for this key
                    isUseOriginalEventMarkers = ~isUseOriginalEventMarkers;
                end
                
            otherwise
                debugout('Unrecognized key/val pair') 
                debugout(key)
                debugout(val)
        end
    end
end


% Load the project configuration (paths to data, plots and raw data)
% -------------------------------------------------------------------------
% --> want to change to if timeline structure passed with path to data/timeline file, plot timeline. else if call
% --> getConfig to find timeline (check newTimelineStructure function for
% --> fields contained in Timeline Structure
    config = getConfig;

% Loads event data files. If missing, procedes with events disabled.
% -------------------------------------------------------------------------

% [pathstr,name,ext] = fileparts(datapath);

    if useTimeline
%         if isempty(pathstr)
        if exist(fullfile(config.dataFolderPath, 'timeline.mat'),'file')
            load(fullfile(config.dataFolderPath, 'timeline.mat'));
            debugout('using timeline markers')
        else
            if ~supressWarningDialogs
                warndlg('Event data file "timeline.mat" was not found. Continuing with events disabled.');
            end
            useTimeline = false;
        end
%         end
    end


% -------------------------------------------------------------------------
% Constants Defined Here
% -------------------------------------------------------------------------

%	Page setup for landscape US Letter
        graphsInFigure = 1;
        graphsPlotGap = 0.05;
        GraphsPlotMargin = 0.06;
        
        legendFontSize = [8];
     
%	Plot colors and styles for auto-styling data streams
        colors = { [0 0 1], [0 .5 0], [.75 0 .75],...
                   [0 .75 .75], [.68 .46 0]};
        lineStyle = {'-','--',':'};
        isColorOverride = false;

%	Data path (*.mat)
%         dataPath = '/Users/nick/Documents/MATLAB/ORB-D1/Data Files/';
        dataPath = config.dataFolderPath;
        
        eventFile = 'events.mat';

% %   TODO: Implement start/stop time passing
%         timeToPlot = struct('start',735495.296704555, ...
%                             'stop',735496.029342311);
%         t0 = datenum('September 18, 2013 14:58');

if useTimeline
    t0 = timeline.t0.time;
    debugout('Found t0 in timeline struct')
else
    % Should I do something here?
end



% Setup multi plot loop variables from plot parameters
numberOfGraphs = length(graph);


for graphNumber = 1:numberOfGraphs
% -------------------------------------------------------------------------
% Create a new graph
% -------------------------------------------------------------------------
    numberOfSubplots = length(graph(graphNumber).subplots);
    numberOfSubplots
    events = [];
% -------------------------------------------------------------------------
% Generate new figure and handle. Set up for priting
% -------------------------------------------------------------------------
    UserData.graph = graph;
    
    % Original struct-based figure/plot generation code
    figureHandle(graphNumber) = makeMDRTPlotFigure(UserData.graph, graphNumber);    
    subPlotAxes = MDRTSubplot(numberOfSubplots,1,graphsPlotGap, ... 
                                GraphsPlotMargin,GraphsPlotMargin);

    % New MDRT Class based figure/plot generation code:                                
                            
	% [subPlotAxes, thisFig] = makeManyMDRTSubplots(graph(graphNumber).subplots, ...
    %                             graph(graphNumber).name, ...
    %                             'newStyle',     false, ...
    %                             'plotsHigh',    numberOfSubplots, ...
    %                             'groupAxesBy',  numberOfSubplots, ...
    %                             'graphStruct',  graph, ...
    %                             'graphNumber',  graphNumber);
                            
    % figureHandle(graphNumber) = thisFig;
    
                            
    % TODO: Insert code to parse graph title meta tags!
    %     graphName = parseGraphTitle(graph(graphNumber).name);                      
    
    titleStr = parseGraphTitle(graph(graphNumber).name);
    ST_h = suptitle(titleStr);
    ST_h.Interpreter = 'none';

    
    % Reset axes label variables
    axesTypeCell = [];
    isNormalSubplot = [];
    
    for subPlotNumber = 1:numberOfSubplots
        debugout(sprintf('Subplot %d of %d', subPlotNumber, numberOfSubplots))
        iv = [];
        axTimeLims = [];
        
        isNormalSubplot(subPlotNumber) = true;
        
        % Plot the actual data here
        toPlot = graph(graphNumber).streams(subPlotNumber).toPlot;
        
        % Load data sets to be plotted into array of structs
        % --> CHANGE TO CHECK FOR FULLFILE PATH <------------
        try
            for i = 1:length(toPlot)
                s(i)  = load([dataPath toPlot{i} '.mat'],'fd');
                iv(i) = isFDValve(s(i).fd);
            end
            
            % Build the list of variable types for axes label generation
            for i = 1:length(s)
                axesTypeCell = [axesTypeCell, {s(i).fd.Type}];
            end
        
        catch
            debugout('We caught an exception loading FD files. Skipping subplot')
            continue
        end
        
        if all(iv) && ENABLE_NEW_VALVE_PLOT
            % All streams are valve data - use cool valve plot
            debugout('Detected all valves in subplot: calling valveStateBar')
            debugout(toPlot')
            if verLessThan('matlab','9.2.0') % before R2017a
                valveStateBar(toPlot, subPlotAxes(subPlotNumber));
            else
                valveStateBar(toPlot, subPlotAxes(subPlotNumber), ...
                              'LabelOffset',    -65 );
            end
            
            isNormalSubplot(subPlotNumber) = false;
        else
            axTimeLims = populateSubplot;
        end

        % Preallocate plot handles
%         hDataPlot = gobjects(numberOfGraphs, max(size(toPlot)));
%         hDataPlot = gobjects(numberOfGraphs);
        
        



        % REMEMBER FOR LATER:
        % if(any(strcmp('isValve',fieldnames(fd))));disp('isValve!!!');end




        % -------------------------------------------------------------
        % Apply styling to the subplot.
        % -------------------------------------------------------------


            debugout(subPlotAxes(subPlotNumber).HitTest)    

            % Set subplot title and draw T:0
                title(subPlotAxes(subPlotNumber),graph(graphNumber).subplots(subPlotNumber));

            % Set(subPlotAxes(1), 'fontSize', [6]);

            % Plot sequencer events first, underneath data streams
                    % Plot time markers for major LFF events
                        % Loop through listed events
                        axes(subPlotAxes(subPlotNumber));

                        % Crappy workaround to still have timeline events
                        
                        if useTimeline
%                             for t = 1:numel(timeline.milestone)
%                                 events = vertcat(events,  MDRTEvent(timeline.milestone(t), gca));
%                             end
%                             setappdata(thisFig, 'MDRTEvents', events);

                            if isUseOriginalEventMarkers
                                reviewPlotAllTimelineEvents(timeline);
                            end
                        end


            % ylabel(subPlotAxes(subPlotNumber),'Temperature (^oF)')
                ylabel(subPlotAxes(subPlotNumber), axesLabelStringFromSensorType(axesTypeCell));


            % Display major and minor grids
                set(subPlotAxes(subPlotNumber),'XGrid','on','XMinorGrid','on','XMinorTick','on');
                set(subPlotAxes(subPlotNumber),'YGrid','on','YMinorGrid','on','YMinorTick','on');

            % dynamicDateTicks
                dynamicDateTicks(subPlotAxes, 'linked') 
                
                if axTimeLims
                    subPlotAxes(subPlotNumber).XLim = axTimeLims;
                end

%                 xLim = get(subPlotAxes(subPlotNumber), 'XLim');
% %                     setDateAxes(subPlotAxes(subPlotNumber), 'XLim', [timeToPlot.start timeToPlot.stop]);
%                  setDateAxes(subPlotAxes(subPlotNumber), 'XLim', xLim);


            % Override the data cursor text callback to show time stamp
                dcmObj = datacursormode(gcf);
                set(dcmObj,'UpdateFcn',@dateTipCallback,'Enable','on');

            % Style the legend to use smaller font size
            if isNormalSubplot(subPlotNumber)
                subPlotLegend(subPlotNumber) = legend(subPlotAxes(subPlotNumber), 'show');
                set(subPlotLegend(subPlotNumber),'FontSize',legendFontSize);
                set(subPlotLegend(subPlotNumber), 'Interpreter', 'none');
            else
                debugout('Skipping legend for special subplot')
            end

            % Reset any subplot specific loop variables
                axesTypeCell = [];
                clear s

                if subPlotNumber == numberOfSubplots
                    % on last subplot, so add date string
%                         tlabel('WhichAxes', 'last')
                    debugout('last tlabel call')

                else
%                         tlabel('Reference', 'none')
                    debugout('regular tlabel call')

                end
                    
    end % subplot loop
    
%     This seems to break auto x-axis limits in 2017a
    % Link x axes?
        linkaxes(subPlotAxes(:),'x');
        
        
    % Automatic X axis scaling:
    % --------------------------------------------------------------------- 
        timeLimits = get(subPlotAxes(subPlotNumber),'XLim');
        
        if ~graph(graphNumber).time.isStartTimeAuto
            switch graph(graphNumber).time.isStartTimeUTC
                case true
                    % absolute timestamp
                    timeLimits(1) = graph(graphNumber).time.startTime.Time;
                case false
                    % T- timestamp
                    % Added if/end block to accomodate non-timeline plots
                    if useTimeline
                        timeLimits(1) = t0 + graph(graphNumber).time.startTime;
                    end
            end
        end
        
        if ~graph(graphNumber).time.isStopTimeAuto
            switch graph(graphNumber).time.isStopTimeUTC
                case true
                    % absolute timestamp
                    timeLimits(2) = graph(graphNumber).time.stopTime.Time;
                    debugout('Using UTC time!!! Hooray')
                case false
                    % T- timestamp
                    % Added if/end block to accomodate non-timeline plots
                    if useTimeline
                        timeLimits(2) = t0 + graph(graphNumber).time.stopTime;
                    end
            end
        end
        
        % Add a buffer on each side of the x axis scaling
        bound = 0.04;
        delta = 0.04*(timeLimits(2)-timeLimits(1));
        timeLimits = [timeLimits(1)-delta, timeLimits(2)+delta];
        
        setDateAxes(subPlotAxes(subPlotNumber),'XLim',timeLimits);
        
        if ~graph(graphNumber).time.isStartTimeAuto && ~graph(graphNumber).time.isStopTimeAuto
            reviewRescaleAllTimelineEvents(gcf);
        end
        
    % Automatic Y axis scaling:
    % --------------------------------------------------------------------- 
        
        % For "discrete" values, bump the Y limits by a small amount to
        % ensure the viewer can clearly see the data along the top and
        % bottom of the plot.
        
        commonStateLimits = [1 2 3 100];
        
        for i = 1:numel(subPlotAxes)
            if isNormalSubplot(i)
                y_lim = subPlotAxes(i).YLim;
                y_lower = min(y_lim);
                y_upper = max(y_lim);

                if ismember(y_upper, commonStateLimits) && (y_lower == 0)
                    y_upper = y_upper + 0.1;
                    y_lower = y_lower - 0.1;
                    subPlotAxes(i).YLim = [y_lower, y_upper];
                end
            end
        end

    % Fix paper orientation for saving
%         orient(figureHandle(graphNumber), 'landscape');

    % Pause execution to allow user to adjust plot prior to saving?
    
    % Call a redraw to correct the grid bug
    refresh(figureHandle(graphNumber))
    
end % Graph Loop


    function xlims = populateSubplot()
        
        xlims = [100000000000 1];

%{
  +-----------------------------------------------------------------------------+
  |                             Main plotting loop.                             |
  +-----------------------------------------------------------------------------+
%}

    % Initialize style loop variables
        iStyle = 1;
        iColor = 1;
        lineWeight = 0.5;

        hold off;
        axes(subPlotAxes(subPlotNumber));
        
        for i = 1:length(toPlot)
            
            xlims = vertcat(xlims, [min(s(i).fd.ts.Time), max(s(i).fd.ts.Time)]);

            % Set useReducePlot based on FD length
            if (length(s(i).fd.ts.Time) > reducePlotThresholdLength) && ENABLE_REDUCE
                isReduceThisPlot = true;
            else
                isReduceThisPlot = false;
            end
            debugout(sprintf('isReduceThisPlot=<strong>%s</strong>', ... 
                                mat2str(isReduceThisPlot) ) )
            
            
            debugStr = sprintf('%s to %s : %s', ...
                            datestr(s(i).fd.ts.Time(1)), ...
                            datestr(s(i).fd.ts.Time(end)), ...
                            displayNameFromFD(s(i).fd) );
            % debugout(debugStr)
            


            % Check for set point/command - plot as red stairs
            if(strfind(s(i).fd.FullString, 'Param' ))

                hDataPlot(graphNumber,subPlotNumber,i) = stairs(s(i).fd.ts.Time, ...
                                      s(i).fd.ts.Data, ...
                                      'displayname', ...
                                      displayNameFromFD(s(i).fd));
                isColorOverride = true;
                overrideColor = [1 0 0];
            else

                if isReduceThisPlot

                    hSmallPlt = stairs( ...
                                    s(i).fd.ts.Time([1, end]), ...
                                    s(i).fd.ts.Data([1, end]), ...
                                    'displayname', ...
                                    displayNameFromFD(s(i).fd));
                    
                    hDataPlot(graphNumber,subPlotNumber,i) = LinePlotReducer(hSmallPlt, ...
                                    s(i).fd.ts.Time, ...
                                    s(i).fd.ts.Data);
                                
%                     hThisPlot = LinePlotReducer(@stairs, ...
%                                     s(i).fd.ts.Time, ...
%                                     s(i).fd.ts.Data, ...
%                                     'displayname', ...
%                                     displayNameFromFD(s(i).fd));
%                                 
%                     hDataPlot(graphNumber,subPlotNumber,i) = hThisPlot.h_plot;

                else
                    hDataPlot(graphNumber,subPlotNumber,i) = stairs(s(i).fd.ts.Time, s(i).fd.ts.Data , ...
                                    'displayname', ...
                                    displayNameFromFD(s(i).fd));
                end
            end

            % Apply the appropriate color
            if (isColorOverride)
                thisColor = overrideColor;

            else
                thisColor = colors{iColor};

            end

            switch class(hDataPlot(graphNumber,subPlotNumber,i))
                case 'LinePlotReducer'
                    thisPlotHandle = hDataPlot(graphNumber,subPlotNumber,i).h_plot;
                otherwise
                    thisPlotHandle = hDataPlot(graphNumber,subPlotNumber,i);
            end

            set(thisPlotHandle,'Color',thisColor)
            set(thisPlotHandle,'LineStyle',lineStyle{iStyle});
            set(thisPlotHandle,'LineWidth',lineWeight);
            hold on;

            % Increment Styles as needed
            if ~isColorOverride
                iColor = iColor + 1;
                if (iColor > length(colors))
                    iStyle = iStyle + 1;
                    iColor = 1;
                    if (iStyle > length(lineStyle))
                        iStyle = 1;
                        iColor = 1;
                    end
                    % Option to adjust line weight for d
                    switch lineStyle{iStyle}
                        case ':'
                            lineWeight = 0.5;
                        otherwise
                            lineWeight = 0.5;
                    end
                end
            end

            isColorOverride = false;

        end % Data stream plots
        
        xlims = [ min(xlims(:,1)), max(xlims(:,2)) ];
        
    end

    % Hack to fix subplot axes Tag strings
    [subPlotAxes.Tag] = deal('MDRTAxes');


end