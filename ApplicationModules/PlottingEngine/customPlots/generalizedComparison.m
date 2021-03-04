missions = {
    '/Users/nick/data/imported/2020-08-28 - NC-1145/data';
    '/Users/nick/data/imported/2020-08-11 - NC-1145/data';
    '/Users/nick/data/imported/2020-02-12 - LO2 Testing/data';
    '/Users/nick/data/archive/2020-02-15 - NG-13 Launch/data';
    '/Users/nick/data/archive/2020-02-09_NG-13/data';
    '/Users/nick/data/archive/2019-11-01 - NG-12/data';
	'/Users/nick/data/archive/2019-04-16 - NG-11 Launch/data';
	'/Users/nick/data/archive/2018-11-16 - NG-10 Launch/data';
	'/Users/nick/data/archive/2018-05-20 - OA-9 Launch/data';
	'/Users/nick/data/archive/2017-11-12 - OA-8 Launch/data';
	'/Users/nick/data/archive/2016-20-17 OA-5 LA1/data';
};


%% FDs to plot
dataFiles = { '2015 LO2 FM-2015 Coriolis Meter Mon.mat';
              '2016 LO2 FM-2016 Coriolis Meter Mon.mat' };
          
pressFiles = {  '2904 LO2 PT-2904 Press Sensor Mon.mat';
                '2906 LO2 PT-2906 Press Sensor Mon.mat';
                '2918 LO2 PT-2918 Press Sensor Mon.mat';
                '2112 LO2 PT-2112 Press Sensor Mon.mat';
                };

valveFiles = {'2010 LO2 DCVNO-2010 State.mat';
              '2013 LO2 PCVNO-2013 State.mat';
              '2014 LO2 PCVNO-2014 State.mat';
              '2029 LO2 PCVNO-2029 State.mat'};
          
          
          
% valveFiles = {	'2010 LO2 DCVNO-2010 State.mat';
%                 '2013 LO2 PCVNO-2013 State.mat';
%                 '2013 LO2 PCVNO-2013 Globe Valve Mon.mat';
%                 '2014 LO2 PCVNO-2014 State.mat';
%                 '2014 LO2 PCVNO-2014 Globe Valve Mon.mat';
%                 '2027 LO2 DCVNO-2027 State.mat';
%                 '2029 LO2 PCVNO-2029 State.mat';
%                 '2029 LO2 PCVNO-2029 Globe Valve Mon.mat';
%                 '2031 LO2 DCVNC-2031 State.mat';
%                 '2032 LO2 DCVNO-2032 State.mat';
%                 '2035 LO2 DCVNO-2035 State.mat';
%                 '2056 LO2 DCVNC-2056 State.mat';
%                 '2059 LO2 PCVNC-2059 State.mat';
%                 '2059 LO2 PCVNC-2059 Globe Valve Mon.mat';
%                 '2067 LO2 DCVNO-2067 State.mat';
%                 '2069 LO2 PCVNC-2069 State.mat';
%                 '2069 LO2 PCVNC-2069 Globe Valve Mon.mat';
%                 '2093 LO2 DCVNC-2093 State.mat';
%                 '2096 LO2 DCVNC-2096 State.mat';
%                 '2097 LO2 DCVNC-2097 State.mat';
%                 '2099 LO2 DCVNO-2099 State.mat';
%                 '2220 LO2 PCVNO-2220 State.mat';
%                 '2220 LO2 PCVNO-2220 Globe Valve Mon.mat';
%                 '2221 LO2 PCVNC-2221 State.mat';
%                 '2221 LO2 PCVNC-2221 Globe Valve Mon.mat';
%             };

%% Plot info
PlotTitleString = 'All Stop Flow Comparisons - Pressure';
searchMilestoneFD='LOLS Stop Flow Cmd';
          
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
sfIndLen = 0;

%% Load Data

data = [];
plan = [];

for m = 1:length(missions)

    load(fullfile(missions{m}, 'timeline.mat'));
    load(fullfile(missions{m}, 'metadata.mat'));
	
    disp(' ')
    disp(metaData.operationName)
    fds={timeline.milestone.FD}';
    sfInd = find(ismember(fds, searchMilestoneFD));
    if sfInd
        disp(datestr( [timeline.milestone(sfInd).Time] ) )
        
        data(m).timeline = timeline;
        data(m).metaData = metaData;
        data(m).sfInd = sfInd;
        
        sfIndLen = sfIndLen + length(sfInd); % might be redundant
        
        for s = 1:length(sfInd)
            thisPlan = [m, sfInd(s)]; % mission index, milestone index
            plan = vertcat(plan, thisPlan);
        end
        
        for d = 1:length(dataFiles)
            load( fullfile( missions{m}, dataFiles{d} ) );
            data(m).dataFiles(d) = fd;
        end
        
        for d = 1:length(valveFiles)
            try
                load( fullfile( missions{m}, valveFiles{d} ) );
                data(m).valveFiles(d) = fd;
            catch
                tempFd = newFD;
                tempFd.FullString = valveFiles{d}(6:end-4);
                tempFd.ts = timeseries;
                tempFd.ts.Name = tempFd.FullString;
                data(m).valveFiles(d) = tempFd;
            end
        end
        
        for d = 1:length(pressFiles)
            try
                load( fullfile( missions{m}, pressFiles{d} ) );
                data(m).pressFiles(d) = fd;
            catch
                tempFd = newFD;
                tempFd.FullString = pressFiles{d}(6:end-4);
                tempFd.ts = timeseries;
                tempFd.ts.Name = tempFd.FullString;
                data(m).pressFiles(d) = tempFd;
            end
        end
        
        
    end

end


disp(sprintf( '\n%d instances of "%s" found\n', length(sfInd), searchMilestoneFD))


%% Generate Subplot Axes and Pages

if size(plan, 1) > spWide
    remainder = size(plan, 1);
    while remainder > 0
        f = makeMDRTPlotFigure;
        disp(sprintf('Creating figure %d', f.Number))
        
        fig = vertcat(fig, f);
        
        if remainder >= spWide
            plotCols = spWide;
        else
            plotCols = remainder;
        end
                
        spa = MDRTSubplot(  spHigh, plotCols, graphsPlotGap, ... 
                            GraphsPlotMargin, GraphsPlotMargin);
                            
        PageTitleString = sprintf('%s - Page %d',PlotTitleString, figCount);
        disp(sprintf('  Generating %s', PageTitleString))
        suptitle(PageTitleString);
        figCount = figCount + 1;
        
        disp(sprintf('  Adding %d subplot axes', length(spa)))
        subPlotAxes = vertcat(subPlotAxes, spa);
        
        axPair = reshape(spa, plotCols, 2);
        axPairs = vertcat(axPairs, axPair);
        
        remainder = remainder - spWide;
        
        subOffset = length(sfInd);
    end

else  
    fig = makeMDRTPlotFigure;
    
    subPlotAxes = MDRTSubplot(spHigh,length(sfInd),graphsPlotGap, ... 
                                GraphsPlotMargin,GraphsPlotMargin);
	suptitle(PlotTitleString);
end



%% Calculate and Plot 

for ind = 1:size(plan, 1)
    
    isThresholdFound = false;
    
    thisMission = plan(ind,1);
    thisMilestoneIndex = plan(ind, 2);
    
    milestone = data(thisMission).timeline.milestone(thisMilestoneIndex);    % timeline.milestone(sfInd(ind));
    t0 = milestone.Time - 2*onesec ;        % time axis t0
    tf = milestone.Time + 10*onesec ;       % time axis tf
    tc = milestone.Time;                    % command time
    timeInterval = [t0, tf];
    
    %% Numerical Analysis
    
    fd1file = fullfile(missions(thisMission), data(thisMission).dataFiles(1).FullString );
    fd2file = fullfile(missions(thisMission), data(thisMission).dataFiles(2).FullString );
    
    f1ts = data(thisMission).dataFiles(1).ts.getsampleusingtime(t0, tf + onesec*2);
    f2ts = data(thisMission).dataFiles(2).ts.getsampleusingtime(t0, tf + onesec*2);
    
    % Find indeces for data matching condition
    f1idx = f1ts.Data < 10;
    f2idx = f2ts.Data < 10;
    
    b1ts = f1ts; b1ts.Data = f1idx;
    b2ts = f2ts; b2ts.Data = f2idx;
    
    % Can't calculate if no matching conditions found on both flowmeters!
    if max(f1idx) && max(f2idx)
        startTime = max(f1ts.Time(1), f2ts.Time(1));
        endTime = min(f1ts.Time(end), f2ts.Time(end));

        newTime = [f1ts.Time; f2ts.Time];
        newTime = sort(newTime);
        newTime = newTime( (newTime >= startTime) & (newTime <= endTime) );

        B1ts=b1ts.resample(newTime);
        B2ts=b2ts.resample(newTime);

        Bts = B1ts; Bts.Data = B1ts.Data & B2ts.Data;

        matches=find(diff(Bts.Data)==1)+1;

        annotationX = [tc(1), newTime(matches(1)) ];
        annotationY = [150, 10 ];

        P1 = [tc(1) + 4*onesec,    150 ];
        P2 = [newTime(matches(1)),  10 ];

        timeToStopFlow = {datestr(newTime(matches) - tc, 'SS.FFF')};

        disp(sprintf('\nResults for Stop Flow test %d : %s', ind, data(thisMission).metaData.operationName))
        for tempInd = 1:length(matches)
            disp(sprintf('\tCondition met in %s seconds', ...
                datestr(newTime(matches(tempInd)) - tc, 'SS.FFF')))
        end
        
        isThresholdFound = true;

    else
        disp(sprintf('\nResults for Stop Flow test %d', ind))
        disp(sprintf('\tNo matching condition found'))
    end
    
	
    %% Valve State Calculation and reporting
    
    for vind = 1:length(data(thisMission).valveFiles)
        vstate = data(thisMission).valveFiles(vind).ts.getsampleusingtime(0, t0);
        try
            s1 = vstate.Data(end);
        catch
            s1 = nan;
        end
        
        vstate = data(thisMission).valveFiles(vind).ts.getsampleusingtime(0, tf);
        try
            s2 = vstate.Data(end);
        catch
            s2 = nan;
        end
        
        disp(sprintf('%s\t%d\t%d',data(thisMission).valveFiles(vind).ts.Name, s1, s2))
    end
    
    

    %% Plot Data
    % Top Plot (Flow Rate)
    axes(axPairs(ind,1));
    
    for fn = 1:numel(dataFiles)
        fd = data(thisMission).dataFiles(fn);
%         fd = allFDs(fn);
        hold on
        stairs(fd.ts.Time, fd.ts.Data, 'displayName', displayNameFromFD(fd));
    end
    
    reviewPlotAllTimelineEvents(data(thisMission).timeline)
%     title(sprintf('%s %d', 'Stop Flow (Flow)', ind))
    title(sprintf('%s %s', data(thisMission).metaData.operationName, 'Stop Flow'), 'interpreter', 'none');
    setDateAxes(axPairs(ind, 1), 'XLim', timeInterval);
    ylim([ 0, 275] );
    hline(10, '--r');
    
    if isThresholdFound
        MDRTannotation('textarrow', timeToStopFlow, P1, P2);
    end
    
    % Bottom Plot (Valve State)
    axes(axPairs(ind,2));
    
    for fn = 1:numel(pressFiles)
        fd = data(thisMission).pressFiles(fn);
%         fd = valveFDs(fn);
        hold on
        stairs(fd.ts.Time, fd.ts.Data, 'displayName', displayNameFromFD(fd));
    end
    
    
    reviewPlotAllTimelineEvents(data(thisMission).timeline)
%     title(sprintf('%s %d', 'Stop Flow (Valve)', ind))
    title(sprintf('%s %s', data(thisMission).metaData.operationName, 'Stop Flow'), 'interpreter', 'none');
    
    linkaxes(axPairs(ind,:),'x');
    dynamicDateTicks(axPairs(ind,:), 'link');
    setDateAxes(axPairs(ind, 2), 'XLim', timeInterval);
    
    ylim([ 0, 200] );
%     ylim([ -0.1, 2.1] );
    
    
    
end


%% Add hline annotations to bottom plot
for q = 1:length(axPairs)
    axes(axPairs(q,2))
    hline(165, '--r', 'RV setpoint');
    hline(165*0.9, '--r', '- 10%');
end


reviewRescaleAllTimelineEvents

