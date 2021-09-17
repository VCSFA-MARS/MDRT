dataSets = {
    '/Users/nick/data/archive/2021-08-09 - NG-16_Launch'
    '/Users/nick/data/archive/2021-08-09 - NG-16_Launch' % Extra for VNO1 Testing
    '/Users/nick/data/imported/2021-05-26 - ITR-2084 VNO1 Simulation'
    '/Users/nick/data/archive/2021-02-19 - NG-15 Launch'
    '/Users/nick/data/archive/2021-02-19 - NG-15 Launch' % Extra for VNO1 Testing
    '/Users/nick/data/archive/2020-10-02 - NG-14 Launch'
    '/Users/nick/data/archive/2020-09-30 - NG-14 Scrub'
    '/Users/nick/data/archive/2020-02-15 - NG-13 Launch'
    '/Users/nick/data/archive/2020-02-09_NG-13'
    '/Users/nick/data/archive/2019-11-01 - NG-12'
    '/Users/nick/data/archive/2019-04-16 - NG-11 Launch'
    '/Users/nick/data/archive/2018-11-16 - NG-10 Launch'
    '/Users/nick/data/archive/2018-05-20 - OA-9 Launch'
    '/Users/nick/data/archive/2017-11-12 - OA-8 Launch'
    '/Users/nick/data/archive/2017-11-11 - OA-8 Scrub'
    '/Users/nick/data/archive/2016-20-17 OA-5 LA1'
};

botData = {
    '4913 Ghe PT-4913 Press Sensor Mon.mat'
    '4914 Ghe PT-4914 Press Sensor Mon.mat'
    '4915 Ghe PT-4915 Press Sensor Mon.mat'
};

topData = {
	'4912 Ghe PT-4912 Press Sensor Mon.mat'
};

%% Make Subplots
plotTitles = {};
for d = 1:numel(dataSets)
    metafile = fullfile(dataSets{d}, 'data', 'metadata.mat');
    load(metafile)
    plotTitles = vertcat(plotTitles, metaData.operationName);
end

numSubplots = numel(plotTitles) * 2;
[axHandles, figHandles, axPairArray] = makeManyMDRTSubplots( ...
                numSubplots,     'VNO1 Comparison', ...
                'groupAxesBy',  2, ...
                'plotsWide',    3, ...
                'plotsHigh',    2);





%%
for p = 1:numel(dataSets)
    thisAxPair = axPairArray(p,:);
    topAx = axPairArray(p,1);
    
    folder = fullfile(dataSets{p}, 'data');
   
    for t = 1:numel(topData)
        filename = fullfile(folder, topData{t});
        try
            load(filename)
        catch
            % skip
            continue
        end
        
        axes(topAx); hold on
        dispName = displayNameFromFD(fd);
        LinePlotReducer(@stairs, fd.ts.Time, fd.ts.Data, 'displayname', dispName);
    end
    
    topAx.Title.String = sprintf('%s - %s', plotTitles{p}, 'Storage');
    legend('Location', 'SouthEast')
    
    botAx = axPairArray(p,2);
    for t = 1:numel(botData)
        filename = fullfile(folder, botData{t});
        try
            load(filename)
        catch
            % skip
            continue
        end
        
        axes(botAx); hold on
        dispName = displayNameFromFD(fd);
        LinePlotReducer(@stairs, fd.ts.Time, fd.ts.Data, 'displayname', dispName);
    end
    
    botAx.Title.String = sprintf('%s - %s', plotTitles{p}, 'Interface');
    
    linkaxes(thisAxPair, 'x');
    dynamicDateTicks(thisAxPair, 'linked');
    
    setDateAxes(topAx, 'YLim', [4000, 5500]);
    setDateAxes(botAx, 'YLim', [2800, 3200]);
    
	
    try
        load(fullfile(folder, 'timeline.mat'));
        reviewPlotAllTimelineEvents(timeline, 'timelineOnly', true );
    catch
        % don't worry about it
    end
    
    h_zoom = zoom(figHandles(ceil(p/3)) ) ;
    h_zoom.motion = 'horizontal';
    h_zoom.enable = 'on';
    
    legend('Location', 'SouthEast')
    
end