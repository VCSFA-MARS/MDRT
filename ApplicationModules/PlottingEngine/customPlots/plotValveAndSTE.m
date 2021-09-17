dataFolder='/Users/nick/data/imported/2021-06-09 - NC-1273 - LO2 Flow Test/data';

paramFile = '2031 LO2 DCVNC-2031 Ball Valve Ctl Param.mat';
stateFile = '2031 LO2 DCVNC-2031 State.mat';
steFile   = 'STE 2031-PT Press Sensor Mon.mat';
tempFile  = 'STE TC01.mat';

% paramFile = '2097 LO2 DCVNC-2097 Ball Valve Ctl Param.mat'
% stateFile = '2097 LO2 DCVNC-2097 State.mat'
% steFile   = 'STE 2097-PT Press Sensor Mon.mat'
% tempFile  = 'STE TC06.mat'

for twoPasses = 1:2

findNumberPattern = '[A-Z]+-[0-9]+' ;
findNum = regexp(paramFile, findNumberPattern, 'match');

%% Constant Definitions

oneHour = 1/24;
oneMin = oneHour/60;
oneSec = oneMin/60;
window = [-5*oneSec, 15*oneSec];

sequenceTimes = [
    datenum('09-Jun-2021 19:10:52'), datenum('09-Jun-2021 19:10:52')+ 11*oneMin; %nominal
    datenum('09-Jun-2021 19:27:04'), datenum('09-Jun-2021 19:27:04')+ 11*oneMin; %asCommanded
    datenum('09-Jun-2021 20:10:05'), datenum('09-Jun-2021 20:10:05')+ 11*oneMin; %asActuated
    datenum('09-Jun-2021 15:20:18'), 0;                                          %start of chilldown
    datenum('09-Jun-2021 15:20:18'), datenum('09-Jun-2021 16:25:00');            %chilldown interval
    datenum('09-Jun-2021 16:25:00'), datenum('09-Jun-2021 18:20:00');            %cryo-lockup
];

%% Find issued commands and times

load(fullfile(dataFolder, paramFile));


% Find all command indices

cmdParms = fd.ts.Data;
cmdTimes = fd.ts.Time;

changeInds = [  1; 
                find([0;diff(cmdParms)]) ; 
                length(cmdParms) ];

if cmdParms(changeInds(end)) == cmdParms(changeInds(end-1))
    changeInds(end) = [];
end
    
energizeInds = find(cmdParms(changeInds));
deenergizeInds = find(~cmdParms(changeInds));

energizeTimes   = cmdTimes(changeInds(energizeInds));
deenergizeTimes = cmdTimes(changeInds(deenergizeInds));


%% Load All Data

data = struct('param', [], 'state', [], 'ste', [], 'temp', []);

s = load(fullfile(dataFolder, paramFile));
    data.param = s.fd.ts;
s = load(fullfile(dataFolder, stateFile));
    data.state = s.fd.ts;
s = load(fullfile(dataFolder, steFile));
    data.ste = s.fd.ts;
s = load(fullfile(dataFolder, tempFile));
    data.temp = s.fd.ts;




%% Plot full family

[axHandles, figHandles, axPairArray] = makeManyMDRTSubplots( ...
...%                 {'Valve State', 'Actuator Pressure', 'Valve Temp';
...%                  'Valve State', 'Actuator Pressure', 'Valve Temp'}, ...
                 {'Valve State', 'Actuator Pressure', ;
                 'Valve State', 'Actuator Pressure', }, ...
                findNum, ...
                'plotswide',            2, ...
                'plotshigh',            2, ...
                'groupaxesby',          2);

linkaxes(axHandles, 'x');
dynamicDateTicks(axHandles, 'link');            
%% Energize
t0 = energizeTimes(1);

for n = 1:numel(energizeTimes)
    tf = energizeTimes(n);
    deltaT = tf - t0;
    
    thisTime = tf + window;
    thisTime(1) = thisTime(1) - (10.1 * oneMin);
    
    axes(axPairArray(1,1))
    
        thisTS = data.state.getsampleusingtime(thisTime(1), thisTime(2) );
        stairs(thisTS.Time - tf, thisTS.Data,'displayname', sprintf('%d', n));
        hold on;
        
    axes(axPairArray(1,2))
        thisTS = data.ste.getsampleusingtime(thisTime(1), thisTime(2));
        stairs(thisTS.Time - tf, thisTS.Data, 'displayname', sprintf('%d', n));
        hold on;
        
%     axes(axPairArray(1,3))
%         thisTS = data.temp.getsampleusingtime(thisTime(1), thisTime(2));
%         stairs(thisTS.Time - tf, thisTS.Data, 'displayname', sprintf('%d', n));
%         hold on;
    
end


axes(axPairArray(1,1))
    hold on
    tf = energizeTimes(n);    
    thisTime = tf + window;
    
    
    thisTS = data.state.getsampleusingtime(thisTime(1), thisTime(2));
    stairs(thisTS.Time - tf, thisTS.Data, '-r');
    hold on;
        
 setDateAxes(axPairArray(1,:), 'XLim', window) 
        
 
 
 %% De-energize
t0 = deenergizeTimes(1);

for n = 1:numel(deenergizeTimes)
    tf = deenergizeTimes(n);
    deltaT = tf - t0;
    
    thisTime = tf + window;
    thisTime(1) = thisTime(1) - (10.1 * oneMin);
    
    axes(axPairArray(2,1))
    
        thisTS = data.state.getsampleusingtime(thisTime(1), thisTime(2) );
        stairs(thisTS.Time - tf, thisTS.Data,'displayname', sprintf('%d', n));
        hold on;
        
    axes(axPairArray(2,2))
        thisTS = data.ste.getsampleusingtime(thisTime(1), thisTime(2));
        stairs(thisTS.Time - tf, thisTS.Data, 'displayname', sprintf('%d', n));
        hold on;
        
%     axes(axPairArray(2,3))
%         thisTS = data.temp.getsampleusingtime(thisTime(1), thisTime(2));
%         stairs(thisTS.Time - tf, thisTS.Data, 'displayname', sprintf('%d', n));
%         hold on;
    
end


axes(axPairArray(2,1))
    hold on
    tf = deenergizeTimes(n);    
    thisTime = tf + window;
    thisTS = data.state.getsampleusingtime(thisTime(1), thisTime(2));
    stairs(thisTS.Time - tf, thisTS.Data, '-r');
    hold on;
        
 setDateAxes(axPairArray(2,:), 'XLim', window) 
 
%% Plot First Test - Energize

makeMDRTPlotFigure;
hax = MDRTSubplot(1, 1);
dynamicDateTicks
suptitle(sprintf('%s %s', findNum{1}, 'Nominal DBO/TO - Energize'))
 
 for n = 1:numel(energizeTimes)
    tf = energizeTimes(n);
    thisTime = tf + window;
    thisTime(1) = thisTime(1) - (10.1 * oneMin);
    
    if tf < sequenceTimes(1,1) || tf > sequenceTimes(1,2)
        continue
    end

    thisTS = data.ste.getsampleusingtime(thisTime(1), thisTime(2));
    stairs(thisTS.Time - tf, thisTS.Data, 'displayname', sprintf('%d', n));
    hold on;
     
 end 
 
setDateAxes(hax, 'XLim', window) 
 
 
%% Plot Second Test - Energize

makeMDRTPlotFigure;
hax = MDRTSubplot(1, 1);
dynamicDateTicks
suptitle(sprintf('%s %s', findNum{1}, 'As Commanded DBO/TO - Energize'))

 for n = 1:numel(energizeTimes)
    tf = energizeTimes(n);
    thisTime = tf + window;
    thisTime(1) = thisTime(1) - (10.1 * oneMin);
    
    if tf < sequenceTimes(2,1) || tf > sequenceTimes(2,2)
        continue
    end

    thisTS = data.ste.getsampleusingtime(thisTime(1), thisTime(2));
    stairs(thisTS.Time - tf, thisTS.Data, 'displayname', sprintf('%d', n));
    hold on;
     
 end 
 
setDateAxes(hax, 'XLim', window) 
 
  
%% Plot Third Test - Energize

makeMDRTPlotFigure;
hax = MDRTSubplot(1, 1);
dynamicDateTicks
suptitle(sprintf('%s %s', findNum{1}, 'As Actuated DBO/TO - Energize'))

 for n = 1:numel(energizeTimes)
    tf = energizeTimes(n);
    thisTime = tf + window;
    thisTime(1) = thisTime(1) - (10.1 * oneMin);
    
    if tf < sequenceTimes(3,1) || tf > sequenceTimes(3,2)
        continue
    end

    thisTS = data.ste.getsampleusingtime(thisTime(1), thisTime(2));
    stairs(thisTS.Time - tf, thisTS.Data, 'displayname', sprintf('%d', n));
    hold on;
     
 end 
 
setDateAxes(hax, 'XLim', window) 
 
  
  
%% Plot First Test - DeEnergize

makeMDRTPlotFigure;
hax = MDRTSubplot(1, 1);
dynamicDateTicks
suptitle(sprintf('%s %s', findNum{1}, 'Nominal DBO/TO - De-energize'))
 
 for n = 1:numel(deenergizeTimes)
    tf = deenergizeTimes(n);
    thisTime = tf + window;
    thisTime(1) = thisTime(1) - (10.1 * oneMin);
    
    if tf < sequenceTimes(1,1) || tf > sequenceTimes(1,2)
        continue
    end

    thisTS = data.ste.getsampleusingtime(thisTime(1), thisTime(2));
    stairs(thisTS.Time - tf, thisTS.Data, 'displayname', sprintf('%d', n));
    hold on;
     
 end 
 
setDateAxes(hax, 'XLim', window) 
 
 
%% Plot Second Test - DeEnergize

makeMDRTPlotFigure;
hax = MDRTSubplot(1, 1);
dynamicDateTicks
suptitle(sprintf('%s %s', findNum{1}, 'As Commanded DBO/TO - De-energize'))

 for n = 1:numel(deenergizeTimes)
    tf = deenergizeTimes(n);
    thisTime = tf + window;
    thisTime(1) = thisTime(1) - (10.1 * oneMin);
    
    if tf < sequenceTimes(2,1) || tf > sequenceTimes(2,2)
        continue
    end

    thisTS = data.ste.getsampleusingtime(thisTime(1), thisTime(2));
    stairs(thisTS.Time - tf, thisTS.Data, 'displayname', sprintf('%d', n));
    hold on;
     
 end 
 
setDateAxes(hax, 'XLim', window) 

  
%% Plot Third Test - DeEnergize
 
makeMDRTPlotFigure;
hax = MDRTSubplot(1, 1);
dynamicDateTicks
suptitle(sprintf('%s %s', findNum{1}, 'As Actuated DBO/TO - De-energize'))
 
 for n = 1:numel(deenergizeTimes)
    tf = deenergizeTimes(n);
    thisTime = tf + window;
    thisTime(1) = thisTime(1) - (10.1 * oneMin);
    
    if tf < sequenceTimes(3,1) || tf > sequenceTimes(3,2)
        continue
    end

    thisTS = data.ste.getsampleusingtime(thisTime(1), thisTime(2));
    stairs(thisTS.Time - tf, thisTS.Data, 'displayname', sprintf('%d', n));
    hold on;
     
 end 
 
  setDateAxes(hax, 'XLim', window) 
 

  
  
%% Plot All Pre-test - Energize
 
makeMDRTPlotFigure;
hax = MDRTSubplot(1, 1);
dynamicDateTicks
suptitle(sprintf('%s %s', findNum{1}, 'Pre-test - Energize'))
 
 for n = 1:numel(energizeTimes)
    tf = energizeTimes(n);
    thisTime = tf + window;
    thisTime(1) = thisTime(1) - (10.1 * oneMin);
    
    if tf > sequenceTimes(4,1)
        continue
    end

    thisTS = data.ste.getsampleusingtime(thisTime(1), thisTime(2));
    stairs(thisTS.Time - tf, thisTS.Data, 'displayname', sprintf('%d', n));
    hold on;
     
 end 
 
  setDateAxes(hax, 'XLim', window)   
%% Plot All Pre-test - DeEnergize
 
 makeMDRTPlotFigure;
 hax = MDRTSubplot(1, 1);
 dynamicDateTicks
suptitle(sprintf('%s %s', findNum{1}, 'Pre-test - De-energize'))
 
 for n = 1:numel(deenergizeTimes)
    tf = deenergizeTimes(n);
    thisTime = tf + window;
    thisTime(1) = thisTime(1) - (10.1 * oneMin);
    
    if tf > sequenceTimes(4,1)
        continue
    end

    thisTS = data.ste.getsampleusingtime(thisTime(1), thisTime(2));
    stairs(thisTS.Time - tf, thisTS.Data, 'displayname', sprintf('%d', n));
    hold on;
     
 end 
 
  setDateAxes(hax, 'XLim', window) 
  
  
  
  
  
  
%% Plot All Chilldown - Energize
 
makeMDRTPlotFigure;
hax = MDRTSubplot(1, 1);
dynamicDateTicks
suptitle(sprintf('%s %s', findNum{1}, 'Chilldown - Energize'))
 
 for n = 1:numel(energizeTimes)
    tf = energizeTimes(n);
    thisTime = tf + window;
    thisTime(1) = thisTime(1) - (10.1 * oneMin);

    if tf < sequenceTimes(5,1) || tf > sequenceTimes(5,2)
        continue
    end

    thisTS = data.ste.getsampleusingtime(thisTime(1), thisTime(2));
    stairs(thisTS.Time - tf, thisTS.Data, 'displayname', sprintf('%d', n));
    hold on;
     
 end 
 
setDateAxes(hax, 'XLim', window)   


%% Plot All Chilldown - DeEnergize
 
makeMDRTPlotFigure;
hax = MDRTSubplot(1, 1);
dynamicDateTicks
suptitle(sprintf('%s %s', findNum{1}, 'Chilldown - De-energize'))
 
 for n = 1:numel(deenergizeTimes)
    tf = deenergizeTimes(n);
    thisTime = tf + window;
    thisTime(1) = thisTime(1) - (10.1 * oneMin);
    
    if tf < sequenceTimes(5,1) || tf > sequenceTimes(5,2)
        continue
    end

    thisTS = data.ste.getsampleusingtime(thisTime(1), thisTime(2));
    stairs(thisTS.Time - tf, thisTS.Data, 'displayname', sprintf('%d', n));
    hold on;
     
 end 
 
setDateAxes(hax, 'XLim', window)   




%% Plot All Lockup - Energize
 
makeMDRTPlotFigure;
hax = MDRTSubplot(1, 1);
dynamicDateTicks
suptitle(sprintf('%s %s', findNum{1}, 'Lockup - Energize'))
 
 for n = 1:numel(energizeTimes)
    tf = energizeTimes(n);
    thisTime = tf + window;
    thisTime(1) = thisTime(1) - (10.1 * oneMin);

    if tf < sequenceTimes(6,1) || tf > sequenceTimes(6,2)
        continue
    end

    thisTS = data.ste.getsampleusingtime(thisTime(1), thisTime(2));
    stairs(thisTS.Time - tf, thisTS.Data, 'displayname', sprintf('%d', n));
    hold on;
     
 end 
 
setDateAxes(hax, 'XLim', window)   


%% Plot All Lockup - DeEnergize
 
makeMDRTPlotFigure;
hax = MDRTSubplot(1, 1);
dynamicDateTicks
suptitle(sprintf('%s %s', findNum{1}, 'Lockup - De-energize'))
 
 for n = 1:numel(deenergizeTimes)
    tf = deenergizeTimes(n);
    thisTime = tf + window;
    thisTime(1) = thisTime(1) - (10.1 * oneMin);
    
    if tf < sequenceTimes(6,1) || tf > sequenceTimes(6,2)
        continue
    end

    thisTS = data.ste.getsampleusingtime(thisTime(1), thisTime(2));
    stairs(thisTS.Time - tf, thisTS.Data, 'displayname', sprintf('%d', n));
    hold on;
     
 end 
 
setDateAxes(hax, 'XLim', window)   





































%% End of first valve 

paramFile = '2097 LO2 DCVNC-2097 Ball Valve Ctl Param.mat'
stateFile = '2097 LO2 DCVNC-2097 State.mat'
steFile   = 'STE 2097-PT Press Sensor Mon.mat'
tempFile  = 'STE TC06.mat'

end