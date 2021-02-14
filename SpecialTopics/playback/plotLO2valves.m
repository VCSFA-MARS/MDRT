function replayMDRTData

dataPath = '/Users/nick/data/archive/2019-11-01 - NG-12/data'
% dataPath = '/Users/nick/data/archive/2019-04-16 - NG-11 Launch/data';
% dataPath = '/Users/nick/data/archive/2018-11-16 - NG10 Topoff/data';
% dataPath = '/Users/nick/data/archive/2018-05-20 - OA-9 Launch/data';

<<<<<<< Updated upstream
config = getConfig;
=======
dataPath = uigetdir(dataPath, 'Select data folder');
>>>>>>> Stashed changes

% [x,y,button] = ginput(1)


dataPath = config.dataFolderPath;
dataPath = uigetdir(dataPath, 'Select data folder')

I = imread('LO2-schematic.png');
hf = figure;
addToolButtonsToPlot(hf);

hap = axes();
hap.Units = 'normalized';
hap.Position(2) = 0.28

hi = imagesc(I);

p = hap.Position;
% had = axes('Position', [0,0, 1, p(2)]);
had = axes('Position', [0,0, 1, 0.28]);

valveCenters = [ 341,   541;
                 329,   691;
                 329,   782;
                 557,   723;
                 619,   603;
                 800,   540;
                 783,   660;
                1651,   691;
                 922,   812;
                 586,   871;
                1683,   932];
            
valveNames = {  'd2031';
                'p2029';
                'd2097';
                'd2032';
                'd2027';
                'd2035';
                'd2099';
                'd2040';
                'd4070';
                'd4193';
                'd4089'};
            
tcPos = [   280     730;
            217     661;
            327     385;
            523     510;
            851     512;
            1604    746];
            
tsNames = { 'pm2029';
            't2908';
            't2910';
            't2911';
            't2912';
            't4920'};
            
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

<<<<<<< Updated upstream
% flowData = '2015 LO2 FM-2015 Coriolis Meter Mon.mat';
flowData = '2909 LO2 PT-2909 Press Sensor Mon.mat';
=======
flowData = '2015 LO2 FM-2015 Coriolis Meter Mon.mat';
% flowData = '2909 LO2 PT-2909 Press Sensor Mon.mat';
>>>>>>> Stashed changes
% flowData = '4919 Ghe PT-4919 Press Sensor Mon.mat';

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
      
   links = {   
        '2027 LO2 DCVNO-2027 State.mat', 'd2027', 'valve';
        '2029 LO2 PCVNO-2029 State.mat', 'p2029', 'valve';
        '2031 LO2 DCVNC-2031 State.mat', 'd2031', 'valve';
        '2032 LO2 DCVNO-2032 State.mat', 'd2032', 'valve';
        '2035 LO2 DCVNO-2035 State.mat', 'd2035', 'valve';
        '2040 LO2 DCVNO-2040 State.mat', 'd2040', 'valve';
        '2097 LO2 DCVNC-2097 State.mat', 'd2097', 'valve';
        '2099 LO2 DCVNO-2099 State.mat', 'd2099', 'valve';
        '4070 Ghe DCVNC-4070 State.mat', 'd4070', 'valve';
        '4193 Ghe DCVNC-4193 State.mat', 'd4193', 'valve';
        '4089 Ghe DCVNO-4089 State.mat', 'd4089', 'valve';
        '2029 LO2 PCVNO-2029 Globe Valve Mon.mat', 'pm2029', 'sensor';
        '2908 LO2 TC-2908 Temp Sensor Mon.mat', 't2908', 'sensor';
        '2910 LO2 TC-2910 Temp Sensor Mon.mat', 't2910', 'sensor';
        '2911 LO2 TC-2911 Temp Sensor Mon.mat', 't2911', 'sensor';
        '2912 LO2 TC-2912 Temp Sensor Mon.mat', 't2912', 'sensor';
        '4920 Ghe TC-4920 Temp Sensor Mon.mat', 't4920', 'sensor'};
    
    
   
 fds = struct;
 
 n = length(links);
 
combinedTimeVector = [];
 
 for i = 1:n
     try         
         temp = load(fullfile(dataPath, links{i,1}));
         fd.(links{i,2}) = temp.fd;
         combinedTimeVector = vertcat(combinedTimeVector, temp.fd.ts.Time);
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
        updateGUIfromTime(pt(1));
        
    end





















end