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
	'/Users/nick/data/archive/2020-02-15 - NG-13 Launch'; ...
};


dataFileName1 = '8010 HSS PT-8010 Press Sensor Mon.mat';
dataFileName1 = '8110 HSS PT-8110 Press Sensor Mon.mat';
dataFileName2 = '8020 HSS DCVNO-8020 State.mat';
dataFileName3 = '8030 HSS DCVNC-8030 State.mat';

topPlotTitle = 'HSS Hydraulic Line Supply Pressure';
midPlotTitle = 'HSS Supply Valve';
botPlotTitle = 'HSS Drain Valve';

% EventString = 'Prime FLS Transfer Line';
EventString = 'FGSE FLS High Flow Fill Command';
EventFD = 'GHe-W Charge Cmd';

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
                [0.9 0.0 0.0];
                [0.5 0.0 0.5];
                [0.0 0.0 0.9]...
             };
         
         
         
%	Page setup for landscape US Letter
        graphsInFigure = 1;
        graphsPlotGap = 0.05;
        GraphsPlotMargin = 0.06;
        numberOfSubplots = 3;
        
        legendFontSize = [8];
        
subPlotAxes = MDRTSubplot(numberOfSubplots,1,graphsPlotGap, ... 
                                GraphsPlotMargin,GraphsPlotMargin);
                            

% load(timelines{1});
load( fullfile( dataFolders{end}, 'data', 'timeline.mat') );


% ismember({timeline.milestone.FD}, 'GHe-W Charge Cmd')
% eventInd = find(ismember({timeline.milestone.String}, EventString), 1, 'first');

% tf = timeline.milestone(eventInd).Time;

tf=timeline.t0.time;



htop = [];
hmid = [];
hbot = [];


for f = 1:numel(dataFolders)
    %     load(timelines{f})
    %     load(datafiles{f})
    %     load(metafiles{f})
    
    load( fullfile( dataFolders{f}, 'data', 'timeline.mat') );
    load( fullfile( dataFolders{f}, 'data',  dataFileName1) );
    load( fullfile( dataFolders{f}, 'data', 'metadata.mat') );
    
    if timeline.uset0
          
        to = timeline.t0.time;

    %     deltaT = tf - timeline.t0.time;
        deltaT = tf - to;


        disp(sprintf('%s : DeltaT = %1.8f', metaData.operationName, deltaT))


        axes(subPlotAxes(1)); % 8110
            hold on;
            ht = plot(fd.ts.Time + deltaT, fd.ts.Data, ...
                'Color',                colors{f}, ...
                'DisplayName',          metaData.operationName);

        axes(subPlotAxes(2)); % 8020
            hold on;
            % load(loxdata{f});
            load( fullfile( dataFolders{f}, 'data',  dataFileName2) );
            hm = stairs(fd.ts.Time + deltaT, fd.ts.Data, ...
                'Color',                colors{f}, ...
                'DisplayName',          metaData.operationName);
            
        axes(subPlotAxes(3)); % 8030
            hold on;
            % load(loxdata{f});
            load( fullfile( dataFolders{f}, 'data',  dataFileName3) );
            hb = stairs(fd.ts.Time + deltaT, fd.ts.Data, ...
                'Color',                colors{f}, ...
                'DisplayName',          metaData.operationName);
            

            htop = vertcat(htop, ht);
            hmid = vertcat(hmid, hm);
            hbot = vertcat(hbot, hb);
            
    else
        % No matching dude was found - skip that mission
    end
        
end

reviewPlotAllTimelineEvents(timeline)




axes(subPlotAxes(1)); % 8110
    title(topPlotTitle);
    legend SHOW;
    dynamicDateTicks;

axes(subPlotAxes(2)); % 8020
    title(midPlotTitle);
    legend SHOW;
    dynamicDateTicks;
    
axes(subPlotAxes(3)); % 8030
    title(botPlotTitle);
    legend SHOW;
    dynamicDateTicks;
    
    

htop(1).XData = htop(1).XData - (onesec * 2.5);
hmid(1).XData = hmid(1).XData - (onesec * 2.5);
hbot(1).XData = hbot(1).XData - (onesec * 2.5);
