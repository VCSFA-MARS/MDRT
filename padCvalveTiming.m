config = MDRTConfig.getInstance;
fdIndexFile =fullfile(config.workingDataPath, 'AvailableFDs.mat');
padCvalveConfigFile = 'Pad0C_ValveGrouping.xlsx';

OPEN_STATE = 1;
CLOSED_STATE = 0;
TRANSITION_STATE = 2;
ERROR_STATE = 3;
DEFAULT_STATE = CLOSED_STATE; % Closed if computation fails
MAX_VALVE_TIME = seconds(30); % duration object, only search in this range

reports = [];

if ~exist(fdIndexFile, 'file')
  fprintf('AvailableFDs.mat index file not present in %s\n', config.workingDataPath)
  return
end

s = load(fullfile(config.workingDataPath, 'AvailableFDs.mat'));
FDList = s.FDList;

% s.FDList(contains(s.FDList(:,1), '317'),1)

configTable = readtable('Pad0C_ValveGrouping.xlsx', ...
  'PreserveVariableNames',true);

% prog_bar = waitbar(0,'Computing Valve Timing from Data Set', 'WindowStyle','modal');

progressbar(0)
progressbar('Computing Valve Timing from Data Set');

for i = 1:height(configTable)
  thisType    = configTable.("Valve Type"){i};
  thisFind    = configTable.("Valve FN"){i};
  thisOpen    = configTable.("Open I/O")(i);
  thisClosed  = configTable.("Closed I/O")(i);
  thisCommand = configTable.("Command I/O")(i);
  thisSigType = configTable.("TRUE State Signal")(i);
  thisValveName = sprintf('%s-%s', thisType, thisFind);

  thisReport = struct('valve', thisValveName, 'open', struct, 'close', struct);

  openFD_str =    FDList{endsWith(FDList(:,1), sprintf('-%d', thisOpen)),1};
  closedFD_str =  FDList{endsWith(FDList(:,1), sprintf('-%d', thisClosed)),1};
  commandFD_str = FDList{endsWith(FDList(:,1), sprintf('-%d', thisCommand)),1};

  if any(contains({openFD_str, closedFD_str, commandFD_str}, '-Ps-'))
    disp('Ya done f*d up, son');
    break
  end



  CFD = load_fd_by_name(commandFD_str);

  com_inds = find(diff(CFD.ts.Data))+1;
  if isempty(com_inds)
    fprintf('\tNo commands found, skipping valve %s\n', thisValveName);
    continue
  end

  fprintf('Processing valve %s-%s\n', thisType, thisFind);
  fprintf('\tOpenFD: %d\t%s\n', thisOpen, openFD_str);
  fprintf('\tClosedFD: %d\t%s\n', thisClosed, closedFD_str);
  fprintf('\tCmdFD: %d\t%s\n', thisCommand, commandFD_str);


  oFD = load_fd_by_name(openFD_str);
  cFD = load_fd_by_name(closedFD_str);

  oSW_inds = find(diff(oFD.ts.Data))+1;
  cSW_inds = find(diff(cFD.ts.Data))+1;

  ct = datetime(cFD.ts.Time(cSW_inds), 'ConvertFrom', 'datenum');
  ot = datetime(oFD.ts.Time(oSW_inds), 'ConvertFrom', 'datenum');
  Ct = datetime(CFD.ts.Time(com_inds), 'ConvertFrom', 'datenum');

  cd = cFD.ts.Data(cSW_inds);
  od = cFD.ts.Data(oSW_inds);
  Cd = cFD.ts.Data(com_inds);

  % Create timetables of switch and commands - only events
  cett = timetable(ct, cd, 'DimensionNames', {'Time', 'Value'});
  oett = timetable(ot, od, 'DimensionNames', {'Time', 'Value'});
  Cett = timetable(Ct, Cd, 'DimensionNames', {'Time', 'Value'});

  % Create timetable of valve state, include start of full data 
  e_times = sort([cett.Time; oett.Time]);
  first_time_dn = min( [cFD.ts.Time(1), cFD.ts.Time(1)]);
  first_time_dt = datetime(first_time_dn, 'ConvertFrom', 'datenum');
  e_times = vertcat(first_time_dt, e_times);
  

  % Handle odd valve wirings
  ON = thisSigType;
  OFF = ~ON;

  states = ones(length(e_times), 1) * DEFAULT_STATE;
  for n = 1:length(e_times)
    thisTime = e_times(n);
    thisDNTime = datenum(thisTime);

    cSw = getsampleusingtime(cFD.ts, 0,thisDNTime).Data(end);
    oSw = getsampleusingtime(oFD.ts, 0,thisDNTime).Data(end);

    % cSw = retime(cett, thisTime, 'previous');
    % oSw = retime(oett, thisTime, 'previous');

    if cSw == ON && oSw == ON
      thisState = 3; % Transitioning
    elseif cSw == ON && oSw == OFF
      thisState = 1; % Open
    elseif cSw == OFF && oSw == ON
      thisState = 0; % Closed
    elseif cSw == OFF && oSw == OFF
      thisState = 2; % Critical
    end

    states(n,:) = [thisState];

  end

  sett = timetable(e_times, states, 'DimensionNames', {'Time', 'Value'});


  
  % Plot Command and State
  if false
    stairs(datetime(CFD.ts.Time, 'ConvertFrom', 'datenum'), CFD.ts.Data, 'DisplayName', 'Command');
    hold on
    plot(datetime(CFD.ts.Time(com_inds), 'ConvertFrom', 'datenum'), CFD.ts.Data(com_inds), 'LineStyle','none', 'Marker','v','Color','r', 'HandleVisibility', 'off');
    % stairs(datetime(oFD.ts.Time, 'ConvertFrom', 'datenum'), oFD.ts.Data + 0.1, 'DisplayName', 'OpenSW');
    % stairs(datetime(cFD.ts.Time, 'ConvertFrom', 'datenum'), cFD.ts.Data +0.2, 'DisplayName', 'CloseSW');
    stairs(e_times, states, 'DisplayName', 'ValveState', 'Marker', 'o', 'Color', 'g', 'DisplayName', 'State');

    hax = gca;
    cmdTime = datetime(CFD.ts.Time(com_inds(1)), 'ConvertFrom', 'datenum');
    hax.XLim = [cmdTime - seconds(3), cmdTime + seconds(30)];
    hax.YLim = hax.YLim + [-0.1, 0.1];

  end


  %% Find all open cycles
  thisOpenReport = struct();
  thisOpenReport.cycles = 0;

  OPEN_CMD = 1;
  if contains(thisType, {'N/O', 'NO'})
    % OPEN is de-energized
    OPEN_CMD = ~OPEN_CMD;
  end

  % Find all open commands
  oCmds = Cett(Cett.Value == OPEN_CMD, :);
  if isempty(oCmds)
    % No open commands were found
    thisReport.open = thisOpenReport;

  else

    openCycleTimes = [];
    for n = 1:height(oCmds)
      timeCmd = oCmds.Time(n);

      % find closest state change within allowable window
      timeWindow = timerange(timeCmd, timeCmd + MAX_VALVE_TIME);
      stateWindow = sett(timeWindow, :);

      l_ind = stateWindow.Value == OPEN_STATE;
      if ~any(l_ind)
        % no open states were found in the time window
        continue;
      end
      open = stateWindow(find(l_ind,1),:);

      this_cycle_time = seconds(open.Time - timeCmd);
      openCycleTimes = vertcat(openCycleTimes, this_cycle_time);

    end
    thisOpenReport.AverageTime = mean(openCycleTimes);
    thisOpenReport.CycleTimes = openCycleTimes;
    thisOpenReport.cycles = numel(openCycleTimes);
    thisReport.open = thisOpenReport;
  end

  

  %% Find all close cycles
  thisCloseReport = struct();
  thisCloseReport.cycles = 0;

  CLOSE_CMD = ~OPEN_CMD;

  % Find all close commands
  cCmds = Cett(Cett.Value == CLOSE_CMD, :);

  if isempty(cCmds)
    % No open commands were found
    thisReport.close = thisCloseReport;

  else
  
    closeCycleTimes = [];
    for n = 1:height(cCmds)
      timeCmd = cCmds.Time(n);

      % find closest state change within allowable window
      timeWindow = timerange(timeCmd, timeCmd + MAX_VALVE_TIME);
      stateWindow = sett(timeWindow, :);

      l_ind = stateWindow.Value == CLOSED_STATE;
      if ~any(l_ind)
        % no open states were found in the time window
        continue;
      end
      close = stateWindow(find(l_ind,1),:);

      this_cycle_time = seconds(close.Time - timeCmd);
      closeCycleTimes = vertcat(closeCycleTimes, this_cycle_time);

    end

    thisCloseReport.AverageTime = mean(closeCycleTimes);
    thisCloseReport.CycleTimes = closeCycleTimes;
    thisCloseReport.cycles = numel(closeCycleTimes);
    thisReport.close = thisCloseReport;

  end

  reports = vertcat(reports, thisReport);

  % waitbar(i/height(configTable), prog_bar, thisValveName)
  progressbar(i/height(configTable))

end


%% Report Output as Table

colnames = {'valve', 'command', 'cycles', 'average', 'cycle_time'};
colTypes = {'string', 'string', 'double', 'double', 'double'};
% T = array2table({''}, {''}, 0, 0, 0, 'VariableNames', colnames);

T = table('Size', [0,5], 'VariableTypes', colTypes, 'VariableNames', colnames);
thisRow = 1;
for i = 1:height(reports)
  thisRep = reports(i);

  newRow = {thisRep.valve, 'open', 0,0,0};
  if thisRep.open.cycles
    newRow = {
      thisRep.valve;
      'open';
      thisRep.open.cycles;
      thisRep.open.AverageTime;
      thisRep.open.CycleTimes
      }';
  end

  T = [T;newRow];

  newRow = {thisRep.valve, 'close', 0,0,0};
  if thisRep.close.cycles
    newRow = {
      thisRep.valve;
      'close';
      thisRep.close.cycles;
      thisRep.close.AverageTime;
      thisRep.close.CycleTimes
      }';
  end

  T = [T;newRow];

end




%% Save Excel File

s = load(fullfile(config.workingDataPath, 'metadata.mat'));
defaultFileName = sprintf('Valve Timing Data for %s', s.metaData.operationName);
setFolder = config.userWorkingPath;

fileTypes = {
  '*.xlsx', 'Excel Spreadsheet (*.xlsx)';
  '*.csv', 'Comma Separated Value (*.csv)';
  '*.*',  'All Files (*.*)'};

[filename, pathname, ext] = uiputfile( fileTypes, ...
                            'Save as', fullfile(setFolder, defaultFileName) );

if ~pathname; return; end

writetable(T, fullfile(pathname, filename))