function compareCGHe()

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

ComparisonName = 'Cold Helium Comparison';

%% Configuration to allow running on multiple machines

config = MDRTConfig.getInstance;

load(fullfile(config.dataArchivePath, 'dataIndex.mat'));


availableDataSets = cell(length(dataIndex), 3);


for i = 1:length(dataIndex)

    opnames{i, 1} = dataIndex(i).metaData.operationName;
    datapaths{i, 1} = dataIndex(i).pathToData;
    usedata{i,1} = true;
    
end

availableDataSets = { usedata{:}; opnames{:}; datapaths{:} }';

hf = figure('NumberTitle',      'off', ...
            'Name',             [ComparisonName ' : ' 'Data Set Selection'], ...
            'ToolBar',          'none', ...
            'MenuBar',          'none');
        
ht = uitable('Data', availableDataSets, ...
            'ColumnEdit',       [true, false, false], ...
            'Units',            'normalized', ...
            'Position',         [0.05 0.15 0.9 0.85] );

hb = uicontrol('Style',         'pushbutton', ...
            'Units',            'normalized', ...
            'Position',         [0.05 0.025 0.9, 0.1], ...
            'String',           'Generate Comparison Plot', ...
            'Callback',         {@generatePlot, ht});
        
        
        
end      
   
function generatePlot(event, obj, varargin)
%% Plot FD configuration and logic


plotConfig = cell2table(varargin{1}.Data);
plotConfig.Properties.VariableNames = {'use', 'name', 'path'};

dataFolders = plotConfig.path(plotConfig.use);




dataFileName1 = '4918 Ghe PT-4918 Press Sensor Mon.mat';
dataFileName2 = '4919 Ghe PT-4919 Press Sensor Mon.mat';

EventString = 'Charge Chilled Helium Bottles';
EventFD = 'GHe-W Charge Cmd';

% Constants
onehr = 1/24;
onemin = onehr/60;
onesec = onemin/60;

fig = makeMDRTPlotFigure;


% fix color matrix based on number of plots!

recentColors =  [   0.0 0.0 0.9;
                    0.5 0.0 0.5;
                    0.9 0.0 0.0 ];
length(dataFolders)
                
for ci = 1:length(dataFolders)
    if ci <= length(recentColors )
        colors(ci, :) = recentColors(ci, :);
    else
        colors(ci, :) = [0.6 0.6 0.6];
    end
end

colors = num2cell(colors(end:-1:1,:) ,2 )

% 
% 
% colors = {      [0.6 0.6 0.6];
%                 [0.6 0.6 0.6];
%                 [0.6 0.6 0.6];
%                 [0.6 0.6 0.6];
%                 [0.6 0.6 0.6];
%                 [0.6 0.6 0.6];
%                 [0.6 0.6 0.6];
%                 [0.9 0.0 0.0];
%                 [0.5 0.0 0.5];
%                 [0.0 0.0 0.9]...
%              };



%	Page setup for landscape US Letter
        graphsInFigure = 1;
        graphsPlotGap = 0.05;
        GraphsPlotMargin = 0.06;
        numberOfSubplots = 2;

        legendFontSize = [8];

subPlotAxes = MDRTSubplot(numberOfSubplots,1,graphsPlotGap, ... 
                                GraphsPlotMargin,GraphsPlotMargin);


% load(timelines{1});
load( fullfile( dataFolders{end}, 'timeline.mat') );


% ismember({timeline.milestone.FD}, 'GHe-W Charge Cmd')
eventInd = find(ismember({timeline.milestone.String}, EventString), 1, 'first');

tf = timeline.milestone(eventInd).Time;

% tf=timeline.t0.time;



htop = [];
hbot = [];


for f = 1:numel(dataFolders)

    try

        load( fullfile( dataFolders{f},  'timeline.mat') );
        load( fullfile( dataFolders{f},   dataFileName1) );
        load( fullfile( dataFolders{f},  'metadata.mat') );

        eventInd = find(ismember({timeline.milestone.String}, EventString), 1, 'first');

        if ~ isempty(eventInd)

            to = timeline.milestone(eventInd).Time;

        %     deltaT = tf - timeline.t0.time;
            deltaT = tf - to;


            disp(sprintf('%s : DeltaT = %1.8f', metaData.operationName, deltaT))


            axes(subPlotAxes(1)); % 4918
                hold on; 
                ht = plot(fd.ts.Time + deltaT, fd.ts.Data, ...
                    'Color',                colors{f}, ...
                    'DisplayName',          metaData.operationName);

            axes(subPlotAxes(2)); % 4919
                hold on;
                % load(loxdata{f});
                load( fullfile( dataFolders{f},   dataFileName2) );
                hb = plot(fd.ts.Time + deltaT, fd.ts.Data, ...
                    'Color',                colors{f}, ...
                    'DisplayName',          metaData.operationName);

                htop = vertcat(htop, ht);
                hbot = vertcat(hbot, hb);

        else
            % No matching dude was found - skip that mission
        end

    catch
        % Unable to load metadata - no action
    end

end


linkaxes(subPlotAxes, 'x')
dynamicDateTicks;

axes(subPlotAxes(1));
title('PT-4918 Data for A230 Launches - Charging');
reviewPlotAllTimelineEvents(timeline)
legend SHOW;

axes(subPlotAxes(2));
title('PT-4919 Data for A230 Launches - Charging');
reviewPlotAllTimelineEvents(timeline)

legend SHOW;


    end


