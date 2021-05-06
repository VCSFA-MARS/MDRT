dataFolders = { '/Users/nick/data/archive/2021-02-19 - NG-15 Launch/data';
                '/Users/nick/data/archive/2020-10-02 - NG-14 Launch/data';
                '/Users/nick/data/archive/2020-09-30 - NG-14 Scrub/data';
                '/Users/nick/data/archive/2020-02-15 - NG-13 Launch/data';
                '/Users/nick/data/archive/2019-11-01 - NG-12/data';
                '/Users/nick/data/archive/2019-04-16 - NG-11 Launch/data';
                '/Users/nick/data/archive/2018-11-16 - NG-10 Launch/data'
                };
            
dataFiles = { '5903 GN2 PT-5903 Press Sensor Mon.mat';
              '5070 GN2 PT-5070 Press Sensor Mon.mat' };

valveFiles = {'2031 LO2 DCVNC-2031 State.mat';
              '2031 LO2 DCVNC-2031 Ball Valve Ctl Param.mat';
              '2097 LO2 DCVNC-2097 State.mat';
              '2097 LO2 DCVNC-2097 Ball Valve Ctl Param.mat'};
                

eventFD = 'LOLS Topoff Cmd';
eventSt = 'FGSE LOLS Top-Off Command';

PageTitles = sprintf('%s Comparison Across Missions', eventFD);

%% Constants

onehr = 1/24;
onemin = onehr/60;
onesec = onemin/60;

%% Iterate across data sets and plan plots

DataSet = struct;
PlotParam = [];

for dfi = 1:numel(dataFolders)
    commandCounter = 0;
    metaFile = fullfile(dataFolders{dfi}, 'metadata.mat');
    timeFile = fullfile(dataFolders{dfi}, 'timeline.mat');
    
    ms = load(metaFile);
    ts = load(timeFile);
    
    DataSet(dfi).metadata = ms.metaData;
    DataSet(dfi).timeline = ts.timeline;
    DataSet(dfi).Mission = ms.metaData.operationName;
    
    TheseValves = [];
    for fdi = 1:numel(valveFiles);
        load(fullfile(dataFolders{dfi}, valveFiles{fdi})) ;
        TheseValves = vertcat(TheseValves, fd);
    end
    
    DataSet(dfi).ValveFDs = TheseValves;
    
    ThesePTs = [];
    for fdi = 1:numel(dataFiles);
        load(fullfile(dataFolders{dfi}, dataFiles{fdi}));
        ThesePTs = vertcat(ThesePTs, fd);
    end
    
    DataSet(dfi).PTFDs = ThesePTs;
    
    
    
	MFds={ts.timeline.milestone.FD}';
    sfInd = find(ismember(MFds, eventFD));
    
    for ei = 1:numel(sfInd)
        % Build plot parameter for each found event
        ThisPlot = struct;
        ThisPlot.event = ts.timeline.milestone(sfInd(ei));
        ThisPlot.Title = sprintf('%s : %s %d', DataSet(dfi).Mission, eventFD, ei);
        ThisPlot.dsi = dfi;
        ThisPlot.te = ThisPlot.event.Time;
        ThisPlot.t0 = ThisPlot.te - 2*onesec;
        ThisPlot.tf = ThisPlot.te + 10*onesec;
        
        
        PlotParam = vertcat(PlotParam, ThisPlot);
        
        commandCounter = commandCounter + 1;
    end
    
    fprintf('Found %2d events in %s\n', commandCounter, DataSet(dfi).Mission)
    
end
    
%% Generate Figures and Subplots

 [axHandles, figHandles, axPairArray] = makeManyMDRTSubplots(numel(PlotParam)*2, PageTitles );


%% Generate Plots

for pi = 1:numel(PlotParam)
    
    topAx = axPairArray(pi, 1);
    botAx = axPairArray(pi, 2);
    
    thisPlot = PlotParam(pi);
    thisDataSet = DataSet(thisPlot.dsi);
    
    
    % Muscle Pressure Plots: Top Axes
        
    for p = 1:numel(thisDataSet.PTFDs)
        topAx.addFD(thisDataSet.PTFDs(p));
    end
                    



    dynamicDateTicks(topAx.hAx);
    setDateAxes(topAx.hAx, 'XLim', [thisPlot.t0 thisPlot.tf] ) ;
    setDateAxes(topAx.hAx, 'YLim', [92, 102]);
    MDRTEvent(thisPlot.event, topAx);
    
    
    topAx.title = thisPlot.Title;
    
    % Valve Position Plots: Bottom Axes
    
    for s = 1:numel(thisDataSet.ValveFDs)
        botAx.addFD(thisDataSet.ValveFDs(s));
    end
    
	dynamicDateTicks(botAx.hAx);
    setDateAxes(botAx.hAx, 'XLim', [thisPlot.t0 thisPlot.tf] ) ;
    setDateAxes(botAx.hAx, 'YLim', [-0.1, 2.1]);
                
    botAx.title = thisPlot.Title;
    MDRTEvent(thisPlot.event, botAx);
                
    
    linkaxes([axPairArray(pi,:).hAx]', 'x');

    
end


return
%% Save all these damn plots


path = '/Users/nick/Downloads'

for f = 1:axPairArray(end).hAx.Parent.Number
    
    fh = figure(f);
    
    sth = findobj(fh,'Tag','suptitle');
    graphTitle = sth.Children.String;
    
    defaultName = regexprep(graphTitle,'^[!@$^&*~?.|/[]<>\`";#()]','');
    defaultName = regexprep(defaultName, '[:]','-');
    
    
    saveas(fh, fullfile(path, defaultName),'pdf');
    
end



PlotTitleString = sprintf('%s Flight Comparison', eventFD);