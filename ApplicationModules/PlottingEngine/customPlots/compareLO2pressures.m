dataFolders = {
	'/Users/nick/data/archive/2016-20-17 OA-5 LA1';
	'/Users/nick/data/archive/2017-11-11 - OA-8 Scrub';
	'/Users/nick/data/archive/2017-11-12 - OA-8 Launch';
	'/Users/nick/data/archive/2018-05-20 - OA-9 Launch';
	'/Users/nick/data/archive/2018-11-16 - NG-10 Launch';
	'/Users/nick/data/archive/2019-04-16 - NG-11 Launch';
	'/Users/nick/data/archive/2019-11-01 - NG-12';
	'/Users/nick/data/archive/2020-02-09_NG-13';
	'/Users/nick/data/archive/2020-02-14_NG-13-2';
	'/Users/nick/data/archive/2020-02-15 - NG-13 Launch';
    '/Users/nick/data/archive/2020-09-30 - NG-14 Scrub';
    '/Users/nick/data/archive/2020-10-02 - NG-14 Launch'; ...
};


sensorFiles = { '2913 LO2 PT-2913 Press Sensor Mon.mat';
                '2904 LO2 PT-2904 Press Sensor Mon.mat';
                '2906 LO2 PT-2906 Press Sensor Mon.mat';
                '2918 LO2 PT-2918 Press Sensor Mon.mat';
                '2112 LO2 PT-2112 Press Sensor Mon.mat';
                '2909 LO2 PT-2909 Press Sensor Mon.mat';
                'DOZM.mat'; ...
                };


dataFileName1  = '2918 LO2 PT-2918 Press Sensor Mon.mat';
% dataFileName11 = '2112 LO2 PT-2112 Press Sensor Mon.mat';
dataFileName2  = '2906 LO2 PT-2906 Press Sensor Mon.mat';


dataFileName1 = '2112 LO2 PT-2112 Press Sensor Mon.mat'
dataFileName2 = '2909 LO2 PT-2909 Press Sensor Mon.mat'

EventString = 'FGSE LOLS Low Flow Fill Command';
EventFD = 'LOLS LLFO Cmd';

EventString = 'LOLS Chilldown Transfer Line Phase 1';
EventFD = 'LOLS Chilldown Phase1 Cmd'

% Constants
onehr = 1/24;
onemin = onehr/60;
onesec = onemin/60;

fig = makeMDRTPlotFigure;

colors = {      [0.6 0.6 0.6];
                [0.6 0.6 0.6];
                [0.6 0.6 0.6];
                [0.6 0.6 0.6];
                [0.6 0.6 0.6];
                [0.6 0.6 0.6];
                [0.6 0.6 0.6];
                [0.6 0.6 0.6];
                [0.6 0.6 0.6];
                [0.9 0.0 0.0];
                [0.5 0.0 0.5];
                [0.0 0.0 0.9]...
             };
         
         
         
%	Page setup for landscape US Letter
        graphsInFigure = 1;
        graphsPlotGap = 0.05;
        GraphsPlotMargin = 0.06;
        numberOfSubplots = 2;
        
        legendFontSize = [8];
        
subPlotAxes = MDRTSubplot(numberOfSubplots,1,graphsPlotGap, ... 
                                GraphsPlotMargin,GraphsPlotMargin);
                            

% load(timelines{1});
load( fullfile( dataFolders{end}, 'data', 'timeline.mat') );


% ismember({timeline.milestone.FD}, 'GHe-W Charge Cmd')
eventInd = find(ismember({timeline.milestone.String}, EventString), 1, 'first');

tf = timeline.milestone(eventInd).Time;

tf=timeline.t0.time;



htop = [];
hbot = [];


for f = 1:numel(dataFolders)
    %     load(timelines{f})
    %     load(datafiles{f})
    %     load(metafiles{f})
    
    load( fullfile( dataFolders{f}, 'data', 'timeline.mat') );
    load( fullfile( dataFolders{f}, 'data',  dataFileName1) );
    load( fullfile( dataFolders{f}, 'data', 'metadata.mat') );
    
    eventInd = find(ismember({timeline.milestone.String}, EventString), 1, 'first');
    
    if ~ isempty(eventInd)
          
        to = timeline.milestone(eventInd).Time;

        deltaT = tf - timeline.t0.time;
%         deltaT = tf - to;


        disp(sprintf('%s : DeltaT = %1.8f', metaData.operationName, deltaT))


        axes(subPlotAxes(1)); % 2904
            hold on;
            ht = plot(fd.ts.Time + deltaT, fd.ts.Data, ...
                'Color',                colors{f}, ...
                'DisplayName',          metaData.operationName);
            
            topTitle = sprintf('%s-%s Data for A230 Launches - Loading', ...
                fd.Type, fd.ID);

        axes(subPlotAxes(2)); % 2906
            hold on;
            % load(loxdata{f});
            load( fullfile( dataFolders{f}, 'data',  dataFileName2) );
            hb = plot(fd.ts.Time + deltaT, fd.ts.Data, ...
                'Color',                colors{f}, ...
                'DisplayName',          metaData.operationName);
            
            botTitle = sprintf('%s-%s Data for A230 Launches - Loading', ...
                fd.Type, fd.ID);

            htop = vertcat(htop, ht);
            hbot = vertcat(hbot, hb);
            
    else
        % No matching dude was found - skip that mission
    end
        
end

reviewPlotAllTimelineEvents(timeline)
linkaxes(subPlotAxes, 'x');
dynamicDateTicks;
legend SHOW;


axes(subPlotAxes(1));
title(topTitle);

axes(subPlotAxes(2));
title(botTitle);

legend SHOW;

htop(1).XData = htop(1).XData - (onesec * 2.5);
hbot(1).XData = hbot(1).XData - (onesec * 2.5);

