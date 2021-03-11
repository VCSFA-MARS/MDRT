p1 = '/Users/nick/data/archive/2020-09-30 - NG-14 Scrub/data/'
p2 = '/Users/nick/data/archive/2020-10-02 - NG-14 Launch/data/'
p3 = '/Users/nick/data/imported/2020-10-02 - NG-14 Stop Flow/data/'
% %% 
% dataFiles = { '2015 LO2 FM-2015 Coriolis Meter Mon.mat';
%               '2016 LO2 FM-2016 Coriolis Meter Mon.mat'
%               '2010 LO2 DCVNO-2010 State.mat';
%               '2013 LO2 PCVNO-2013 State.mat';
%               '2014 LO2 PCVNO-2014 State.mat';
%               '2029 LO2 PCVNO-2029 State.mat'};
%           
%           'LO2 Flow Control Max Value.mat'
%           'LO2 Flow Control Min Value.mat'
%           
% for n = 1:numel(dataFiles)
%     disp(sprintf('Appending %s data', dataFiles{n} ))
%     f1 = load(fullfile(p1, dataFiles{n}));
%     f2 = load(fullfile(p2, dataFiles{n}));
% 
%     nts = f1.fd.ts.append(f2.fd.ts);
%     
%     fd = f1.fd;
%     fd.ts = nts;
%     
%     save(fullfile(p3, dataFiles{n}), 'fd')
%     
% end
% 
% %%
% 
% hold on;
% 
% dataFiles = {   'LO2 Flow Control Max Value.mat';
%                 'LO2 Flow Control Min Value.mat' };
% 
% scaleFactor = [1.05, 0.95];
%             
%             
% for n = 1:numel(dataFiles);
%     load(fullfile(p2, dataFiles{n}));
%     stairs(fd.ts.Time, fd.ts.Data * scaleFactor(n), '--r')
% end

%% 
fig = makeMDRTPlotFigure;
%	Page setup for landscape US Letter
    graphsInFigure = 1;
    graphsPlotGap = 0.05;
    GraphsPlotMargin = 0.06;
    numberOfSubplots = 3;

    legendFontSize = [8];

subPlotAxes = MDRTSubplot(  numberOfSubplots, ...
                            1,                      graphsPlotGap, ... 
                            GraphsPlotMargin,       GraphsPlotMargin);

linkaxes(subPlotAxes, 'x')
dynamicDateTicks

%% 
f1 = '2014 LO2 PCVNO-2014 Globe Valve Mon.mat';
f2 = '2014 LO2 PCVNO-2014 Globe Valve Cmd Param.mat';

% f1 = '2059 LO2 PCVNC-2059 Globe Valve Mon.mat';
% f2 = '2059 LO2 PCVNC-2059 Globe Valve Cmd Param.mat';


data = struct;

t = load(fullfile(p1, f1));
data.pos = t.fd;

t = load(fullfile(p1, f2));
data.cmd = t.fd;

% Strip duplicate values
    td = [data.cmd.ts.Time, data.cmd.ts.Data];
    [C,IA,~] = unique(data.cmd.ts.Time,'rows');
    
    uTime = C;
    uData = data.cmd.ts.Data(IA);
    
    tempCmdts = timeseries(uData, uTime)
    tempCmdts.Name = data.cmd.ts.Name
    data.cmd.ts = tempCmdts;

axes(subPlotAxes(1));
hold on
h1 = stairs(data.pos.ts.Time, data.pos.ts.Data, ...
        'DisplayName',  sprintf('%s-%s', data.pos.Type, data.pos.ID))

h2 = stairs(data.cmd.ts.Time, data.cmd.ts.Data, '--r', ...
        'DisplayName',  sprintf('%s-%s Cmd', data.pos.Type, data.pos.ID))

%%

timeVect = data.pos.ts.Time;
cmdVect = zeros(size(timeVect));
errVect = zeros(size(timeVect));




%% Make a command vector that matches the position vector's time vector

for i=1:numel(timeVect);
    
    tdata = data.cmd.ts.getsampleusingtime(timeVect(1), timeVect(i));
    
    if isempty(tdata.Data)
        cmdVect(i) = 0;
    else
        cmdVect(i) =  tdata.Data(end);
    end
end

cmdValue = resample(data.cmd.ts, timeVect, 'zoh')

%%

posValue = data.pos.ts;

errValue = posValue - cmdValue;
errValue.Name = 'Error Value'


axes(subPlotAxes(2));

h3 = stairs(errValue.Time, errValue.Data, 'DisplayName',  errValue.Name)

%% Rate of change of Error

oneHr = 1/24;
oneMin = oneHr/60;
oneSec = oneMin/60;

dd = diff(errValue.Data);
dt = diff(errValue.Time);
tv = errValue.Time(1:end-1);

errRate = timeseries(dd./dt .* oneSec, tv, 'Name', 'dE/dt')
axes(subPlotAxes(3))

h4 = stairs(errRate.Time, errRate.Data, 'DisplayName', errRate.Name)


%%


    
    