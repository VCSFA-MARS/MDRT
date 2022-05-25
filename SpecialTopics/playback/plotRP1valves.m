function plotRP1valves

% dataPath = '/Users/nick/data/archive/2021-08-09 - NG-16_Launch/data'
% dataPath = '/Users/nick/data/archive/2021-02-19 - NG-15 Launch/data'
% dataPath = '/Users/nick/data/archive/2019-11-01 - NG-12/data'
% dataPath = '/Users/nick/data/archive/2019-04-16 - NG-11 Launch/data';
% dataPath = '/Users/nick/data/archive/2018-11-16 - NG10 Topoff/data';
% dataPath = '/Users/nick/data/archive/2018-05-20 - OA-9 Launch/data';

config = getConfig;
dataPath = config.dataFolderPath;
% dataPath = uigetdir(dataPath, 'Select data folder');
% 
% % [x,y,button] = ginput(1)
% % [x,y] = ginput()
% 
% dataPath = config.dataFolderPath;
% dataPath = uigetdir(dataPath, 'Select data folder')

I = imread('RP1 System.png');
hf = figure;
addToolButtonsToPlot(hf);

hap = axes();
hap.Units = 'normalized';
hap.Position(2) = 0.28

hi = imagesc(I);

p = hap.Position;
% had = axes('Position', [0,0, 1, p(2)]);
had = axes('Position', [0,0, 1, 0.28]);

valveCenters = [ 330.9, 358.6819;
                 472.9, 358.6819;
                 613.0, 359.1566;
                 613.9, 278.9277;
                 974.9, 355.3588;
                1133.8, 354.8840;
                 654.3, 149.3271;
                 874.3, 149.3271;
                1055.0, 415;
                1055.0, 451;    ];
            
valveNames = {  'd1003';
                'd1010';
                'p1015';
                'p1014';
                'd1021';
                'd1022';
                'd8032';
                'd8020';
                'd1023';
                'd1024';};
            
tcPos = [        084.6, 430.3657 ;
                 173.0, 429.8910 ;
                 424.0, 328.7740 ;
                 815.1, 316.9058 ;
                1049.2, 313.5828 ;
                 735.2, 169.7403 ;
                 613.9,  245.7   ; 
                 613.9,  382.9   ;
                 802.7,  380.3   ;
                1037.2,  375.3   ;
         ];
            
tsNames = {     'p1917' ;
                'p1902' ;
                'p1904' ;
                'p1906' ;
                'p1909' ;
                'p8010' ;
                'pcv1014' ;
                'pcv1015' ;
                'ts1905'  ;
                'ts1907'  ;};
            
            
            
            
            
            
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

flowData = '1016 RP1 FM-1016 Coriolis Meter Filtered.mat'
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

% temp = load(fullfile(dataPath, statData));
% hold on
% hstat = stairs(had, temp.fd.ts.Time, temp.fd.ts.Data * 500);
% 
% temp = load(fullfile(dataPath, stopData));
% hold on
% hstop = stairs(had, temp.fd.ts.Time, temp.fd.ts.Data * 400);

tl = load(fullfile(dataPath, 'timeline.mat'));
reviewPlotAllTimelineEvents(tl.timeline);

setDateAxes(had, 'XLim', [temp.fd.ts.Time(1), temp.fd.ts.Time(end)]);
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
      

links =	 {  '1003 RP1 DCVNC-1003 State.mat', 'd1003', 'valve' ;
            '1010 RP1 DCVNC-1010 State.mat', 'd1010', 'valve' ;
            '1015 RP1 PCVNC-1015 State.mat', 'p1015', 'valve' ;
            '1014 RP1 PCVNC-1014 State.mat', 'p1014', 'valve' ;
            '1021 RP1 DCVNC-1021 State.mat', 'd1021', 'valve' ;
            '1022 RP1 DCVNO-1022 State.mat', 'd1022', 'valve' ;
            '1023 RP1 DCVNC-1023 State.mat', 'd1023', 'valve' ;
            '1024 RP1 DCVNC-1024 State.mat', 'd1024', 'valve' ;
            '8032 RP1 DCVNC-8032 State.mat', 'd8032', 'valve' ;
            '8020 HSS DCVNO-8020 State.mat', 'd8020', 'valve' ; 
            '1917 RP1 PT-1917 Press Sensor Mon.mat', 'p1917', 'sensor' ;
            '1902 RP1 PT-1902 Press Sensor Mon.mat', 'p1902', 'sensor' ;
            '1904 RP1 PT-1904 Press Sensor Mon.mat', 'p1904', 'sensor' ;
            '1906 RP1 PT-1906 Press Sensor Mon.mat', 'p1906', 'sensor' ;
            '1909 RP1 PT-1909 Press Sensor Mon.mat', 'p1909', 'sensor' ;
            '8010 HSS PT-8010 Press Sensor Mon.mat', 'p8010', 'sensor' ; 
            '1014 RP1 PCVNC-1014 Globe Valve Mon.mat', 'pcv1014', 'sensor' ;
            '1015 RP1 PCVNC-1015 Globe Valve Mon.mat', 'pcv1015', 'sensor' ;
            '1905 RP1 TC-1905 Temp Sensor Mon.mat', 'ts1905', 'sensor';
            '1907 RP1 TC-1907 Temp Sensor Mon.mat', 'ts1907', 'sensor';
        };
    
    
detailPlots = { 342, 240, 'p1904', [0 100], 'sensor', {} ; 
                774, 240, 'p1906', [0 100], 'sensor', {} ; 
                997, 240, 'p1909', [0 100], 'sensor', {} ;
                776, 300, 'p8010', [0 200], 'sensor', {} ;
%                 538, 280, 'pcv1014', [0 1], 'valve', 'PCVNC-1014' ;
%                 540, 070, 'pcv1015', [0 1], 'valve', 'PCVNC-1015' ;
                538, 410, 'pcv1014', [0 1], 'valve', 'PCVNC-1014' ;
                540, 200, 'pcv1015', [0 1], 'valve', 'PCVNC-1015' ;
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
dpWidth = 0.09;
dpHeight = 0.066;

dpAxes = [];

for i = 1:size(detailPlots, 1)
    
    thisX    = detailPlots{i, 1};
    thisY    = detailPlots{i, 2};
    thisName = detailPlots{i, 3};
    thisYLim = detailPlots{i, 4};
    thisKind = detailPlots{i, 5};
    thisFind = detailPlots{i, 6};
    thisFD   = fd.(thisName);
    
%     [figX, figY] = ds2nfu(hap, thisX, thisY);
    [figX, figY] = figCoordFromAxes(thisX, thisY, hap);
        
    dp.(detailPlots{i, 3}) = axes('position', [-1 -1 0.5 0.5]);
    
    this = dp.(detailPlots{i, 3});
    
    
    this.Position = [   figX, ...
                        figY - dpHeight, ...
                        dpWidth, ...
                        dpHeight ] ;
    
    switch lower(thisKind)
        case 'sensor'
            plot( thisFD.ts.Time, thisFD.ts.Data );
        case 'valve'
            valveStateBar( thisFind, this, 'DataFolder', dataPath );
        otherwise
            
    end
    
    
    lx = mean(dp.(detailPlots{i, 3}).XLim);

    hTemp = line(   [lx lx],            dp.(thisName).YLim, ...
                    'Color',            'red', ...
                    'LineWidth',        3 ...
                 );
	

    this.YLim = thisYLim;
    
    dpAxes = vertcat(dpAxes, this);
    plotLines = vertcat(plotLines, hTemp);
    
end

    linkaxes([dpAxes; had], 'x');
    dynamicDateTicks(dpAxes, 'linked');

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
        htime.String = datestr(timeIndex, 'HH:MM:SS.FFF');
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





















end