function [reports, data, T] = processPadCValves(varargin)
%% Analyzes valve data and produces three data products:
%  - reports  : Report structures with command and cycle times
%  - data     : Data (timetables) for plotting
%  - T        : Table representation of reports for excel export
%
% Uses the data set selected in MDRTConfig by default
%
% Keyword Arguments
%   SaveExcel     : [true|false]
%   SaveData      : [true|false]
%   RootFolder    : [str] - full path to data set root (not /data)
%   ProgressFig   : [matlab.ui.Figure] - Parent figure for progress dialog

%% reports struct
% reports is an array of structs, with each struct corresponding to a valve.
% Each report struct has the type ('dcvnc'), the find number, a formatted
% name ('DCVNC-1234'), an array of 'cycles' structs (each with the command 
% and state change data point), and finally an 'errors' array of structs
% containing the failed commands.
% version 1 of cycles has command, command_time, completed_time
% version 1.1 added 'passed' to the cycles

%% data struct
% the output data currently contain ALL data points from the valve command
% and feedback switches. A valve 'State' is computed and stored, consisting
% of just the points at which the state changes (also first and last). It also
% contains a 'commands' array, of just the times at which the command changes.
% state
% commands
% commands_error


%% Default Values

do_save_file      = false; % Write table to Excel
do_save_data      = false; % Write MATLAB data (reports/data)
dataSetRootFolder = '';    % The parent dataset folder, NOT '/data'
progParent        = [];    % if empty, will run standalone progressbar

if length(varargin)>1
  for k = 1:2:length(varargin)

    key = varargin{k};
    val = varargin{k+1};

    switch lower(key)
      case {'saveexcel', 'savefile', 'save', 'writetable'}
        do_save_file = parseFunctionArgument(val, 'logical', do_save_file);

      case {'savedata', 'savereport', 'savereports', 'writedata'}
        do_save_data = parseFunctionArgument(val, 'logical', do_save_data);

      case {'rootfolder', 'datasetfolder'}
        dataSetRootFolder = parseFunctionArgument(val, 'folder', dataSetRootFolder);

      case {'progressfig'}
        progParent = val;

      otherwise
    end % switch key
  end % loop through pairs
end % if nargs

  configTable = readtable('Pad0C_ValveGrouping.xlsx', ...
                          'PreserveVariableNames',true);
  
  num_valves = height(configTable);

  if isempty(dataSetRootFolder)
    config = MDRTConfig.getInstance;
    dataSetRootFolder = config.userWorkingPath;
  end

  
  s = load(fullfile(dataSetRootFolder, 'data', 'AvailableFDs.mat'));
  FDList = s.FDList;

  EMPTY_CYCLE = struct ( ...
    'direction',  [], ...
    'command',    [], ...
    'complete',   [], ...
    'passed',     []  ...
    );

  EMPTY_ERROR = struct ( ...
    'direction',  [], ...
    'command',    [] ...
    );

  %% Build Data and Report Structure
  EMPTY_REPORT = struct( ...
    'type',   [], ...
    'find',   [], ...
    'name',   [], ...
    'open',   [], ...
    'close',  [], ...
    'errors', [], ...
    'cycles', []  ...
    );

  EMPTY_DATA = struct ( ...
    'cmd',        [], ...
    'sw_close',   [], ...
    'sw_open',    [], ...
    'state',      [], ...
    'cmds_open',  [], ...
    'cmds_close', [], ...
    'cmds_error', []  ...
    );


  reports = repmat(EMPTY_REPORT, num_valves, 1);
  data    = repmat(EMPTY_DATA,   num_valves, 1);

  %% Build Data from Valves
  DATA_STEPS = 5;
  for i = 1:num_valves
    % info for this (ith) valve
    thisType      = configTable.("Valve Type"){i};
    thisFind      = configTable.("Valve FN"){i};
    thisOpen      = configTable.("Open I/O")(i);
    thisClosed    = configTable.("Closed I/O")(i);
    thisCommand   = configTable.("Command I/O")(i);
    thisSigType   = configTable.("TRUE State Signal")(i);
    thisValveName = sprintf('%s-%s', thisType, thisFind);
    thisTimingReq = table2struct(configTable(i, ...
      {'Open_Min', 'Open_Max', 'Close_Min', 'Close_Max'}));

    %% Pre-populate valve report;
    thisReport      = EMPTY_REPORT;
    thisReport.type = thisType;
    thisReport.find = thisFind;
    thisReport.name = thisValveName;
    reports(i) = thisReport;


    %% Loading Data
    % Update progress bar
    loading_progress(i, num_valves, 0, DATA_STEPS, progParent, thisReport.name)

    data(i).cmd   = timetable_from_io_num(thisCommand, FDList, dataSetRootFolder);
    data(i).cmd   = add_command_state_to_timetable(data(i).cmd, thisType);
    loading_progress(i, num_valves, 1, DATA_STEPS, progParent)

    data(i).sw_close = timetable_from_io_num(thisClosed,  FDList, dataSetRootFolder);
    data(i).sw_close = add_switch_state_to_timetable(data(i).sw_close, thisSigType);
    loading_progress(i, num_valves, 2, DATA_STEPS, progParent)

    data(i).sw_open  = timetable_from_io_num(thisOpen,    FDList, dataSetRootFolder);
    data(i).sw_open  = add_switch_state_to_timetable(data(i).sw_open, thisSigType);
    loading_progress(i, num_valves, 3, DATA_STEPS, progParent)

    if any([isempty(data(i).cmd), isempty(data(i).sw_close), isempty(data(i).sw_open)])
      continue
    end

    %% Calculate State Timetable

    % Get all change times from both switches and command
    csw_change_ind = find(diff(data(i).sw_close.Value)) + 1;
    osw_change_ind = find(diff(data(i).sw_open.Value)) + 1;
    cmd_change_ind = find(diff(data(i).cmd.Value)) + 1;

    % Append first and final value, for better plotting later on
    csw_change_ind = [1; csw_change_ind; length(data(i).sw_close.Value)];
    osw_change_ind = [1; osw_change_ind; length(data(i).sw_open.Value)];
    cmd_change_ind = [1; cmd_change_ind; length(data(i).cmd.Value)];
    
    state_times = vertcat( ...
                    data(i).sw_close(csw_change_ind,:).Time, ...
                    data(i).sw_open(osw_change_ind, :).Time ...
                    );
    if thisSigType
      data(i).state = make_state_from_sw_changes_reversed( ...
        data(i).sw_open,  ...
        data(i).sw_close, ...
        state_times   ...
        );
    else
      data(i).state = make_state_from_sw_changes( ...
        data(i).sw_open,  ...
        data(i).sw_close, ...
        state_times   ...
        );
    end

    loading_progress(i, num_valves, 4, DATA_STEPS, progParent)

    %% Loop through all commands

    MAX_CYCLE_TIME = duration(0, 2, 0); % two minute max

    for n = 1:length(cmd_change_ind)
      c_ind = cmd_change_ind(n);
      this_cmd  = data(i).cmd(c_ind,:); 
      cmd_time  = this_cmd.Time;

      debugout('Parsing %s command for %s', this_cmd.Command, thisValveName);

      this_interval = timerange(cmd_time, cmd_time + MAX_CYCLE_TIME, 'open');

      states = data(i).state(this_interval,:);

      if isempty(states)
        % No state changes found within MAX_CYCLE_TIME of command
        if (cmd_time == data(i).cmd.Time(1) || cmd_time == data(i).cmd.Time(end))
          % Ignore first and last data points - they are for plot completeness
          % and are not expected to be a legitimate cycle.
          continue;
        end

        this_error = EMPTY_ERROR;
        this_error.direction = this_cmd.Command;
        this_error.command   = this_cmd.Time;
        thisReport.errors    = horzcat(thisReport.errors, this_error);
        debugout(this_cmd)
        continue
      end

      switch this_cmd.Command
        case 'Open'
          cmd_state_lind = states.State == 'Open';
        otherwise
          % 'Close'
          cmd_state_lind = states.State == 'Closed';
      end

      if ~any(cmd_state_lind)
        % No states matching the commanded position in the MAX_CYCLE_TIME window
        % Report failure to turn?
        debugout('No %s transition found for %s', this_cmd.Command, thisValveName);
        % Didn't I just make this work as an error reporting??
        continue;
      end

      % The timestamp of the final position is the 1st element of matching states
      new_state_time = states(cmd_state_lind,:).Time(1);
      cycle_duration = new_state_time - cmd_time;


      %% Build the report for this detected valve cycle
      % Right now we have a field for 'open' that is an array of cycle durations as duration objects
      % report:
      %   - cycles : [ cycle.type, cycle.command, cycle.complete ]
      %   - errors : [ cycle.type, cycle.command ]

      switch this_cmd.Command
        case 'Open'
          thisReport.open  = horzcat(thisReport.open,  cycle_duration);
          data(i).cmds_open = vertcat(data(i).cmds_open, this_cmd);
        case 'Close'
          thisReport.close = horzcat(thisReport.close, cycle_duration);
          data(i).cmds_close = vertcat(data(i).cmds_close, this_cmd);
        otherwise
          % Something is horribly wrong
          debugout('What did you do+!???')
          continue
      end

      thisCycle = EMPTY_CYCLE;
      thisCycle.direction = this_cmd.Command;
      thisCycle.command   = this_cmd.Time;
      thisCycle.complete  = new_state_time;
      thisCycle.passed    = pass_or_fail_cycle(thisCycle, thisReport, thisTimingReq);
      thisReport.cycles = horzcat(thisReport.cycles, thisCycle);


    end

    % Went through every command and built report for this valve. 
    % Update master array
    reports(i) = thisReport;

    loading_progress(i, num_valves, 5, DATA_STEPS, progParent)

  end

  loading_progress(1,1,1,1,progParent)

  T = report_table_from_reports(reports);

  if do_save_file
    save_report_table_to_excel(T, dataSetRootFolder);
  end

  if do_save_data
    save_valve_data_to_matlab(data, reports, dataSetRootFolder);
  end

  
end

function this_cmd = add_command_state_to_timetable(this_cmd, thisType)
  % Compute a 'Command' column from the electrical signal value.
  % 'Open' means we are asking the valve to be in the physically open position
  % Pad-C Control Data use 1 as open for all valves, regardless of
  % NO/NC status. They convert the output from the module.

  if isempty(this_cmd)
    return
  end

  CLOSE_CMD = 0;
  OPEN_CMD  = 1;

  this_cmd.Command = categorical(this_cmd.Value, ...
    [OPEN_CMD, CLOSE_CMD], ... 
    {'Open', 'Close'});
end


function this_switch = add_switch_state_to_timetable(this_switch, sig_type)
  % Compute a 'State' column from electrical signal value. 
  % 'Engaged' means the valve is physically pushing the switch (in
  % a position to touch the position switch)
  ENGAGED    = sig_type;
  DISENGAGED = ~ENGAGED;

  if isempty(this_switch)
    return
  end

  this_switch.State = categorical( ...
    this_switch.Value, ...
    [ENGAGED, DISENGAGED], ...
    {'Engaged', 'Disengaged'} ...
    );
end

function state_tt = make_state_from_sw_changes(osw, csw, times)
  % Compute a valve state timetable from the open_sw and close_sw timetables
  % pass the indices of all interesting events (first, last, all changes)
  % sigType is from config spreadsheet. The open switch means OPEN when it
  % equals the sigType
  %   	        oPx	        cPx
  % OPEN	      ENGAGED	    DISENGAGED
  % CLOSED	    DISENGAGED	ENGAGED
  % TRANSITION	DISENGAGED	DISENGAGED
  % CRITICAL	  ENGAGED	    ENGAGED

  Value = ones(height(times), 1);
  times = sort(times);
  Time  = times;

  for i = 1:height(times)
    time = times(i);
    oSw = osw(osw.Time <= time, :).State(end);
    cSw = csw(csw.Time <= time, :).State(end);

    % oSw = osw(inds(i),:).State;
    % cSw = csw(inds(i),:).State;

    if     oSw == 'Engaged'    && cSw == 'Disengaged'
      thisState = 1; % Open

    elseif oSw == 'Disengaged' && cSw == 'Engaged'
      thisState = 0; % Closed

    elseif oSw == 'Disengaged' && cSw == 'Disengaged'
      thisState = 2; % Transitioning

    elseif oSw == 'Engaged'    && cSw == 'Engaged'
        thisState = 3; % Critical

    end
    Value(i) = thisState;
  end

  state_tt = timetable(Time, Value);
  state_tt.State = categorical( ...
    state_tt.Value, ...
    [0, 1, 2, 3], ...
    {'Closed', 'Open', 'Cautionary', 'Critical'} ...
    );
end


function state_tt = make_state_from_sw_changes_reversed(osw, csw, times)
  % Compute a valve state timetable from the open_sw and close_sw timetables
  % pass the indices of all interesting events (first, last, all changes)
  % sigType is from config spreadsheet. The open switch means OPEN when it
  % equals the sigType
  %   	        oPx	        cPx
  % OPEN	      ENGAGED	    DISENGAGED
  % CLOSED	    DISENGAGED	ENGAGED
  % CRITICAL  	DISENGAGED	DISENGAGED
  % TRANSITION	ENGAGED	    ENGAGED

  Value = ones(height(times), 1);
  times = sort(times);
  Time  = times;

  for i = 1:height(times)
    time = times(i);
    oSw = osw(osw.Time <= time, :).State(end);
    cSw = csw(csw.Time <= time, :).State(end);

    if     oSw == 'Engaged'    && cSw == 'Disengaged'
      thisState = 1; % Open

    elseif oSw == 'Disengaged' && cSw == 'Engaged'
      thisState = 0; % Closed

    elseif oSw == 'Disengaged' && cSw == 'Disengaged'
      thisState = 3; % Transitioning

    elseif oSw == 'Engaged'    && cSw == 'Engaged'
        thisState = 2; % Critical

    end
    Value(i) = thisState;
  end

  state_tt = timetable(Time, Value);
  state_tt.State = categorical( ...
    state_tt.Value, ...
    [0, 1, 2, 3], ...
    {'Closed', 'Open', 'Cautionary', 'Critical'} ...
    );
end

function def_state = default_state_from_type(type_str)
  % Return the numeric value of the default state of a valve
  % if NO or NC doesn't match, returns "3" for critical - something
  % has gone wrong
  def_state = 3;
  if endsWith(type_str, {'N/C', 'NC'}, 'IgnoreCase', true)
    def_state = 0;
    return
  elseif endsWith(type_str, {'N/O', 'NO'}, 'IgnoreCase', true)
    def_state = 1;
    return
  end
end

function passed = pass_or_fail_cycle(thisCycle, thisReport, thisTimingReq)
  % If thisTimingReq has Nan (empty requirements from spreadsheet) then mark as
  % passed. Some valves may have no requirements - it will be user's job to 
  % ensure requirements are captured. If no requirements, then manual review

  seconds_elapsed = seconds(thisCycle.complete - thisCycle.command);
  switch thisCycle.direction
    case 'Open'
      if seconds_elapsed > thisTimingReq.Open_Max 
        passed = false;
      elseif seconds_elapsed < thisTimingReq.Open_Min
        passed = false;
      else
        passed = true;
      end
      return

    case 'Close'
      if seconds_elapsed > thisTimingReq.Close_Max 
        passed = false;
      elseif seconds_elapsed < thisTimingReq.Close_Min
        passed = false;
      else
        passed = true;
      end
      return
  end

end

function loading_progress(valve, valves, step, steps, pbp, varargin)
  persistent pb;
  progress = ((valve-1) + step/steps) / valves;
  
  if isa(pbp, 'matlab.ui.Figure')
    if progress == 0
      pb = uiprogressdlg(pbp, 'Title', 'Valve Timing Progress', ...
        'Cancelable','on', ...
        'Message', 'Processing all valves');
    end
  
    pb.Value = progress;
    if ~isempty(varargin)
      pb.Message = varargin{1};
    end

    if progress == 1
      try
        close(pb);
      catch
      end
      pb = [];
    end
  
  else
    if valve == 0
      progressbar('Loading Valve Data');
    end
  
    progressbar(progress)
  end
end

function tt = timetable_from_io_num(io_num, FDList, data_root_folder)
  %% returns a timetable for the FD with the matching IOcode number
  %  returns empty value if FD can't be loaded
  fd_str = get_fd_string_from_IO_code_number(io_num, FDList);
  if isempty(fd_str)
    tt = [];
    return
  end

  data_file_folder = fullfile(data_root_folder, 'data');


  try
    fd = load_fd_by_name(fd_str, 'folder', data_file_folder);
  catch
    tt = [];
    return;
  end

  Time = datetime(fd.ts.Time, 'ConvertFrom', 'datenum');
  Value = fd.ts.Data;

  % tt = timetable( Time, Value, 'DimensionNames', {'Time', 'Value'});
  tt = timetable( Time, Value);
  return
end


function fd_str = get_fd_string_from_IO_code_number(io_code, FDList)
  % Returns the first FD string that ends in IO code number with 0 padding
  % If multiple matches, returns the first match in the list
  % if no matches, returns empty char array ''
  fd_str = '';
  search_tok = sprintf('-%d', io_code);
  matches = endsWith(FDList(:,1), search_tok );
  if ~any(matches)
    return;
  end
  
  % Return only first match in case of overload
  match_ind = find(matches);

  fd_str = FDList{match_ind(1)};
  return
end


function T = report_table_from_reports(reports)

  %% Report Output as Table

  first_row_flag = true;

  colnames = {'valve',  'find',   'command', 'cycles', 'average', 'cycle_time'};
  colTypes = {'string', 'string', 'string',  'double', 'double',  'cell'};
  T = table('Size', [0,numel(colnames)], 'VariableTypes', colTypes, 'VariableNames', colnames);

  for i = 1:height(reports)
    thisRep = reports(i);
    valveName = sprintf('%s-%s', thisRep.type, thisRep.find);

    newRow = {valveName, thisRep.find, 'open', 0,0,[]};
    if ~isempty(thisRep.open)
      newRow = {
        valveName;
        thisRep.find;
        'open';
        length(thisRep.open);
        seconds(mean(thisRep.open));
        {thisRep.open}
        }';
    end

    T = vertcat(T, cell2table(newRow, 'VariableNames', colnames));

    newRow = {valveName, thisRep.find, 'close', 0,0,duration.empty()};
    if ~isempty(thisRep.close)
      newRow = {
        valveName;
        thisRep.find;
        'close';
        length(thisRep.close);
        seconds(mean(thisRep.close));
        {thisRep.close}
        }';
    end

    T = vertcat(T, cell2table(newRow, 'VariableNames', colnames));

  end

end

function save_report_table_to_excel(T, setFolder)
  %% Prompt user for filename and write the report table T to disk as an excel
  % file.

  template  = getMDRTResource('ValveTiming_Template.xlsx');
  s = load(fullfile(setFolder, 'data', 'metadata.mat'));
  defaultFileName = sprintf('Valve Timing Data for %s', s.metaData.operationName);

  fileTypes = {
    '*.xlsx', 'Excel Spreadsheet (*.xlsx)';
    '*.csv', 'Comma Separated Value (*.csv)';
    '*.*',  'All Files (*.*)'};

  [filename, pathname, ext] = uiputfile( fileTypes, ...
    'Save as', fullfile(setFolder, defaultFileName) );

  if ~pathname; return; end

  % Change T.cycle_time from {duration} cell array to a { double } cell array
  % because MATLAB is stupid and their friggin custom data types work like
  % butt

  cell_arr_of_doubles = cellfun(@seconds, T.cycle_time, 'UniformOutput', false);
  T.cycle_time = cell_arr_of_doubles;
  
  % tempFile = [tempname, '.xlsx'];
  % copyfile(template, tempFile)
  % writetable(T, tempFile, 'PreserveFormat',true)
  % disp(tempFile)
  % copyfile(tempFile, fullfile(pathname, filename))
  
  writetable(T, fullfile(pathname, filename))

end


function save_valve_data_to_matlab(data, reports, setFolder)
% Write the results of the reports and valve data to disk as .mat
% files to other tools can parse them later.
% Saves all data in a single .mat file with a version number

filename  = 'pad-c-valve-timing.mat';
valve_timing_version = '1.1';

save(fullfile(setFolder, filename), ...
  'valve_timing_version', ...
  'data', ...
  'reports' ...
  );

end
