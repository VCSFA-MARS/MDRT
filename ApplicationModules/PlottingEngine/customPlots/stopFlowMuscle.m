dataFolder = {
    % '/Users/nick/data/archive/2016-20-17 OA-5 LA1/data/';
    % '/Users/nick/data/archive/2017-11-12 - OA-8 Launch/data';
    % '/Users/nick/data/archive/2018-05-20 - OA-9 Launch/data';
    % '/Users/nick/data/archive/2018-11-16 - NG-10 Launch/data';
    % '/Users/nick/data/archive/2019-04-16 - NG-11 Launch/data';
    % '/Users/nick/data/archive/2019-11-01 - NG-12/data';
    % '/Users/nick/data/archive/2020-02-09_NG-13/data';
    % '/Users/nick/data/archive/2020-02-15 - NG-13 Launch/data';
    % '/Users/nick/data/archive/2020-09-30 - NG-14 Scrub/data';
    % '/Users/nick/data/archive/2020-10-02 - NG-14 Launch/data';
    % '/Users/nick/data/archive/2021-02-19 - NG-15 Launch/data';

    % '/Users/engineer/Imported Data Repository/2020-08-27 - NC-1145_Day_3/data';
    % '/Users/nick/data/imported/2021-01-16 - LO2 Flow Test NC-2135 OP-80/data';
    % '/Users/nick/data/imported/2021-06-09 - NC-1273 - LO2 Flow Test/data';
    % '/Users/nick/data/imported/2021-07-23 - Stop Flow Dry Cycles ITR-2174 OP-10/data';
    '/Users/nick/data/imported/2021-07-29 - Stop Flow Accumulator Timing ITR-2174 OP-40/data';
}

dataFiles = { 
            % '2015 LO2 FM-2015 Coriolis Meter Mon.mat';
            % '2016 LO2 FM-2016 Coriolis Meter Mon.mat';
            '5903 GN2 PT-5903 Press Sensor Mon.mat';
            '5070 GN2 PT-5070 Press Sensor Mon.mat';
            'STE 2031-PT Pressure Sensor Mon.mat';
            };

valveFiles = {'2010 LO2 DCVNO-2010 State.mat';
              '2013 LO2 PCVNO-2013 State.mat';
              '2014 LO2 PCVNO-2014 State.mat';
              '2029 LO2 PCVNO-2029 State.mat';
              '2027 LO2 DCVNO-2027 State.mat';
              '2032 LO2 DCVNO-2032 State.mat';
              };
          
stateFile = { 'LOLS Stop Flow State.mat' };

triggerEventString = 'LOLS Stop Flow Cmd';


%% Script Constant and Setup Defs ---------------------------------------------

PlotTitleString = 'ITR-2174 OP-40 Stop Flow Data';

onehr = 1/24;
onemin = onehr/60;
onesec = onemin/60;

topPlotYLim = [ 0, 275];
topPlotYLim = [ 75 105];


%% Find All Events in data sets -----------------------------------------------

sfIndices = [];
stopEvents = [];

for f = 1:numel(dataFolder)
    thisFolder = dataFolder{f};

    timelineFile=fullfile(thisFolder, 'timeline.mat');
    metaDataFile=fullfile(thisFolder, 'metadata.mat');

    if exist(timelineFile, 'file')
        load(timelineFile);
        fds={timeline.milestone.FD}';
    else
        sprintf('No timeline.mat file found in: %s\n', thisFolder);
        continue
    end


    load(metaDataFile);

    sfIndices = vertcat( find(ismember(fds, triggerEventString)) );

    if ~isempty(sfIndices)
        for s = 1:numel(sfIndices)
                
            thisEvent = struct();
            thisEvent.dataFolder = thisFolder;
            thisEvent.metaData  = metaData;
            thisEvent.timeline  = timeline;
            thisEvent.eventInd  = sfIndices(s);
            thisEvent.opName    = metaData.operationName;
            % thisEvent.allFdInd  = numel(allFDs);

            stopEvents = vertcat(stopEvents, thisEvent);
        end
    end
end


%% Calculate All Stop Flow Times ----------------------------------------------

lastDataSet = [];
plotInfo = [];
allFDs = {};
allResults = [];

for ind = 1:numel(stopEvents)
    thisEvent = stopEvents(ind);

    thisMilestone = thisEvent.timeline.milestone(thisEvent.eventInd);
    t0 = thisMilestone.Time - 2*onesec ;
    tf = thisMilestone.Time + 10*onesec ;
    tc = thisMilestone.Time;
    timeInterval = [t0, tf];
    

    % Load new data if needed

    if ~isequal(thisEvent.dataFolder, lastDataSet)

        fprintf('Loading data from: %s\n', thisEvent.dataFolder)

        thisFDs = [];
        for fn = 1:numel(dataFiles)
            f = dataFiles{fn};
            load(fullfile(thisEvent.dataFolder, f))
            thisFDs = vertcat(thisFDs, fd);
            commandNum = 1;
            % fprintf('Skipping calculation on Event %d, FD %d\n', ind, fn)
        end

        allFDs = vertcat(allFDs, thisFDs);
        
        % Can skip loading valves, they'll be plotted later
        % valveFDs = [];
        % for fn = 1:numel(valveFiles)
        %     f = valveFiles{fn};
        %     load(fullfile(dataFolder, f))
        %     valveFDs = vertcat(valveFDs, fd);
        % end

        lastDataSet = thisEvent.dataFolder;
    end

    % Numerical Analysis


 
    
    fprintf('\nResults for Stop Flow Command %d\n', ind )



    thisResult = struct;
    % thisResult.annotationP1     = P1;
    % thisResult.annotationP2     = P2;
    % thisResult.stopTime         = timeToStopFlow;
    thisResult.timeInterval     = timeInterval;
    thisResult.commandNum       = commandNum; commandNum = commandNum + 1;
    thisResult.opName           = thisEvent.opName;
    thisResult.dataFolder       = thisEvent.dataFolder;
    thisResult.allFdInd         = numel(allFDs);
    thisResult.stopEventInd     = ind;

    allResults = vertcat(allResults, thisResult);

end
    


%% Generate Figures and Subplots ----------------------------------------------

[axHandles, figHandles, axPairArray] = makeManyMDRTSubplots( numel(allResults) * 2, ...
                                                            PlotTitleString ); 


    % PageTitleString = sprintf('%s - %s - Page %d', PlotTitleString, thisOp, figCount);    
    % PageTitleString = sprintf('%s - %s', PlotTitleString, thisOp);
    
    
%% Populate Plots -------------------------------------------------------------
    
for n = 1:numel(allResults)
    this = allResults(n);
    

    % TOP PLOT ---------------------------------
    thisFDs = allFDs{this.allFdInd};

    axes(axPairArray(n,1));
    title(sprintf('%s %s %d', '(Press)', this.opName, this.commandNum))
    
    for fn = 1:numel(thisFDs)
        fd = thisFDs(fn);
        hold on
        stairs(fd.ts.Time, fd.ts.Data, 'displayName', displayNameFromFD(fd));
    end

    dynamicDateTicks; set(datacursormode(gcf), 'UpdateFcn', @dateTipCallback);
    
    xlim(this.timeInterval);
    ylim(topPlotYLim );
    hline(10, '--r');
    reviewPlotAllTimelineEvents(stopEvents(this.stopEventInd).timeline)

    % MDRTannotation('textarrow', this.stopTime, this.annotationP1, this.annotationP2);

    

    % BOTTOM PLOT ------------------------------

    axes(axPairArray(n,2));
    title(sprintf('%s %s %d', '(Valve)', this.opName, this.commandNum))
    valveStateBar(valveFiles, axPairArray(n,2), 'DataFolder', this.dataFolder, 'LabelOffset', -16);
    dynamicDateTicks; set(datacursormode(gcf), 'UpdateFcn', @dateTipCallback);
    xlim(this.timeInterval);
    %     ylim([ -0.1, 2.1] );
    reviewPlotAllTimelineEvents(stopEvents(this.stopEventInd).timeline)

    

end
  
    

    
    % % Display Stop Flow State
    % try
    %     load( fullfile( dataFolder, stateFile{1} ) );
    %     hold on
    %     stairs(fd.ts.Time, fd.ts.Data, 'displayName', 'Stop Flow State');
    % catch
    %     disp(sprintf('\tState FD not found'))
    % end
    




