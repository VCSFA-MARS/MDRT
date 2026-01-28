%% valveHistoryTool - plots each actuation of a selected valve for a given 
% data set and creates a table of all relevant timing data for export to
% excel or csv

missions = {
%     '/Users/nick/data/archive/2021-08-09 - NG-16_Launch/data';
%     '/Users/nick/data/imported/2021-07-29 - Stop Flow Accumulator Timing ITR-2174 OP-40/data';   
%     '/Users/nick/data/imported/2021-07-29 - 2010 Muscle Supply Test ITR-2174 OP-20/data';    
%     '/Users/nick/data/imported/2021-07-23 - Stop Flow Dry Cycles ITR-2174 OP-10/data';
%     '/Users/nick/data/imported/2021-06-09 - NC-1273 - LO2 Flow Test/data';
%     '/Users/nick/data/imported/2021-02-23 - All 2031 Post NG-15/data';
%     '/Users/nick/data/archive/2021-02-19 - NG-15 Launch/data';
%     '/Users/nick/data/archive/2020-10-02 - NG-14 Launch/data';
%     '/Users/nick/data/archive/2020-09-30 - NG-14 Scrub/data';
%     '/Users/nick/data/imported/2020-08-28 - NC-1145/data';
%     '/Users/nick/data/imported/2020-08-11 - NC-1145/data';
%     '/Users/nick/data/imported/2020-02-12 - LO2 Testing/data';
%     '/Users/nick/data/archive/2020-02-15 - NG-13 Launch/data';
%     '/Users/nick/data/archive/2020-02-09_NG-13/data';
%     '/Users/nick/data/archive/2019-11-01 - NG-12/data';
% 	'/Users/nick/data/archive/2019-04-16 - NG-11 Launch/data';
% 	'/Users/nick/data/archive/2018-11-16 - NG-10 Launch/data';
% 	'/Users/nick/data/archive/2018-05-20 - OA-9 Launch/data';
% 	'/Users/nick/data/archive/2017-11-12 - OA-8 Launch/data';
% 	'/Users/nick/data/archive/2016-20-17 OA-5 LA1/data';
    '/Users/nick/data/imported/2021-12-06 - LO2 Flow Test LOLS-16/data'

};

shouldPrintMessages = true;
shouldPlotRVLimits  = false;
skipFigures = false;

pressSensNum = '5070';
steSens = 'STE TC06';
steSens = '';
timelineEventFd = 'LOLS Chilldown Phase1 Cmd';


%% Calculated Parameters

skipSTE = isempty(steSens);
skipPTs = isempty(pressSensNum);



%% Constants

oneHr = 1/24;
oneMin = oneHr/60;
oneSec = oneMin/60;

plotWindow = [-5*oneSec, 15*oneSec];
dataWindow = [-11*oneMin, 11*oneMin];
pressYLim  = [ 70 110 ];


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

[s,~,~] = regexp(valveName, '(PCVNC|PCVNO|RV-0003|RV-0004)-\d*');

if isempty(s)
    isDiscrete = true;
    valveType = 'Discrete';
else
    isDiscrete = false;
    valveType = 'Proportional';
end


[s,~,~] = regexp(valveName, '(PCVNC|DCVNC|RV-0001|BV)');

if isempty(s)
    isNO = true;
    normalPos = 'OPEN';
else
    isNO = false;
    normalPos = 'CLOSED';
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
        
        try
            pFiles = dir(fullfile(missions{n}, ['*' pressSensNum '*']));
            tpress = load(fullfile(missions{n}, pFiles.name), 'fd');
            disp('Found pressure sensor')
        catch
            skipPTs = true;
        end
        
        try
            stFiles = dir(fullfile(missions{n}, ['*' steSens '*']));
            stData = load(fullfile(missions{n}, stFiles.name), 'fd');
        catch
            skipSTE = true;
        end
        
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
    
    if ~skipPTs;
        data(n).press = tpress.fd;
    end
    
    data(n).metadata = tMeta.metaData;
    data(n).path = missions{n};
    
    data(n).cmd.ts      = removeDuplicateTimeseriesPoints( tcmd.fd.ts );
    data(n).state.ts    = removeDuplicateTimeseriesPoints( tstate.fd.ts );
    
    if ~skipPTs
        data(n).press.ts    = removeDuplicateTimeseriesPoints( tpress.fd.ts );
    end
    
    
    % Event Time for later calculations
    % ---------------------------------------------------------------------
    try
        tTimeline = load(fullfile(missions{n}, 'timeline.mat'), 'timeline');
        milestones = tTimeline.timeline.milestone;

        eventInd = find(not(cellfun('isempty', ...
            strfind({milestones.FD}, timelineEventFd) )));
                
        data(n).eventFd     = milestones(eventInd).FD;
        data(n).eventTime   = milestones(eventInd).Time;
        
        
    catch
        
        data(n).eventFd     = [];
        data(n).eventTime   = [];
        
    end
    
    
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
axPairArray = [];
axPair = [];
figCount = 1;          
sfIndLen = 0;

%% Generate Plan
%   Step through each command and create an array of items to analyse and
%   plot. It's the "plan"

plan = [];

for m = 1:length(data)
	
    disp(' ')
    disp(data(m).metadata.operationName)
    
    % For Discrete Valves, find all command changes
    cmdChg = diff(data(m).cmd.ts.Data);
    cmdInd = find(cmdChg) + 1; % +1 needed due to diff offset.
    
    for n = 1:numel(cmdInd)
        % Step through each command change and build a "plan"
        % plan fmt: [data() index, command fd.ts.Data index, cmd datenum, cmdChange,    ]
        cmdDatenum = data(m).cmd.ts.Time(cmdInd(n));
        thisPlan = [m, cmdInd(n), cmdDatenum, cmdChg(cmdInd(n) -1) ];
        plan = vertcat(plan, thisPlan);
        if shouldPrintMessages; fprintf('\tFound command change at %s\n', datestr(cmdDatenum) ); end
        
    end
    

end


fprintf( '\n%d instances of "%s" commands found\n', size(plan,1), valveName )


%% Generate Subplot Axes and Pages

if ~skipFigures

    [axHandles, figHandles, axPairArray] = makeManyMDRTSubplots(size(plan, 1)*2, PlotTitleString);

end



%% Calculate and Plot 

results = struct('firstmvt', [],        'motionstop', [], ...
                 'timetofirstmvt', [],  'transitiontime', [], ...  
                 'totaltime', [],       'timeFromEvent', [], ...
                 'operation', [],       'commandnum', [], ...
                 'command', [],         'normalpos', [], ...
                 'commandtime', [],     'commandtype', []);
             
             
lastDataIndex = 0;
cmdCount = 0;

for ind = 1:size(plan, 1)
    
    isThresholdFound = false;
    
    thisInd = plan(ind,1);
    cmdInd  = plan(ind,2);
    cmdTime = plan(ind,3);
    cmdChng = plan(ind,4);
    
    t0 = cmdTime - 2*oneSec ;        % time axis t0
    tf = cmdTime + 15*oneSec ;       % time axis tf
    tc = cmdTime;                    % command time
    timeInterval = [t0, tf];
    
    try
        lastState = find(data(thisInd).state.ts.Time <= cmdTime);
        lastState = data(thisInd).state.ts.Data( lastState(end) );
    catch
        lastState = [];
    end
    
    if lastDataIndex ~= thisInd
        lastDataIndex = thisInd;
        cmdCount = 1;
    else
        cmdCount = cmdCount + 1;
    end
    
    
    
    %% Numerical Analysis
    
    
%           firstmvt: []
%         motionstop: []
%     transitiontime: []
%          totaltime: []
%          operation: []
%         commandnum: []
%            command: []
%          normalpos: []
    
    results(ind).operation = data(thisInd).metadata.operationName;
    results(ind).normalpos = normalPos;
    results(ind).command = data(thisInd).cmd.ts.Data(cmdInd);
    results(ind).commandtime = cmdTime;
    results(ind).lastState = lastState;
    results(ind).commandnum = cmdCount;
    % This is STE!
    if ~skipSTE
        results(ind).steTemp = mean(stData.fd.ts.getsampleusingtime(t0,tf).Data);
    end
    
    if isDiscrete
        if cmdChng > 0
            %Energizing
            results(ind).commandtype = 'Energize';
            if isNO
                results(ind).commandedTo = 'CLOSE';
            else
                results(ind).commandedTo = 'OPEN';
            end
        else
            results(ind).commandtype = 'De-energize';
            if isNO
                results(ind).commandedTo = 'OPEN';
            else
                results(ind).commandedTo = 'CLOSE';
            end
        end
    else
        if (cmdChng < 0 && isNO) || (cmdChng > 0 && ~isNO)
            %Energizing
            results(ind).commandtype = 'Energize';
        else
            results(ind).commandtype = 'De-energize';
        end
        
        if cmdChng > 0
            results(ind).commandedTo = 'OPEN';
        else
            results(ind).commandedTo = 'CLOSE';
        end
    end
    
    
    
    cmdTs = data(thisInd).cmd.ts.getsampleusingtime(t0, tf + oneSec*2);
    staTs = data(thisInd).state.ts.getsampleusingtime(t0, tf + oneSec*2);
    
    % Get time to first movement
    foundFirstMovement  = false;
    foundFinalState     = false;
    
    if isDiscrete
        targetTrans = 2;
        switch results(ind).commandedTo
            case 'OPEN'
                targetFinal = 1;
            otherwise
                targetFinal = 0;
        end
    else
        % What the hell am I gonna do for proportional??
        continue
    end
    
    for sInd = 1:length(staTs.Data)
        if staTs.Time(sInd) > cmdTime;
            
            if abs(staTs.Data(sInd) - results(ind).lastState) > 0.5 % Should be movement for discrete or proportional in either direction
                if ~foundFirstMovement
                    foundFirstMovement = true;
                    results(ind).firstmvt = staTs.Time(sInd);
                end
                
                if ~foundFinalState && (staTs.Data(sInd) == targetFinal)
                    foundFinalState = true;
                    results(ind).motionstop = staTs.Time(sInd);
                end    
            end
        end
    end
    
    
    results(ind).timetofirstmvt = (results(ind).firstmvt   - results(ind).commandtime)  ./ oneSec;
    results(ind).transitiontime = (results(ind).motionstop - results(ind).firstmvt)     ./ oneSec;
    results(ind).totaltime      = (results(ind).motionstop - results(ind).commandtime)  ./ oneSec;
    
    results(ind).timeFromEvent  = (results(ind).commandtime - data(thisInd).eventTime); % ./ onesec;
    results(ind).eventFd        = data(thisInd).eventFd;
    
    % Get time to final state (might be the same time!)
    
    
 
    
%         annotationX = [tc(1), newTime(matches(1)) ];
%         annotationY = [150, 10 ];
% 
%         P1 = [tc(1) + 4*onesec,    150 ];
%         P2 = [newTime(matches(1)),  10 ];



    
if skipFigures
    continue
end
    
    

    %% Plot Data
    % Top Plot (Flow Rate)
    axes(axPairArray(ind,1));
%     
%     for fn = 1:numel(dataFiles)
%         fd = data(thisInd).dataFiles(fn);
% %         fd = allFDs(fn);
%         hold on
%         stairs(fd.ts.Time, fd.ts.Data, 'displayName', displayNameFromFD(fd));
%     end
    
    tempState = data(thisInd).state.ts.getsampleusingtime(dataWindow(1)+t0, dataWindow(2)+t0);
    tempParam = data(thisInd).cmd.ts.getsampleusingtime(dataWindow(1)+t0, dataWindow(2)+t0);
    
    stairs(tempState.Time, tempState.Data, 'DisplayName', 'State');
    hold on;
    stairs(tempParam.Time, tempParam.Data, 'DisplayName', 'Command')
    
%     reviewPlotAllTimelineEvents(data(thisInd).timeline)
%     title(sprintf('%s %d', 'Stop Flow (Flow)', ind))
%     title(sprintf('%s %s', data(thisInd).metaData.operationName, 'Stop Flow'), 'interpreter', 'none');
    setDateAxes(axPairArray(ind, 1), 'XLim', plotWindow + t0);
    
    if isDiscrete
        ylim([ -0.1, 2.1 ] );
    else
        ylim([ -0.1, 100.1 ] );
    end
    
    
    if ~skipPTs
        % Bottom Plot (Valve State)
        axes(axPairArray(ind,2));

%         for fn = 1:numel(pressFiles)
%             fd = data(thisInd).pressFiles(fn);
            data(thisInd).press.ts
    %         fd = valveFDs(fn);
            hold on
            stairs(data(thisInd).press.ts.Time, data(thisInd).press.ts.Data, ...
                'displayName', displayNameFromFD(data(thisInd).press));
%         end


        try
            reviewPlotAllTimelineEvents(data(thisInd).timeline)
        catch
        end
    %     title(sprintf('%s %d', 'Stop Flow (Valve)', ind))
%         title(sprintf('%s %s', data(thisInd).metaData.operationName, 'Stop Flow'), 'interpreter', 'none');

        linkaxes(axPairArray(ind,:),'x');
        dynamicDateTicks(axPairArray(ind,:), 'link');
        setDateAxes(axPairArray(ind, 2), 'XLim', timeInterval);
        
        if shouldPlotRVLimits
            hline(165, '--r', 'RV setpoint');
            hline(165*0.9, '--r', '- 10%');
        end
    
        ylim( pressYLim );
    end
    
    
%     ylim([ -0.1, 2.1] );

    
end

%% Table output

outTable = struct2table(results);

fieldsToClean = {'firstmvt'; 'motionstop'; 'timetofirstmvt'; 'transitiontime'; 'totaltime'};
for f2cInd = 1:numel(fieldsToClean)
    fieldName = fieldsToClean{f2cInd};
    switch class(outTable.(fieldName))
        case 'cell'
            emptyIndices = cellfun(@isempty, outTable.(fieldName) );
            outTable.(fieldName)(emptyIndices) = {nan};
        case 'double'
            % Anything to do here?
    end
    
end

outTable


writetable(outTable, fullfile(missions{end}, [valveName, '_valveTable.csv']))



reviewRescaleAllTimelineEvents

