function plotGN2PHS


% dataPath = '/Users/nick/data/archive/2022-02-18 - NG-17 Launch/data'
% dataPath = '/Users/nick/data/archive/2021-08-09 - NG-16_Launch/data'
% dataPath = '/Users/nick/data/archive/2021-02-19 - NG-15 Launch/data'
% dataPath = '/Users/nick/data/archive/2019-11-01 - NG-12/data'
% dataPath = '/Users/nick/data/archive/2019-04-16 - NG-11 Launch/data';
% dataPath = '/Users/nick/data/archive/2018-11-16 - NG10 Topoff/data';
% dataPath = '/Users/nick/data/archive/2018-05-20 - OA-9 Launch/data';

flowData = '5919 GN2 PT-5919 Press Sensor Mon.mat'

config = getConfig;
dataPath = config.dataFolderPath;


% dataPath = uigetdir(dataPath, 'Select data folder');
% 
% % [x,y,button] = ginput(1)
% % [x,y] = ginput()
% 
% dataPath = config.dataFolderPath;
% dataPath = uigetdir(dataPath, 'Select data folder')

I = imread('414-GN2PHS.png');


onehr = 1/24;
onemin = onehr/60;
onesec = onemin/60;


%% Load Data 

t0 = [];

try
    t = load(fullfile(dataPath, 'timeline.mat'),'-mat');

    if t.timeline.uset0
        t0 = t.timeline.t0.time;
    end
    
catch
    warning('%s %s\n%s', 'Unable to read timeline file', ...
        'Check file permissions.' ...
       );
end



%% Figure Setup

hf = figure;
addToolButtonsToPlot(hf);


%% Axes Setup - Schematic Placement

hap = axes();
hap.Units = 'normalized';
hap.Position(2) = 0.28;

hi = imagesc(I);


%% Axes Setup - Master Plot Placement

had = axes('Position', [0,0, 1, 0.28]);

hdd = uicontrol('Style',    'popup', ...
                'Units',    'normalized', ...
                'Position', [0.01 0.28 0.2 0.02], ...
                'String',   {'', 'Dummy Value'}, ...
                'Callback', @selectNewFD );

FDList = {};

try
    load(fullfile(dataPath, 'AvailableFDs.mat'),'-mat');

    % Add the loaded list to the GUI handles structure
    FDList;

    % add the list to the GUI menu
    hdd.String = FDList(:,1);
catch
    warning('%s %s\n%s', 'Unable to read FD List.', ...
        'Check file permissions.', ...
        'Select "Update FD List" as a temporary workaround.');
end

dropIndex = [];
[dropIndex, ~ ] = find(ismember(FDList, flowData));

if dropIndex
    hdd.Value = dropIndex;
end

            


%% Figure Setup - Widget Placement

valveCenters = [ 1333	 301
                 1398	 536
                 1830	 595
                 1961	 595  ];
            
valveNames = {  'd5079';
                'd5047';
                'p5126';
                'p5198';};
            
tcPos = [       1200	 290;
                1250	 490;
                1700	 290;
                2100	 290;
                2100	 390;
         ];
            
tsNames = {     'p5920' ;
                'p5917' ;
                'p5913' ;
                'p5911' ;
                't5916' ;
                };
            
            
            
            
            
            
%% Draw Valve Symbols
            
valveX = [0 50 50 0 -50 -50 0];
valveY = [0 25 -25 0 -25 25 0];

axes(hap);
hold on;
valves = struct;
            
for i = 1:length(valveCenters)
    
    x = valveX * 0.75 + valveCenters(i,1);
    y = valveY * 0.75 + valveCenters(i,2);
	
	valves.(valveNames{i}) = fill(x, y, 'g');
	
end

%% Display Temperature Sensor Data

axes(hap);
hold on;
sensors = struct;


for i = 1:length(tsNames)

    sensors.(tsNames{i}) = text(tcPos(i,1), tcPos(i,2), '-XXX.X', ...
                    'Color',                [1 0 0], ...
                    'BackgroundColor',      [1 1 1], ...
                    'FontSize',             20 );
end


%% Plot Data Stream


% flowData = '2015 LO2 FM-2015 Coriolis Meter Mon.mat';
% flowData = '2909 LO2 PT-2909 Press Sensor Mon.mat';
% flowData = '4919 Ghe PT-4919 Press Sensor Mon.mat';
% flowData = '5070 GN2 PT-5070 Press Sensor Mon.mat';
% flowData = 'OxygenLevel.mat'
% statData = 'LO2TopOffStatus.mat';
% stopData = 'StopLO2Top-Off.mat';

temp = load(fullfile(dataPath, flowData));
axes(had)
hold on
hdat = plot(had, temp.fd.ts.Time, temp.fd.ts.Data);

timeLimits = [temp.fd.ts.Time(1), temp.fd.ts.Time(end)];

% temp = load(fullfile(dataPath, statData));
% hold on
% hstat = stairs(had, temp.fd.ts.Time, temp.fd.ts.Data * 500);
% 
% temp = load(fullfile(dataPath, stopData));
% hold on
% hstop = stairs(had, temp.fd.ts.Time, temp.fd.ts.Data * 400);

tl = load(fullfile(dataPath, 'timeline.mat'));
reviewPlotAllTimelineEvents(tl.timeline);

setDateAxes(had, 'XLim', timeLimits);
% had.YLim = [0, 1200];
% had.YLim = [-10, 60];

%% Make Time Marker

lx = mean(had.XLim);

hMark = line(   [lx lx],                had.YLim, ...
                'Color',                'red', ...
                'LineWidth',            3, ...
                'ButtonDownFcn',        @startDragFcn);
            
hf.WindowButtonUpFcn = @stopDragFcn;

   
%% Load Valve Data
      

links =	 {  '5079 GN2 DCVNO-5079 State.mat', 'd5079', 'valve' ;
            '5047 GN2 DCVNO-5047 State.mat', 'd5047', 'valve' ;
            '5126 GN2 DCVNC-5126 State.mat', 'p5126', 'valve' ;
            '5198 GN2 DCVNC-5198 State.mat', 'p5198', 'valve' ;
            '5920 GN2 PT-5920 Press Sensor Mon.mat', 'p5920', 'sensor';
            '5917 GN2 PT-5917 Press Sensor Mon.mat', 'p5917', 'sensor';
            '5913 GN2 PT-5913 Press Sensor Mon.mat', 'p5913', 'sensor';
            '5911 GN2 PT-5911 Press Sensor Mon.mat', 'p5911', 'sensor';
            '5916 GN2 TC-5916 Temp Sensor Mon.mat',  't5916', 'sensor';
            
        };
    

detailPlots = { 1156, 200, 'p5920', [2500 4000], 'sensor', {} ; 
                1222, 400, 'p5917', [2500 4000], 'sensor', {} ; 
                1672, 200, 'p5913', [2500 4000], 'sensor', {} ;
                2067, 200, 'p5911', [2500 4000], 'sensor', {} ;
                2091, 300, 't5916', [  32   75], 'sensor', {} ;
                };

    
   
 fd = struct; % This was a typo before - is it better now?
 
 n = length(links);
 
combinedTimeVector = [];
 
 for i = 1:n
     try         
         temp = load(fullfile(dataPath, links{i,1}));
         fd.(links{i,2}) = temp.fd;
         combinedTimeVector = vertcat(combinedTimeVector, temp.fd.ts.Time);
         debugout(sprintf('Linking %s\t%s', links{i,2}, links{i,1}) );
     catch
         disp(sprintf('%s data %s not found', links{i,3}, links{i,1}))
         blankFd = newFD;
         blankFd.ts = timeseries([0 0], [0 now]);
         
         fd.(links{i,2}) = blankFd;
         combinedTimeVector = vertcat(combinedTimeVector, blankFd.ts.Time);
     end
 end

clear temp;
   
combinedTimeVector = sort(combinedTimeVector);   
numSteps = length(combinedTimeVector);

%% Populate Detail Plots

dp = struct;
plotLines = [];
dpWidth = 0.08;
dpHeight = 0.066;
yOffset = 1 - hap.Position(2) - hap.Position(4);
yOffset = 0;

dpAxes = [];

for i = 1:size(detailPlots, 1)
    debugout(sprintf('Detail Plot Loop # : %d', i))
    
    thisX = detailPlots{i, 1};
    thisY = detailPlots{i, 2};
    thisName = detailPlots{i, 3};
    thisYLim = detailPlots{i, 4};
    thisKind = detailPlots{i, 5};
    thisFind = detailPlots{i, 6};
    
    [figX, figY] = figCoordFromAxes(thisX, thisY, hap);
        
    dp.(detailPlots{i, 3}) = axes('position', [-1 -1 0.5 0.5]);
    
    this = dp.(detailPlots{i, 3});
    
                 
    this.Position = [   figX,     ...
                        figY - dpHeight , ...
                        dpWidth, ...	
                        dpHeight ] ;
    
    switch lower(thisKind)
        case 'sensor'
            plot( fd.(detailPlots{i, 3}).ts.Time, fd.(detailPlots{i, 3}).ts.Data );
        case 'valve'
            valveStateBar( thisFind, this, 'DataFolder', dataPath );
        otherwise
            
    end
    
    
    lx = mean(dp.(detailPlots{i, 3}).XLim);

    hTemp = line(   [lx lx],            dp.(detailPlots{i, 3}).YLim, ...
                    'Color',            'red', ...
                    'LineWidth',        2 ...
                 );
	

    this.YLim = thisYLim;
    
    dpAxes = vertcat(dpAxes, this);
    plotLines = vertcat(plotLines, hTemp);
    
end

    linkaxes([dpAxes; had], 'x');
	dynamicDateTicks(dpAxes, 'linked');
    setDateAxes(had, 'XLim', timeLimits);

%% Create Slider

        % hslider = uicontrol(  'style',            'slider', ...
        %                 'position',         [0 0 hf.Position(3) 15], ...
        %                 'min',              1, ...
        %                 'max',              numSteps, ...
        %                 'value',            20, ...
        %                 'sliderstep',       [1/(numSteps-1) , 1/(numSteps-1) ]);
        % 
        % hslider.Units = 'normalized';
        % 
        % sListener = addlistener(hslider, 'Value', 'PostSet', @updateFromSlider);

%% Create Time Display

htime = uicontrol(hf, 'Style',              'text',...
                    'String',               '00:00:00.000',...
                    'Units',                'normalized',...
                    'FontSize',             16, ...
                    'Position',             [0 0.95 1 0.05]);



                
%% Update Display

    function updateFromSlider(hObj, ev)
        updateGUIfromIndex(ev.AffectedObject.Value);
    end

    function updateGUIfromIndex(i)
        i = round(i);
        timeIndex = combinedTimeVector(i);
        updateGUIfromTime(timeIndex);
    end

    function updateGUIfromTime(timeIndex)
        
        if t0
            tdelta = timeIndex - t0;
            htime.String = sprintf('%s UTC: %s  CDT: %s \t (NG Times: %s hrs or %s min or %s sec)', ...
                datestr(timeIndex, 'yyyy mmm dd'), ...
                datestr(timeIndex, 'HH:MM:SS.FFF'),...
                datestr(tdelta,    'HH:MM:SS.FFF'),...
                sprintf('%4.2f',    tdelta/onehr), ...
                sprintf('%5.2f',    tdelta/onemin), ...
                sprintf('%.2f',       tdelta/onesec)  ...
            );
        
        else
%             htime.String = sprintf('%s UTC: %s', ...
%                 datestr(timeIndex, 'yyyy mmm dd'), ...
%                 datestr(timeIndex, 'HH:MM:SS.FFF'));
            
        end
            
        for k = 1:n
            ts = getsampleusingtime(fd.(links{k,2}).ts, 0,timeIndex);
            
            switch links{k,3}
                case 'valve'            
                    if ~isempty(ts.Data)
                        % valves.(links{k,2}).FaceAlpha = ts.Data(end);
                        if (ts.Data(end) == 0)
                            valves.(links{k,2}).FaceColor = [1 0 0];
                        else
                            valves.(links{k,2}).FaceColor = [0 1 0];
                        end
                    end
                    
                case 'sensor'
                    sensors.(links{k,2}).String = sprintf('%3.1f', ts.Data(end));
                    
                otherwise
                    % Anything make sense to go here?
                    
            end
            
        end
    end



    function startDragFcn(varargin)
        hf.WindowButtonMotionFcn = @draggingFcn;
    end

    function stopDragFcn(varargin)
        hf.WindowButtonMotionFcn = '';
    end

    function draggingFcn(varargin)
        pt = get(had, 'CurrentPoint');
        set(hMark, 'XData', pt(1)*[1 1]);
        
        for np = 1:numel(plotLines)
            plotLines(np).XData = pt(1)*[1 1] ;
        end
        
        updateGUIfromTime(pt(1));
        
    end




    function selectNewFD(hobj, event)
        
        t = load(fullfile(dataPath, FDList{hobj.Value,2}));
        
        hdat.XData = t.fd.ts.Time;
        hdat.YData = t.fd.ts.Data;
        hdat.DisplayName = displayNameFromFD(t.fd);
        
        
    end
















end