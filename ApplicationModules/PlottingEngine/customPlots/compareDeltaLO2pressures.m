dataFolders = {
	'/Users/nick/data/archive/2016-20-17 OA-5 LA1';
	'/Users/nick/data/archive/2017-11-11 - OA-8 Scrub';
	'/Users/nick/data/archive/2017-11-12 - OA-8 Launch';
	'/Users/nick/data/archive/2018-05-20 - OA-9 Launch';
	'/Users/nick/data/archive/2018-11-16 - NG-10 Launch';
	'/Users/nick/data/archive/2019-04-16 - NG-11 Launch';
	'/Users/nick/data/archive/2019-11-01 - NG-12';
	'/Users/nick/data/archive/2020-02-09_NG-13';
	'/Users/nick/data/archive/2020-02-15 - NG-13 Launch';
    '/Users/nick/data/archive/2020-09-30 - NG-14 Scrub';
    '/Users/nick/data/archive/2020-10-02 - NG-14 Launch'; ...
};


dataFileName1  = '2904 LO2 PT-2904 Press Sensor Mon.mat';
% dataFileName11 = '2112 LO2 PT-2112 Press Sensor Mon.mat';
dataFileName2  = '2906 LO2 PT-2906 Press Sensor Mon.mat';


sensorFiles = { '2913 LO2 PT-2913 Press Sensor Mon.mat';
                '2904 LO2 PT-2904 Press Sensor Mon.mat';
                '2906 LO2 PT-2906 Press Sensor Mon.mat';
                '2112 LO2 PT-2112 Press Sensor Mon.mat';
                '2918 LO2 PT-2918 Press Sensor Mon.mat';
                '2909 LO2 PT-2909 Press Sensor Mon.mat';
                '2015 LO2 FM-2015 Coriolis Meter Mon.mat';
                'DOZM.mat'...
                };


% EventString = 'FGSE LOLS High Flow Fill Command';
% EventFD = 'LOLS LHFO Cmd';

EventString = 'LOLS Chilldown Transfer Line Phase 1'
EventFD = 'LOLS Chilldown Phase1 Cmd'

LO2SpecificGravity = 1.14;

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
                [0.9 0.0 0.0];
                [0.5 0.0 0.5];
                [0.0 0.0 0.9]...
             };
         
         
         
%%	Page setup for landscape US Letter
        graphsInFigure = 1;
        graphsPlotGap = 0.05;
        GraphsPlotMargin = 0.06;
        numberOfSubplots = 3;
        plotsWide = 3;
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
        try
            S = load( fullfile( dataFolders{f}, 'data',  sensorFiles{i} ) );
            theseData = vertcat(theseData, S.fd);
        catch
            theseData = vertcat(theseData, []);
        end
    end
    
    deltas = {  'Delta1', 2, 1, '2904 - 2913' ;
                'Delta2', 3, 2, '2906 - 2904' ;
                'Delta3', 4, 3, '2112 - 2906' ;
                'Delta4', 5, 3, '2918 - 2906' ;
                'Delta5', 6, 4, '2909 - 2112' ;
                'Delta6', 6, 5, '2909 - 2918' ;
                'Delta7', 6, 3, '2909 - 2906' ;
                'Delta8', 4, 5, '2112 - 2918' ;
             };
         
%          'Delta9', 8, 6, 'DOZM - 2909' ;
    
    eventInd = find(ismember({timeline.milestone.String}, EventString), 1, 'first');

    if ~ isempty(eventInd)

        to = timeline.milestone(eventInd).Time;
        deltaT = tf - to;
        disp(sprintf('\n%s : DeltaT = %1.8f', metaData.operationName, deltaT))

        newTime = to : onesec : to + (4*onehr) ;
        
        % Resample flow meter if
        tsFlow = theseData(7).ts.resample(newTime);
    
        spInd = 0;     
        for i = 1:size(deltas,1) 
            try
                spInd = spInd + 1;
                ts1 = theseData(deltas{i,2}).ts;
                ts2 = theseData(deltas{i,3}).ts;

                testString = sprintf('%s - %s', theseData(deltas{i,2}).ID, theseData(deltas{i,3}).ID);
                if ~ strcmp(deltas{i,4},testString) 
                    error('Delta calculation does not match specified string!')
                end
                disp(sprintf('\t%s\t%s = %s', deltas{i,1}, deltas{i,4}, testString))

                warning off
                ts1 = ts1.resample(newTime);
                ts2 = ts2.resample(newTime);
                warning on
                dts = ts1 - ts2;

                cvData = tsFlow.Data ./ sqrt( abs(ts1.Data - ts2.Data) / LO2SpecificGravity );
                cvts = timeseries(cvData, newTime);

                axes(subPlotAxes(spInd));
                hold on;

%                 ht = plot(cvts.Time + deltaT, cvts.Data, ...
%                     'Color',                colors{f}, ...
%                     'DisplayName',          metaData.operationName);

                ht = plot(dts.Time + deltaT, dts.Data, ...
                    'Color',                colors{f}, ...
                    'DisplayName',          metaData.operationName);


                titleFormatString = '%s %s Data for A230 Launches - Loading';
                titleFormatString = '%s %s';

                topTitle = sprintf(titleFormatString, deltas{i,1}, deltas{i,4});
                title(topTitle);

                switch spInd
                    case 1
                        htop = vertcat(htop, ht);
                    case 2
                        hmid = vertcat(hmid, ht);
                    case 3
                        hbot = vertcat(hbot, ht);
                end
            catch
                disp(sprintf('%s or %s not found in %s', sensorFiles{deltas{i,2}}, sensorFiles{deltas{i,3}}, metaData.operationName ))
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


