dataFolder='/Users/nick/onedrive/Virginia Commercial Space Flight Authority/Pad 0A - Documents/General/90-Combined Systems/Launch Data/MDRT Data/2021-02-19_NG-15_Launch/data';

timelineFile=fullfile(dataFolder, 'timeline.mat');

load(timelineFile);
fds={timeline.milestone.FD}';

%% Valve Files

valveFiles = {  '2097 LO2 DCVNC-2097 Ball Valve Ctl Param.mat' ;
                '2093 LO2 DCVNC-2093 Ball Valve Ctl Param.mat' ;
                '2032 LO2 DCVNO-2032 Ball Valve Ctl Param.mat' ;
                '3025 LN2 DCVNC-3025 Ball Valve Ctl Param.mat' ;
                '3026 LN2 DCVNO-3026 Ball Valve Ctl Param.mat' ;
                '2031 LO2 DCVNC-2031 Ball Valve Ctl Param.mat' ;
                };

valveTitles = { 'DCVNC-2097' ;
                'DCVNC-2093' ;
                'DCVNO-2032' ;
                'DCVNC-3025' ;
                'DCVNO-3026' ;
                'DCVNC-2031' ;
                };

%% Make Figures and Plots

[plotAxes, figHandles] = makeManyMDRTSubplots(valveTitles, 'NG-15 CB11 DO Commands');

for n = 1:numel(valveFiles)
    s = load(fullfile(dataFolder, valveFiles{n}) );
    axes(plotAxes(n));
        stairs(s.fd.ts.Time, s.fd.ts.Data, 'DisplayName', s.fd.ts.Name);
        ylim([ -0.1 , 1.1 ]);
        plotAxes(n).Title.String = valveTitles{n};
        reviewPlotAllTimelineEvents(timeline);
        dynamicDateTicks;
end
            

linkaxes(plotAxes, 'x');

%% Constants

onehr = 1/24;
onemin = onehr/60;
onesec = onemin/60;

