missions = {
    '/Users/nick/data/archive/2021-02-19 - NG-15 Launch/data';
    '/Users/nick/data/archive/2020-10-02 - NG-14 Launch/data';
    '/Users/nick/data/archive/2020-09-30 - NG-14 Scrub/data';
%     '/Users/nick/data/imported/2020-08-28 - NC-1145/data';
%     '/Users/nick/data/imported/2020-08-11 - NC-1145/data';
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
    
    data(n).cmd.ts      = removeDuplicateTimeseriesPoints( tcmd.fd.ts );
    data(n).state.ts    = removeDuplicateTimeseriesPoints( tstate.fd.ts );
    data(n).press.ts    = removeDuplicateTimeseriesPoints( tpress.fd.ts );
    
    
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
        fprintf('\tFound command change at %s\n', datestr(cmdDatenum) )
        
    end
    

end


fprintf( '\n%d instances of "%s" commands found\n', size(plan,1), valveName )



%% Generate Subplot Axes and Pages
skipFigures = true;

if (size(plan, 1) > spWide) & ~skipFigures
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

elseif ~skipFigures
    fig = makeMDRTPlotFigure;
    
    subPlotAxes = MDRTSubplot(spHigh,size(plan,1),graphsPlotGap, ... 
                                GraphsPlotMargin,GraphsPlotMargin);
	suptitle(PlotTitleString);
end



%% Calculate and Plot 

results = struct('firstmvt', [],        'motionstop', [], ...
                 'transitiontime', [],  'totaltime', [], ...
                 'operation', [],       'commandnum', [], ...
                 'command', [],         'normalpos', [], ...
                 'commandtime', [],     'commandtype', []);

for ind = 1:size(plan, 1)
    
    isThresholdFound = false;
    
    thisInd = plan(ind,1);
    cmdInd  = plan(ind,2);
    cmdTime = plan(ind,3);
    cmdChng = plan(ind,4);
    
    t0 = cmdTime - 2*onesec ;        % time axis t0
    tf = cmdTime + 15*onesec ;       % time axis tf
    tc = cmdTime;                    % command time
    timeInterval = [t0, tf];
    
    lastState = find(data(thisInd).state.ts.Time <= cmdTime);
    lastState = data(thisInd).state.ts.Data( lastState(end) );
    
    
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
    
    
    
    cmdTs = data(thisInd).cmd.ts.getsampleusingtime(t0, tf + onesec*2);
    staTs = data(thisInd).state.ts.getsampleusingtime(t0, tf + onesec*2);
    
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

        
    results(ind).totaltime      = (results(ind).motionstop - results(ind).commandtime)  ./ onesec;
    results(ind).transitiontime = (results(ind).motionstop - results(ind).firstmvt)     ./ onesec;
    
    
    
    % Get time to final state (might be the same time!)
    
    
 
    
%         annotationX = [tc(1), newTime(matches(1)) ];
%         annotationY = [150, 10 ];
% 
%         P1 = [tc(1) + 4*onesec,    150 ];
%         P2 = [newTime(matches(1)),  10 ];



    
	
continue
    
    

    %% Plot Data
    % Top Plot (Flow Rate)
    axes(axPairs(ind,1));
    
    for fn = 1:numel(dataFiles)
        fd = data(thisInd).dataFiles(fn);
%         fd = allFDs(fn);
        hold on
        stairs(fd.ts.Time, fd.ts.Data, 'displayName', displayNameFromFD(fd));
    end
    
    reviewPlotAllTimelineEvents(data(thisInd).timeline)
%     title(sprintf('%s %d', 'Stop Flow (Flow)', ind))
    title(sprintf('%s %s', data(thisInd).metaData.operationName, 'Stop Flow'), 'interpreter', 'none');
    setDateAxes(axPairs(ind, 1), 'XLim', timeInterval);
    ylim([ 0, 275] );
    hline(10, '--r');
    
    if isThresholdFound
        MDRTannotation('textarrow', timeToStopFlow, P1, P2);
    end
    
    % Bottom Plot (Valve State)
    axes(axPairs(ind,2));
    
    for fn = 1:numel(pressFiles)
        fd = data(thisInd).pressFiles(fn);
%         fd = valveFDs(fn);
        hold on
        stairs(fd.ts.Time, fd.ts.Data, 'displayName', displayNameFromFD(fd));
    end
    
    
    reviewPlotAllTimelineEvents(data(thisInd).timeline)
%     title(sprintf('%s %d', 'Stop Flow (Valve)', ind))
    title(sprintf('%s %s', data(thisInd).metaData.operationName, 'Stop Flow'), 'interpreter', 'none');
    
    linkaxes(axPairs(ind,:),'x');
    dynamicDateTicks(axPairs(ind,:), 'link');
    setDateAxes(axPairs(ind, 2), 'XLim', timeInterval);
    
    ylim([ 0, 200] );
%     ylim([ -0.1, 2.1] );
    

    
end
struct2table(results)

%% Add hline annotations to bottom plot
for q = 1:length(axPairs)
    axes(axPairs(q,2))
    hline(165, '--r', 'RV setpoint');
    hline(165*0.9, '--r', '- 10%');
end


reviewRescaleAllTimelineEvents

