%% Flow Control Valve - Positioner and Controller Performance Analysis
%
%   Calculates absolute error
%   Calculates latency
%



%% Data Set Selection
config = MDRTConfig.getInstance;
dataDir=uigetdir(config.dataArchivePath);

if ~dataDir; disp('Thank you for shopping at MARS'); exit; end


%% Valve/Data file definitions

valves = struct('LO2',struct('P2013',[],'P2014',[]), ...
                'RP1',struct('P1014',[],'P1015',[]) );

valves.LO2.P2013.cmd.filename = '2013 LO2 PCVNO-2013 Globe Valve Cmd Param.mat';
valves.LO2.P2013.cmd.fullfile = fullfile(dataDir, 'data', valves.LO2.P2013.cmd.filename);

valves.LO2.P2013.mon.filename = '2013 LO2 PCVNO-2013 Globe Valve Mon.mat';
valves.LO2.P2013.mon.fullfile = fullfile(dataDir, 'data', valves.LO2.P2013.mon.filename);

valves.LO2.P2014.cmd.filename = '2014 LO2 PCVNO-2014 Globe Valve Cmd Param.mat';
valves.LO2.P2014.cmd.fullfile = fullfile(dataDir, 'data', valves.LO2.P2014.cmd.filename);

valves.LO2.P2014.mon.filename = '2014 LO2 PCVNO-2014 Globe Valve Mon.mat';
valves.LO2.P2014.mon.fullfile = fullfile(dataDir, 'data', valves.LO2.P2014.mon.filename);



%% Load data
try 
    s = load(valves.LO2.P2013.cmd.fullfile, 'fd');
    valves.LO2.P2013.cmd.fd = s.fd;

    s = load(valves.LO2.P2013.mon.fullfile, 'fd');
    valves.LO2.P2013.mon.fd = s.fd;

    s = load(valves.LO2.P2014.cmd.fullfile, 'fd');
    valves.LO2.P2014.cmd.fd = s.fd;

    s = load(valves.LO2.P2014.mon.fullfile, 'fd');
    valves.LO2.P2014.mon.fd = s.fd;
catch
    disp('unable to load data files - check file names and paths');
    
end


%%



v = valves.LO2.P2013;

% newTime = sort([v.cmd.fd.ts.Time;v.mon.fd.ts.Time]);
newTime = v.cmd.fd.ts.Time;

v.cmd.fd.ts.setinterpmethod('zoh')
v.command  = v.cmd.fd.ts.resample(newTime);
v.position = v.mon.fd.ts.resample(newTime);


%% Calculate Errors

abserr = v.position-v.command;



%% Plot

fig = makeMDRTPlotFigure;
%	Page setup for landscape US Letter
        graphsInFigure = 1;
        graphsPlotGap = 0.05;
        GraphsPlotMargin = 0.06;
        numberOfSubplots = 3;
        
        legendFontSize = [8];
        
hax = MDRTSubplot(numberOfSubplots, 1, graphsPlotGap, ... 
                  GraphsPlotMargin, GraphsPlotMargin);
                            

axes(hax(1));
stairs(v.cmd.fd.ts.Time, v.cmd.fd.ts.Data, 'r', 'DisplayName', 'Command');
hold on
stairs(v.mon.fd.ts.Time, v.mon.fd.ts.Data, 'b', 'DisplayName', 'Position');
legend('show')

axes(hax(2));
area(abserr.Time, abs(abserr.Data), 'displayname', 'Position Error');
legend('show')

plotStyle;


% 
% 
% stairs(newTime, v.position.Data, 'b', 'DisplayName', 'Position');
% stairs(newTime, v.command.Data,  'r', 'DisplayName', 'Command');








