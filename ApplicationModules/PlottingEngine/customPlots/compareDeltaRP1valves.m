dataFolders = {
% 	'/Users/nick/data/archive/2016-20-17 OA-5 LA1';
% 	'/Users/nick/data/archive/2017-11-11 - OA-8 Scrub';
% 	'/Users/nick/data/archive/2017-11-12 - OA-8 Launch';
% 	'/Users/nick/data/archive/2018-05-20 - OA-9 Launch';
% 	'/Users/nick/data/archive/2018-11-16 - NG-10 Launch';
% 	'/Users/nick/data/archive/2019-04-16 - NG-11 Launch';
% 	'/Users/nick/data/archive/2019-11-01 - NG-12';
% 	'/Users/nick/data/archive/2020-02-09_NG-13';
% 	'/Users/nick/data/archive/2020-02-14_NG-13-2';
	'/Users/nick/data/archive/2020-02-15 - NG-13 Launch';
    '/Users/nick/data/archive/2020-09-30 - NG-14 Scrub';
    '/Users/nick/data/archive/2020-10-02 - NG-14 Launch'; ...
    '/Users/nick/data/archive/2021-02-19 - NG-15 Launch'; ...
    '/Users/nick/data/archive/2021-08-09 - NG-16 Launch'; ...
    '/Users/nick/data/archive/2022-02-18 - NG-17 Launch'; ...
    '/Users/nick/data/archive/2022-11-05 - NG-18 Scrub'; ...
    '/Users/nick/data/archive/2022-11-06 - NG-18 Launch'; ...
    };

sensorFiles = {	'1014 RP1 PCVNC-1014 Globe Valve Mon.mat';
                '1015 RP1 PCVNC-1015 Globe Valve Mon.mat'; ...
              };


EventString = 'Prime FLS Transfer Line';
EventFD = 'FLS Prime Transfer Line Cmd';

EventString = 'FGSE FLS Low Flow Fill Command';
EventFD = 'FLS LLFF Cmd';

%% Constants
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
         
         
         
%%	Page setup for landscape US Letter
        graphsInFigure = 1;
        graphsPlotGap = 0.05;
        GraphsPlotMargin = 0.06;
        numberOfSubplots = 3;
        plotsWide = 1;
        plotsHigh = 3;
        legendFontSize = [8];
        
subPlotAxes = MDRTSubplot(plotsHigh, plotsWide, graphsPlotGap, ... 
                                GraphsPlotMargin, GraphsPlotMargin);
                            

% load(timelines{1});
load( fullfile( dataFolders{end}, 'data', 'timeline.mat') );


% ismember({timeline.milestone.FD}, 'GHe-W Charge Cmd')
eventInd = find(ismember({timeline.milestone.String}, EventString), 1, 'first');

tf = timeline.milestone(eventInd).Time;

% tf=timeline.t0.time;



htop = [];
hmid = [];
hbot = [];


for f = 1:numel(dataFolders)
    %     load(timelines{f})
    %     load(datafiles{f})
    %     load(metafiles{f})
    
    
    load( fullfile( dataFolders{f}, 'data', 'timeline.mat') );
    load( fullfile( dataFolders{f}, 'data', 'metadata.mat') );
    
    
    theseData = [];
    
    for i = 1:length(sensorFiles)
        S = load( fullfile( dataFolders{f}, 'data',  sensorFiles{i} ) );
        theseData = vertcat(theseData, S.fd);
    end
    

    
        

    ts1 = theseData(1).ts;
    ts2 = theseData(2).ts;

    eventInd = find(ismember({timeline.milestone.String}, EventString), 1, 'first');
    if ~ isempty(eventInd)

        to = timeline.milestone(eventInd).Time;
        deltaT = tf - to;
        disp(sprintf('%s : DeltaT = %1.8f', metaData.operationName, deltaT))

        newTime = to : onesec : to + (2*onehr) ;
        
        warning off
            ts1 = ts1.resample(newTime);
            ts2 = ts2.resample(newTime);
        warning on
        
        dts = ts1 + ts2;                    % Find average value!
        dts.Data = dts.Data ./ 2;           % Find average value!
        dts.Name = 'Mean valve position';
        
        toPlot = [dts; ts1; ts2];
        
        for n = 1:length(toPlot)
            
            axes(subPlotAxes(n));
            hold on;

            ht = plot(toPlot(n).Time + deltaT, toPlot(n).Data, ...
                'Color',                colors{f}, ...
                'DisplayName',          metaData.operationName);


            titleFormatString = '%s Data for A230 Launches - Loading';

            topTitle = sprintf(titleFormatString, toPlot(n).Name );
            title(topTitle);

            switch n
                case 1
                    htop = vertcat(htop, ht);
                case 2
                    hmid = vertcat(hmid, ht);
                case 3
                    hbot = vertcat(hbot, ht);
            end
            
        end

    end

end

reviewPlotAllTimelineEvents(timeline)

linkaxes(subPlotAxes, 'x')


dynamicDateTicks;
legend SHOW;


% 
% htop(1).XData = htop(1).XData - (onesec * 2.5);
% hbot(1).XData = hbot(1).XData - (onesec * 2.5);


