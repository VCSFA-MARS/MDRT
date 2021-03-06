function varargout = plotGraphFromGUI(graph, timeline)
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
% Counts, 10-7-14 - Spaceport Support Services

% Read in the plot info
% TODO: implement error checking?

% temporary hack for non-timeline plots
    useTimeline = true;
    
% temporary hack to handle giant data sets
    useReducePlot = true;
    ENABLE_REDUCE = false;
    
% Flag to supress warning dialogs
    supressWarningDialogs = false;

% Number of points in FD to trigger "reduce plot" routine
    reducePlotThresholdLength = 1500000;
    
    
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
                debugout('Event data file "timeline.mat" was not found. Continuing with events disabled.');
                useTimeline = false;
            end
        end

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






% Setup multi plot loop variables from plot parameters
numberOfGraphs = length(graph);


for graphNumber = 1:numberOfGraphs
% -------------------------------------------------------------------------
% Create a new graph
% -------------------------------------------------------------------------
    numberOfSubplots = length(graph(graphNumber).subplots);
    
% -------------------------------------------------------------------------
% Generate new figure and handle. Set up for priting
% -------------------------------------------------------------------------
    UserData.graph = graph;

    
    % mdrtFigHandle(graphNumber) = makeMDRTPlotFigure(UserData.graph, graphNumber);
    mdrtFigHandle(graphNumber) = MDRTFigure(); % TODO: Pass plot title once implemented!
    
                            
    
    % TODO: Insert code to parse graph title meta tags!
    %     graphName = parseGraphTitle(graph(graphNumber).name);                      
    
    titleStr = parseGraphTitle(graph(graphNumber).name);
    ST_h = suptitle(titleStr);
    ST_h.Interpreter = 'none';

    

    
    for subPlotNumber = 1:numberOfSubplots
        
        % Add subplot with title to MDRTFigure
        if subPlotNumber == 1
            mdrtFigHandle.subplots(1).title = graph(graphNumber).subplots(1);
        else
            mdrtFigHandle.addSubplot(MDRTAxes('title', graph(graphNumber).subplots(subPlotNumber) ));
        end

        % Plot the actual data here
        toPlot = graph(graphNumber).streams(subPlotNumber).toPlot;
     
        
        % -----------------------------------------------------------------
        % Main plotting loop.
        % -----------------------------------------------------------------

            for i = 1:length(toPlot)
                
                mdrtFigHandle.subplots(subPlotNumber).addFDfromFile( ...
                    fullfile(dataPath, [toPlot{i} '.mat']) ...
                );

            end % Data stream plots

            % % Crappy workaround to still have timeline events
            if useTimeline
                for n = 1:numel(timeline.milestone)
                    MDRTEvent( timeline.milestone(n), mdrtFigHandle )
                end
            end

            if useTimeline
                t0 = timeline.t0.time;
                debugout('Found t0 in timeline struct')
            else
                % Should I do something here?
            end

    end % subplot loop

    % Override the data cursor text callback to show time stamp
        dcmObj = datacursormode(gcf);
        set(dcmObj,'UpdateFcn',@dateTipCallback,'Enable','on');
    
    % % Link x axes?
    %     linkaxes(subPlotAxes(:),'x');
        
        
    % % Automatic X axis scaling:
    % % --------------------------------------------------------------------- 
    %     timeLimits = get(subPlotAxes(subPlotNumber),'XLim');
        
    %     if ~graph(graphNumber).time.isStartTimeAuto
    %         switch graph(graphNumber).time.isStartTimeUTC
    %             case true
    %                 % absolute timestamp
    %                 timeLimits(1) = graph(graphNumber).time.startTime.Time;
    %             case false
    %                 % T- timestamp
    %                 % Added if/end block to accomodate non-timeline plots
    %                 if useTimeline
    %                     timeLimits(1) = t0 + graph(graphNumber).time.startTime;
    %                 end
    %         end
    %     end
        
    %     if ~graph(graphNumber).time.isStopTimeAuto
    %         switch graph(graphNumber).time.isStopTimeUTC
    %             case true
    %                 % absolute timestamp
    %                 timeLimits(2) = graph(graphNumber).time.stopTime.Time;
    %                 debugout('Using UTC time!!! Hooray')
    %             case false
    %                 % T- timestamp
    %                 % Added if/end block to accomodate non-timeline plots
    %                 if useTimeline
    %                     timeLimits(2) = t0 + graph(graphNumber).time.stopTime;
    %                 end
    %         end
    %     end
        
    %     % Add a buffer on each side of the x axis scaling
    %     bound = 0.04;
    %     delta = 0.04*(timeLimits(2)-timeLimits(1));
    %     timeLimits = [timeLimits(1)-delta, timeLimits(2)+delta];
        
    %     setDateAxes(subPlotAxes(subPlotNumber),'XLim',timeLimits);
        
    %     if ~graph(graphNumber).time.isStartTimeAuto && ~graph(graphNumber).time.isStopTimeAuto
    %         reviewRescaleAllTimelineEvents(gcf);
    %   
        
    % % Automatic Y axis scaling:
    % % --------------------------------------------------------------------- 
        
    %     % For "discrete" values, bump the Y limits by a small amount to
    %     % ensure the viewer can clearly see the data along the top and
    %     % bottom of the plot.
        
    %     commonStateLimits = [1 2 3];
        
    %     for i = 1:numel(subPlotAxes)
    %         y_lim = subPlotAxes(i).YLim;
    %         y_lower = min(y_lim);
    %         y_upper = max(y_lim);
            
    %         if ismember(y_upper, commonStateLimits) && (y_lower == 0)
    %             y_upper = y_upper + 0.1;
    %             y_lower = y_lower - 0.1;
    %             subPlotAxes(i).YLim = [y_lower, y_upper];
    %         end
    %     end

    % % Fix paper orientation for saving
    %     orient(mdrtFigHandle(graphNumber), 'landscape');

    % % Pause execution to allow user to adjust plot prior to saving?
    
    % % Call a redraw to correct the grid bug
    % refresh(mdrtFigHandle(graphNumber))
    
end % Graph Loop

