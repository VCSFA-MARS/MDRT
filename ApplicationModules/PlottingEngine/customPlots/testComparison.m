

starts =  [ 737830.945304;
            737832.822360;
            737833.187794;
            737833.978697;
          ];

      
oneHr  = 1/24;
oneMin = oneHr/60/2; 
threeSec = (oneMin/60)*3;
        
makeMDRTPlotFigure
MDRTSubplot(2,2)

ax = ans;

mon = load('/Users/nick/data/archive/2020-02-09_NG-13/data/2014 LO2 PCVNO-2014 Globe Valve Mon.mat');
cmd = load('/Users/nick/data/archive/2020-02-09_NG-13/data/2014 LO2 PCVNO-2014 Globe Valve Cmd Param.mat');
axes(ax(1));
title('Launch Attempt');
    plot(mon.fd.ts.Time, mon.fd.ts.Data, '-b', 'displayname', '2014 Position')
    hold on
    stairs(cmd.fd.ts.Time, cmd.fd.ts.Data, '-r', 'displayname', '2014 Command')
    dynamicDateTicks
    ylim([-1, 101]);
    xlim([starts(1)-threeSec, starts(1)+oneMin]);
    
mon = load('/Users/nick/data/imported/2020-02-11 - LOX Valve Checks/data/2014 LO2 PCVNO-2014 Globe Valve Mon.mat');
cmd = load('/Users/nick/data/imported/2020-02-11 - LOX Valve Checks/data/2014 LO2 PCVNO-2014 Globe Valve Cmd Param.mat');
axes(ax(3));
title('Post Launch Ambient');
    plot(mon.fd.ts.Time, mon.fd.ts.Data, '-b', 'displayname', '2014 Position')
    hold on
    stairs(cmd.fd.ts.Time, cmd.fd.ts.Data, '-r', 'displayname', '2014 Command')
    dynamicDateTicks
    ylim([-1, 101]);
    xlim([starts(2)-threeSec, starts(2)+oneMin]);
    
mon = load('/Users/nick/data/imported/2020-02-11 - 2014 Valve Timing/data/2014 LO2 PCVNO-2014 Globe Valve Mon.mat');
cmd = load('/Users/nick/data/imported/2020-02-11 - 2014 Valve Timing/data/2014 LO2 PCVNO-2014 Globe Valve Cmd Param.mat');
axes(ax(2));
title('Post Repair Ambient');
    plot(mon.fd.ts.Time, mon.fd.ts.Data, '-b', 'displayname', '2014 Position')
    hold on
    stairs(cmd.fd.ts.Time, cmd.fd.ts.Data, '-r', 'displayname', '2014 Command')
    dynamicDateTicks
    ylim([-1, 101]);
    xlim([starts(3)-threeSec, starts(3)+oneMin]);
    
    
mon = load('/Users/nick/data/imported/2020-02-12 - LO2 Testing/data/2014 LO2 PCVNO-2014 Globe Valve Mon.mat');
cmd = load('/Users/nick/data/imported/2020-02-12 - LO2 Testing/data/2014 LO2 PCVNO-2014 Globe Valve Cmd Param.mat');
axes(ax(4));
title('Post Repair Cryo');
    plot(mon.fd.ts.Time, mon.fd.ts.Data, '-b', 'displayname', '2014 Position')
    hold on
    stairs(cmd.fd.ts.Time, cmd.fd.ts.Data, '-r', 'displayname', '2014 Command')
    dynamicDateTicks
    ylim([-1, 101]);
    xlim([starts(4)-threeSec, starts(4)+oneMin]);
    
    