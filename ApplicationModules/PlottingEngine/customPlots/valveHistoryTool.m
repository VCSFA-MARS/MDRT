missions = {
    '/Users/nick/data/archive/2021-02-19 - NG-15 Launch/data';
    '/Users/nick/data/archive/2020-10-02 - NG-14 Launch/data';
    '/Users/nick/data/archive/2020-09-30 - NG-14 Scrub/data';
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

pressSensNum = '5070';

%% Constants

onehr = 1/24;
onemin = onehr/60;
onesec = onemin/60;


%% Valve Selection

prompt={'Enter the valve number (for DCVN0-2010, enter "2010")' };
name='Valve Selection';
defaultanswer={'2010'};
valveNum = inputdlg(prompt,name,1,defaultanswer);

if isempty(valveNum)
    return
end



%% Quick search for files to get valve name

for n = 1:numel(missions)
    files = dir(fullfile(missions{n}, ['*' valveNum{1} '*']));
    if numel(files)
        [s,f,~] = regexpi(files(1).name, '(DCVNC|DCVNO|PCVNC|PCVNO|RV|MV|BV)-\d*');
        valveName = files(1).name;
        valveName = valveName(s:f);
        continue
    end
    
    % Default garbage, if no match is found
    valveName = ['Valve-', 'valveNum{1}'];

end

PlotTitleString = sprintf('%s : Valve Performance Comparison', valveName);


%% Check Valve Type
%   TODO: Add a prompt for user selection if can't be determined from
%   previous

[s,~,~] = regexpi(valveName, '(PCVNC|PCVNO|RV-0003|RV-0004)-\d*');

if isempty(s)
    isDiscrete = true;
else
    isDiscrete = false;
end




%% Grab all available data
%
%   load any data and stuff into the data struct.
%   Each data struct in the array contains an fd, path, and name.
%   data(1).cmd.ts = the command fd's ts for the first available data set

cmdFiles    = cell(numel(missions),1);
stateFiles  = cell(numel(missions),1);
pressFiles  = cell(numel(missions),1);

data = struct();
indToClear = [];


for n = 1:numel(missions)
    
    files = dir(fullfile(missions{n}, ['*' valveNum{1} '*']));
    useAnd = false;
    tracker = 0;
    
    tcmd   = [];
    tstate = [];
    tpress = [];
    
    
    try
        
        cmdInd   = find(~cellfun('isempty', strfind({files.name}, 'Param')));
        stateInd = find(~cellfun('isempty', strfind({files.name}, 'State')));

        tcmd    = load(fullfile(missions{n}, files(cmdInd).name), 'fd');
        tstate  = load(fullfile(missions{n}, files(stateInd).name), 'fd');
        
        pFiles = dir(fullfile(missions{n}, ['*' pressSensNum '*']));
        tpress = load(fullfile(missions{n}, pFiles.name), 'fd');
        
        tMeta = load(fullfile(missions{n}, 'metadata.mat'));
    
    catch % One of the files can't be found or loaded
        
        indToClear = vertcat(indToClear, n);
        missName = fileparts(missions{n});
        fmtStr = '%s ';
        
        if isempty(cmdInd)
            fmtStr = [fmtStr, 'cmd '];
            useAnd = true;
        end
        
        if isempty(stateInd)
            if useAnd
                fmtStr = [fmtStr, 'and '];
            end
            fmtStr = [fmtStr, 'state '];
            useAnd = true;

        end
        
        if isempty(pFiles)
            if useAnd
                fmtStr = [fmtStr, 'and '];
            end
            fmtStr = [fmtStr, 'press sensor '];
        end
            
        fmtStr = [fmtStr, 'missing in %s \n'];
        fprintf(fmtStr, valveName, missName)
        
        
        data(n).cmd = [];
        data(n).state = [];
        data(n).press = [];
        data(n).metadata = [];
        data(n).path = [];
        
        continue
    end
    
    data(n).cmd = tcmd.fd;
    data(n).state = tstate.fd;
    data(n).press = tpress.fd;
    data(n).metadata = tMeta.metaData;
    data(n).path = missions{n};
    
end

data(indToClear) = [];

          


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

plan = [];

for m = 1:length(data)
	
    disp(' ')
    disp(data(m).metadata.operationName)
    
    % For Discrete Valves, find all command changes
    cmdInd = find(diff(data(m).cmd.ts.Data)) + 1; % +1 needed due to diff offset.
    
    for n = 1:numel(cmdInd)
        % Step through each command change and build a "plan"
        % plan fmt: [data() index, command fd.ts.Data index, cmd datenum]
        cmdDatenum = data(m).cmd.ts.Time(cmdInd(n));
        thisPlan = [m, cmdInd, cmdDatenum ];
        plan = vertcat(plan, thisPlan);
        fprintf('\tFound command change at %s\n', datestr(cmdDatenum) )
    end
    
    keyboard
    
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

