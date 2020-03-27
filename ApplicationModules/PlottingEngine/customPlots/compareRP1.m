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


dataFileName1 = '1016 RP1 FM-1016 Coriolis Meter Mon.mat';
dataFileName2 = '1017 RP1 FM-1017 Turbine Meter Mon.mat';

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
        numberOfSubplots = 2;
        
        legendFontSize = [8];
        
subPlotAxes = MDRTSubplot(numberOfSubplots,1,graphsPlotGap, ... 
                                GraphsPlotMargin,GraphsPlotMargin);
                            

% load(timelines{1});
load( fullfile( dataFolders{end}, 'data', 'timeline.mat') );


% ismember({timeline.milestone.FD}, 'GHe-W Charge Cmd')
eventInd = find(ismember({timeline.milestone.String}, EventString), 1, 'first');

tf = timeline.milestone(eventInd).Time;

% tf=timeline.t0.time;



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

    %     deltaT = tf - timeline.t0.time;
        deltaT = tf - to;


        disp(sprintf('%s : DeltaT = %1.8f', metaData.operationName, deltaT))


        axes(subPlotAxes(1)); % 4913
            hold on;
            ht = plot(fd.ts.Time + deltaT, fd.ts.Data, ...
                'Color',                colors{f}, ...
                'DisplayName',          metaData.operationName);

        axes(subPlotAxes(2)); % 4914
            hold on;
            % load(loxdata{f});
            load( fullfile( dataFolders{f}, 'data',  dataFileName2) );
            hb = plot(fd.ts.Time + deltaT, fd.ts.Data, ...
                'Color',                colors{f}, ...
                'DisplayName',          metaData.operationName);

            htop = vertcat(htop, ht);
            hbot = vertcat(hbot, hb);
            
    else
        % No matching dude was found - skip that mission
    end
        
end

reviewPlotAllTimelineEvents(timeline)




axes(subPlotAxes(1)); % 4901
    title('FM-1016 (Coriolis) Data for A230 Launches - Charging');
    legend SHOW;
    dynamicDateTicks;

axes(subPlotAxes(2)); % 4901
    title('FM-1017 (Turbine) Data for A230 Launches - Charging');
    legend SHOW;
    dynamicDateTicks;

htop(1).XData = htop(1).XData - (onesec * 2.5);
hbot(1).XData = hbot(1).XData - (onesec * 2.5);

