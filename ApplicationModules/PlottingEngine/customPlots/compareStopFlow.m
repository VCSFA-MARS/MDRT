% dataFolder='/Users/nick/data/archive/2016-20-17 OA-5 LA1/data/data'
% dataFolder='/Users/nick/data/archive/2017-11-12 - OA-8 Launch/data'
% dataFolder='/Users/nick/data/archive/2018-05-20 - OA-9 Launch/data'
% dataFolder='/Users/nick/data/archive/2018-11-16 - NG-10 Launch/data'
% dataFolder='/Users/nick/data/archive/2019-04-16 - NG-11 Launch/data'
dataFolder='/Users/nick/data/archive/2019-11-01 - NG-12/data'
% dataFolder='/Users/nick/data/archive/2020-02-09_NG-13/data'
% dataFolder='/Users/nick/data/archive/2020-02-15 - NG-13 Launch/data'
% dataFolder='/Users/nick/data/archive/2020-09-30 - NG-14 Scrub/data'
% dataFolder='/Users/nick/data/archive/2020-10-02 - NG-14 Launch/data'

% dataFolder='/Users/engineer/Imported Data Repository/2020-08-27 - NC-1145_Day_3/data';
% dataFolder='/Users/nick/data/imported/2021-01-16 - LO2 Flow Test NC-2135 OP-80/data';
% dataFolder='/Users/nick/onedrive/Virginia Commercial Space Flight Authority/Pad 0A - Documents/General/90-Combined Systems/Launch Data/MDRT Data/2021-02-19_NG-15_Launch/data';
% dataFolder='/Users/nick/data/imported/2021-06-09 - NC-1273 - LO2 Flow Test/data';

timelineFile=fullfile(dataFolder, 'timeline.mat');
metaDataFile=fullfile(dataFolder, 'metadata.mat');

load(timelineFile);
fds={timeline.milestone.FD}';

load(metaDataFile);
thisOp = metaData.operationName;

sfInd = find(ismember(fds, 'LOLS Stop Flow Cmd'));

PlotTitleString = 'LO2 Stop Flow Flight Comparison';

%% Constants

onehr = 1/24;
onemin = onehr/60;
onesec = onemin/60;

%% Plot Setup

    graphsInFigure = 1;
    graphsPlotGap = 0.05;
    GraphsPlotMargin = 0.06;
    numberOfSubplots = 2;

    legendFontSize = [8];
    spWide = 3;
    spHigh = 2;
        
fig = [];
subPlotAxes = [];
subOffset = [];
axPairs = [];
axPair = [];
figCount = 1;
if length(sfInd) > spWide
    remainder = length(sfInd);
    while remainder > 0
        f = makeMDRTPlotFigure;
        disp(sprintf('Creating figure %d', f.Number))
        
        fig = vertcat(fig, f);
        
        if remainder >= spWide
            plotCols = spWide;
        else
            plotCols = remainder;
        end
                
        spa = MDRTSubplot(spHigh,plotCols,graphsPlotGap, ... 
                                GraphsPlotMargin,GraphsPlotMargin);
                            
        PageTitleString = sprintf('%s - %s - Page %d', PlotTitleString, thisOp, figCount);
        disp(sprintf('Generating %s', PageTitleString))
        suptitle(PageTitleString);
        figCount = figCount + 1;
        
        disp(sprintf('Adding %d subplot axes', length(spa)))
        subPlotAxes = vertcat(subPlotAxes, spa);
        
        axPair = reshape(spa, plotCols, 2);
        axPairs = vertcat(axPairs, axPair);
        
        remainder = remainder - spWide;
        disp(sprintf('Remainder = %d', remainder))
        
%         subOffset = vertcat(subOffset, spWide);
        subOffset = length(sfInd);
    end
%         if mod(length(sfInd),spWide)
%             subOffset(end) = mod(length(sfInd),spWide);
%         end
else
    % NOTE: This code DOES NOT WORK for 2 stop flow events! Must correctly
    % implement the generation of the axPairs array
    fig = makeMDRTPlotFigure;
    
    subPlotAxes = MDRTSubplot(spHigh,length(sfInd),graphsPlotGap, ... 
                                GraphsPlotMargin,GraphsPlotMargin);
    axPairs = reshape(subPlotAxes, length(sfInd), 2);
    
    PageTitleString = sprintf('%s - %s', PlotTitleString, thisOp);
	suptitle(PageTitleString);
end
    
%% FDs to plot
dataFiles = { '2015 LO2 FM-2015 Coriolis Meter Mon.mat';
              '2016 LO2 FM-2016 Coriolis Meter Mon.mat' };

valveFiles = {'2010 LO2 DCVNO-2010 State.mat';
              '2013 LO2 PCVNO-2013 State.mat';
              '2014 LO2 PCVNO-2014 State.mat';
              '2029 LO2 PCVNO-2029 State.mat'};
          
stateFile = { 'LOLS Stop Flow State.mat' };

allFDs = [];
for fn = 1:numel(dataFiles)
    f = dataFiles{fn};
    load(fullfile(dataFolder, f))
    allFDs = vertcat(allFDs, fd);
end

valveFDs = [];
for fn = 1:numel(valveFiles)
    f = valveFiles{fn};
    load(fullfile(dataFolder, f))
    valveFDs = vertcat(valveFDs, fd);
end

%% Plot 

for ind = 1:length(sfInd)
    
    milestone = timeline.milestone(sfInd(ind));
    t0 = milestone.Time - 2*onesec ;
    tf = milestone.Time + 10*onesec ;
    tc = milestone.Time;
    timeInterval = [t0, tf];
    
    % Numerical Analysis
    
    f1ts = allFDs(1).ts.getsampleusingtime(t0, tf + onesec*2); % Search up to 2 seconds after the plot window
    f2ts = allFDs(2).ts.getsampleusingtime(t0, tf + onesec*2);
    
    f1idx = f1ts.Data < 10;
    f2idx = f2ts.Data < 10;
    
    b1ts = f1ts; b1ts.Data = f1idx;
    b2ts = f2ts; b2ts.Data = f2idx;
    
    startTime = max(f1ts.Time(1), f2ts.Time(1));
    endTime = min(f1ts.Time(end), f2ts.Time(end));
    
    newTime = [f1ts.Time; f2ts.Time];
    newTime = sort(newTime);
    newTime = newTime((newTime >= startTime) & (newTime <= endTime));
    
    B1ts=b1ts.resample(newTime);
    B2ts=b2ts.resample(newTime);
    
    Bts = B1ts; Bts.Data = B1ts.Data & B2ts.Data;
    
    matches=find(diff(Bts.Data)==1)+1;
    
    annotationX = [tc(1), newTime(matches(1)) ];
    annotationY = [150, 10 ];
    
    P1 = [tc(1) + 4*onesec,    150 ];
    P2 = [newTime(matches(1)),  10 ];
    
    timeToStopFlow = {datestr(newTime(matches) - tc, 'SS.FFF')};
    
    disp(sprintf('\nResults for Stop Flow test %d', sfInd(ind)))
    for tempInd = 1:length(matches)
        disp(sprintf('\tCondition met in %s seconds', ...
            datestr(newTime(matches(tempInd)) - tc, 'SS.FFF')))
    end
    
    
    
	
    
    
        
    
    % Top Plot (Flow Rate)
    axes(axPairs(ind,1));
    
    for fn = 1:numel(dataFiles)
        fd = allFDs(fn);
        hold on
        stairs(fd.ts.Time, fd.ts.Data, 'displayName', displayNameFromFD(fd));
    end
    
    
    dynamicDateTicks; set(datacursormode(gcf), 'UpdateFcn', @dateTipCallback);
    reviewPlotAllTimelineEvents(timeline)
    title(sprintf('%s %d', 'Stop Flow (Flow)', ind))
    xlim(timeInterval);
    ylim([ 0, 275] );
    hline(10, '--r');

    MDRTannotation('textarrow', timeToStopFlow, P1, P2);
    
    % Bottom Plot (Valve State)
    axes(axPairs(ind,2));
    
    for fn = 1:numel(valveFiles)
        fd = valveFDs(fn);
        hold on
        stairs(fd.ts.Time, fd.ts.Data, 'displayName', displayNameFromFD(fd));
    end
    
    % Display Stop Flow State
    try
        load( fullfile( dataFolder, stateFile{1} ) );
        hold on
        stairs(fd.ts.Time, fd.ts.Data, 'displayName', 'Stop Flow State');
    catch
        disp(sprintf('\tState FD not found'))
    end
    
    dynamicDateTicks; set(datacursormode(gcf), 'UpdateFcn', @dateTipCallback);
    reviewPlotAllTimelineEvents(timeline)
    title(sprintf('%s %d', 'Stop Flow (Valve)', ind))
    xlim(timeInterval);
    ylim([ -0.1, 2.1] );
    
    
    
end

reviewRescaleAllTimelineEvents

