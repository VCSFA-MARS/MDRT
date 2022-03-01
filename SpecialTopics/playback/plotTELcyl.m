function plotTELcyl

% dataPath = '/Users/nick/data/TEL_Historical/2022-02-15 - NG17 Lift 1/data'
% dataPath = '/Users/nick/data/archive/2021-02-19 - NG-15 Launch/data'
% dataPath = '/Users/nick/data/archive/2019-11-01 - NG-12/data'
% dataPath = '/Users/nick/data/archive/2019-04-16 - NG-11 Launch/data';
% dataPath = '/Users/nick/data/archive/2018-11-16 - NG10 Topoff/data';
% dataPath = '/Users/nick/data/archive/2018-05-20 - OA-9 Launch/data';

valveScale = 0.5;

config = getConfig;
dataPath = config.dataFolderPath;

% dataPath = uigetdir(dataPath, 'Select data folder');
% 
% % [x,y,button] = ginput(1)
% % [x,y] = ginput()
% 
% for n = 1:6; 
%     disp(sprintf('%4.0f\t%4.0f', x(n), y(n))); 
% end
% dataPath = config.dataFolderPath;
% dataPath = uigetdir(dataPath, 'Select data folder')

I = imread('TEL_CylB.png');
hf = figure;
addToolButtonsToPlot(hf);

hap = axes();
hap.Units = 'normalized';
hap.Position(2) = 0.28;
hap.Position(4) = hap.Position(4)-hap.Position(2)/2;

hi = imagesc(I);
% hi = imshow(I);

p = hap.Position;
% had = axes('Position', [0,0, 1, p(2)]);
had = axes('Position', [0,0, 1, 0.28]);

valveCenters = [ 443	 128;
                 521	 130;
                 442	 485;
                 521	 486;
                1314	 491;
                1484	 608];
            
valveNames = {  'mlv11';
                'mlv12';
                'mlv9';
                'mlv10';
                'mv10';
                'mv9';};
            
tcPos = [        327	 185;
                 562	 185;
                 310	 550;
                 562	 550;
                 875	 550;
                1040	 550;
                 232     257;
         ];
            
tsNames = {     'pt51' ;
                'pt21' ;
                'pt46' ;
                'pt18' ;
                'pt25' ;
                'pt10' ;
                'lt14' };
            
            
            
            
            
            
%% Draw Valve Symbols
            
valveX = [0 50 50 0 -50 -50 0];
valveY = [0 25 -25 0 -25 25 0];

axes(hap);
hold on;
valves = struct;
            
for i = 1:length(valveCenters)
    
    x = valveX * valveScale + valveCenters(i,1);
    y = valveY * valveScale + valveCenters(i,2);
	
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

flowData = 'TELHS_SYS1 LT14 Mon.mat'
% flowData = '2015 LO2 FM-2015 Coriolis Meter Mon.mat';
% flowData = '2909 LO2 PT-2909 Press Sensor Mon.mat';
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
      

links =	 {  'TELHS_SYS1 MLV11 Device Status at Positive Ind.mat', 'mlv11', 'valve' ;
            'TELHS_SYS1 MLV12 Device Status at Positive Ind.mat', 'mlv12', 'valve' ;
            'TELHS_SYS1 MLV9 Device Status at Positive Ind.mat',  'mlv9', 'valve' ;
            'TELHS_SYS1 MLV10 Device Status at Positive Ind.mat', 'mlv10', 'valve' ;
            'TELHS MV10 Device Status at Positive Ind.mat',       'mv10', 'valve' ;
            'TELHS MV9 Device Status at Positive Ind.mat',        'mv9', 'valve' ;
            'TELHS_SYS1 PT51 Mon.mat', 'pt51', 'sensor' ;
            'TELHS_SYS1 PT21 Mon.mat', 'pt21', 'sensor' ;
            'TELHS_SYS1 PT46 Mon.mat', 'pt46', 'sensor' ;
            'TELHS_SYS1 PT18 Mon.mat', 'pt18', 'sensor' ;
            'TELHS_SYS1 PT25 Mon.mat', 'pt25', 'sensor' ;
            'TELHS_SYS1 PT10 Mon.mat', 'pt10', 'sensor' ; 
            'TELHS_SYS1 LT14 Mon.mat', 'lt14', 'sensor' ; 
            'TELHS Skew.mat', 'skew', 'sensor' ;
            'TELHS_SYS1 PV7_FBK Mon.mat', 'PV7FBK', 'sensor' ;
            'TELHS_SYS1 PV8_FBK Mon.mat', 'PV8FBK', 'sensor' ;
            'TELHS_SYS1 PT51 Mon.mat', 'pt51', 'sensor' ;
            'TELHS_SYS1 PT21 Mon.mat', 'pt21', 'sensor' ;
            'TELHS_SYS1 PT46 Mon.mat', 'pt46', 'sensor' ;
            'TELHS_SYS1 PT18 Mon.mat', 'pt18', 'sensor' ;
            'TELHS_SYS1 PT25 Mon.mat', 'pt25', 'sensor' ;
            'TELHS_SYS1 PT10 Mon.mat', 'pt10', 'sensor' ;
            'TELHS_SYS1 PT28 Mon.mat', 'pt28', 'sensor' ;
        };
    
    
detailPlots = { 232, 310, 'skew',   [-3   1], 'sensor', {} ; 
                690,  33, 'PV7FBK', [-11 11], 'sensor', {} ;
                690, 381, 'PV8FBK', [-11 11], 'sensor', {} ;
                300,  17, 'pt51',   [0 3000], 'sensor',  {} ;
                525,  26, 'pt21',   [0 3000], 'sensor',  {} ;
                282, 567, 'pt46',   [0 3000], 'sensor',  {} ;
                529, 567, 'pt18',   [0 3000], 'sensor',  {} ;
                844, 567, 'pt25',   [0 3000], 'sensor',  {} ;
               1005, 567, 'pt10',   [0 3000], 'sensor',  {} ;
                897, 229, 'pt28',   [0   50], 'sensor',  {} ;
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
