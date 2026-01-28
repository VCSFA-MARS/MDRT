dataFolders = {
	'/Users/nick/data/archive/2020-02-15 - NG-13 Launch';
    '/Users/nick/data/archive/2020-09-30 - NG-14 Scrub';
    '/Users/nick/data/archive/2020-10-02 - NG-14 Launch'; ...
    '/Users/nick/data/archive/2021-02-19 - NG-15 Launch'; ...
    '/Users/nick/data/archive/2021-08-09 - NG-16 Launch'; ...
    '/Users/nick/data/archive/2022-02-18 - NG-17 Launch'; ...
    '/Users/nick/data/archive/2022-11-05 - NG-18 Scrub'; ...
    '/Users/nick/data/archive/2022-11-06 - NG-18 Launch'; ...
    };


dataFileName1  = '2904 LO2 PT-2904 Press Sensor Mon.mat';
% dataFileName11 = '2112 LO2 PT-2112 Press Sensor Mon.mat';
dataFileName2  = '2906 LO2 PT-2906 Press Sensor Mon.mat';


sensorFiles = { '1902 RP1 PT-1902 Press Sensor Mon.mat'; % Ullage
                '1904 RP1 PT-1904 Press Sensor Mon.mat'; % Flow Control Inlet
                '1906 RP1 PT-1906 Press Sensor Mon.mat'; % Flow Control Outlet
                '1909 RP1 PT-1909 Press Sensor Mon.mat'; % Interface
                '1016 RP1 FM-1016 Coriolis Meter Filtered.mat'; %Flow Meter
                };

FM_index = 5;
            

EventString = 'FGSE FLS Low Flow Fill Command';
EventFD = 'FLS LLFF Cmd';

RP1SpecificGravity = 0.82;

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
        numberOfSubplots = 4;
        plotsWide = 2;
        plotsHigh = 2;
        legendFontSize = [8];
        
subPlotAxes = MDRTSubplot(plotsHigh, plotsWide, graphsPlotGap, ... 
                                GraphsPlotMargin, GraphsPlotMargin);
                            

load( fullfile( dataFolders{end}, 'data', 'timeline.mat') );

eventInd = find(ismember({timeline.milestone.String}, EventString), 1, 'last');

tf = timeline.milestone(eventInd).Time;

% tf=timeline.t0.time;



htop = [];
hmid = [];
hbot = [];


for f = 1:numel(dataFolders)
    
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
    
    deltas = {  'Delta1', 2, 1, '1904 - 1902' ;
                'Delta2', 3, 2, '1906 - 1904' ;
                'Delta3', 4, 3, '1909 - 1906' ;
                'Delta4', 4, 1, '1909 - 1902' ;
             };
    
    eventInd = find(ismember({timeline.milestone.String}, EventString), 1, 'first');

    if ~ isempty(eventInd)

        to = timeline.milestone(eventInd).Time;
        deltaT = tf - to;
        disp(sprintf('\n%s : DeltaT = %1.8f', metaData.operationName, deltaT))

        newTime = to : onesec : to + (4*onehr) ;
        
        % Resample flow meter if
        tsFlow = theseData(FM_index).ts.resample(newTime);
    
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

                cvData = tsFlow.Data ./ sqrt( abs(ts1.Data - ts2.Data) / RP1SpecificGravity );
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


