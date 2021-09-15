config = MDRTConfig.getInstance;

dataFolder = '/Users/nick/onedrive/Virginia Commercial Space Flight Authority/Pad 0A - Documents/General/Documentation Development/NCs/Archive_Closed/NC-1273 DVNC2031 and DCVNC2097/OP-110_fm_muscle/2021-05-20 - 2021-05-20 - NC1273 OP110 Muscle Droop/data';


[mAx, fh, axPair] = makeManyMDRTSubplots(6, 'VNO1 Actuation', ...
                'newStyle',     true, ...
                'plotsHigh',    2,      'plotsWide',    3, ... 
                'groupAxesBy',  2);



%%           
            
PressFiles = {  '5903 GN2 PT-5903 Press Sensor Mon.mat';
                '5070 GN2 PT-5070 Press Sensor Mon.mat' 
                };

ValveFiles = {  '2029 LO2 PCVNO-2029 Globe Valve Mon.mat';
                '2029 LO2 PCVNO-2029 Globe Valve Cmd Param.mat'
                };
            
%%
for n = 1:length(axPair) 
    axPair(n,1).addFDfromFile(fullfile(dataFolder,PressFiles{1}));
    axPair(n,1).addFDfromFile(fullfile(dataFolder,PressFiles{2}));

    axPair(n,2).addFDfromFile(fullfile(dataFolder,ValveFiles{1}));
    axPair(n,2).addFDfromFile(fullfile(dataFolder,ValveFiles{2}));
    
    dynamicDateTicks([axPair(n,1).hAx, axPair(n,2).hAx]);
    linkaxes([axPair(n,1).hAx, axPair(n,2).hAx], 'x')
    axPair(n,1).hAx.YLim = [92 102];
    axPair(n,2).hAx.YLim = [-1 101];
end

%% 
load(fullfile(dataFolder, 'timeline.mat'));
for n = 1:numel(timeline.milestone);
    for k = 1:numel(axPair)
        MDRTEvent(timeline.milestone(n), axPair(k));
    end
end

%% 
load(fullfile(dataFolder, ValveFiles{2}))
comDiff = diff(fd.ts.Data);
comInd = find(comDiff > 0) + 1;
comTime = fd.ts.Time(comInd);

oneSec = 1 / 24 / 60 / 60;

thisAx = axPair(1,1).hAx;
for n = 1:length(comTime)
    tc = comTime(n);
    t0 = tc - 2*oneSec;
    tf = tc + 10*oneSec;
    
    setDateAxes(thisAx, 'XLim', [t0 tf])
    
    keyboard
    
end
    


