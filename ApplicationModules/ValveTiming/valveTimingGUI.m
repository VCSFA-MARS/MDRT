function hs = valveTimingGUI(varargin)
%% valveTimingGUI launches the valve timing tool
% accepts a parent container for integration into other tools. If you pass a
% pane, tab, or other container, valveTimingGUI will find the parent figure
% and target all the process dialogs to the parent.

config = MDRTConfig.getInstance;
%% GUI Constants
FOLDER_EMPTY   = getMDRTResource('Folder_Tahoe_Empty_16.png', 'ResourceType', 'icon');
FOLDER_FULL    = getMDRTResource('Folder_Tahoe_Data_Full_16.png', 'ResourceType', 'icon');

FOLDER_ICON    = getMDRTResource('folder-16x16.png');
FOLDER_GOOD    = getMDRTResource('folder-good-16x16.png');

VALVE_ICON     = getMDRTResource('valve_white.png', 'ResourceType', 'icon');
VALVE_ICON_WARN  = getMDRTResource('valve_white_yellow.png', 'ResourceType', 'icon');
VALVE_ICON_ERROR = getMDRTResource('valve_white_red.png', 'ResourceType', 'icon');

VALVE_SELECTED = getMDRTResource('valve_blue.png', 'ResourceType', 'icon');
VALVE_SELECTED_WARN  = getMDRTResource('valve_blue_yellow.png', 'ResourceType', 'icon');
VALVE_SELECTED_ERROR = getMDRTResource('valve_blue_red.png', 'ResourceType', 'icon');

% OPEN_FOLDER    = getMDRTResource('OpenFolderIcon.icns', 'ResourceType', 'icon'); 
OPEN_FOLDER = getMDRTResource('OpenFolderIcon.png', 'ResourceType', 'icon');
OPEN_FOLDER = FOLDER_GOOD;

% Display Styles for UI Elements
LIGHT_RED = [255, 199, 206] ./ 255;
DARK_RED  = [156, 0, 6] ./ 255;
LIGHT_YEL = [252, 236, 166] ./ 255;
DARK_YEL  = [156, 87, 0] ./ 255;

fail_style = uistyle('FontColor',       DARK_RED, ...
  'BackgroundColor', LIGHT_RED);
warn_style = uistyle('FontColor',       DARK_YEL, ... 
  'BackgroundColor', LIGHT_YEL);

empty_node_data = struct( ...
  'type',     '' ...
  );

archives = {
  config.dataArchivePath, 'Archive';
  config.importDataPath, 'Import';
  config.remoteArchivePath, 'Remote';
  };


if nargin == 0
  hs.fig = uifigure();
  hs.fig.Name = 'Valve Timing Browser';
  hs.fig.NumberTitle = 'off';
  hs.fig.MenuBar = 'none';
  hs.fig.ToolBar = 'none';
  hs.fig.Tag = 'dataBrowserFigure';
  
else
  hs.fig = varargin{1};
end

hs.top_window = ancestor(hs.fig, 'figure');

grid_fig = uigridlayout(hs.fig, [1,2]);
grid_fig.ColumnWidth = {'fit', '2x'};
hs.grid_fig = grid_fig;

%% Data Set Selection Controls

hs.data_set_col_grid = uigridlayout(grid_fig, [2,1]);
hs.tab_pane = uipanel(hs.data_set_col_grid, 'Title', 'Data Set Selection');
hs.tab_pane_grid = uigridlayout(hs.tab_pane, [2 1], 'RowHeight', {'1x', 'fit'});
hs.tabs = uitabgroup(hs.tab_pane_grid, 'SelectionChangedFcn', @populate_tab_tree);
hs.button_process_valve_timing = uibutton(hs.tab_pane_grid, 'Text', 'Compute Timing', ButtonPushedFcn=@compute_timing_for_dataset);

for i = 1:height(archives)
  this_arch_name = archives{i,2};
  this_arch_path = archives{i,1};
  hs.my_tabs(i) = uitab(hs.tabs, 'Title', this_arch_name, 'UserData', this_arch_path);
end

hs.visible_tab_grid = uigridlayout(hs.tabs.SelectedTab, [1,1]);
populate_tab_tree();


%% FD Selection UI

hs.panel_fd_select = uipanel(hs.data_set_col_grid, 'Title', 'FD Selection');
hs.fd_selection = MDRTListBox(hs.panel_fd_select);
hs.fd_selection.SelectionChangedFcn = @select_valve_cycle;

%% Results View UI

hs.tabgroup_results = uitabgroup(hs.grid_fig);
hs.result_tab_plot = uitab(hs.tabgroup_results, 'Title', 'Plots');
hs.result_tab_grid = uitab(hs.tabgroup_results, 'Title', 'Results');


%% Plot / Axes Creation
hs.grid_plot = uigridlayout(hs.result_tab_plot, [2 1], 'RowHeight', {'fit', '5x'});
hs.plot_title = uilabel(hs.grid_plot);
hs.ax = uiaxes(hs.grid_plot);

%% Tabular Results View
hs.grid_results_tab = uigridlayout(hs.result_tab_grid, [4,1], 'RowHeight', {'fit', '4x', 'fit', '4x'});
hs.results_title = uilabel(hs.grid_results_tab, 'Text', 'Results of Valve Cycling');
hs.results_table = uitable(hs.grid_results_tab);
hs.summary_title = uilabel(hs.grid_results_tab, 'Text', 'Summary of Valve Cycling');
hs.summary_table = uitable(hs.grid_results_tab);


%% +----------------------------------------------------------------------+
%  |                  Utility and Callback Functions                      |
%  +----------------------------------------------------------------------+

  function select_valve_cycle(hobj, event)
    
    
    if isempty(hs.tree.SelectedNodes)
      % Guard against selecting an FD without a data set selcted
      return
    end

    node_data = hs.tree.SelectedNodes.NodeData;

    if isa(node_data, 'char')
      % Guard against selecting cycle when valve isn't selected
      return
    end

    % for now this prints all the commands, so index 1 is used
    this_table = hobj.Value;
    switch this_table.cmd_type
      case 'Open'
        plotValveTimingData(node_data.data, node_data.rep, this_table.cmd_type, this_table.cmd_ind)

      case 'Close'
        plotValveTimingData(node_data.data, node_data.rep, this_table.cmd_type, this_table.cmd_ind)

    end

    
  end

  function populate_tab_tree(~, ~)
    % Populates the folder tree when an archive tab is selected
    
    hs.visible_tab_grid.Parent = hs.tabs.SelectedTab;
    if isfield(hs, 'tree')
      hs.tree.delete
    end

    root_node_data = empty_node_data;
    root_node_data.type = 'root_node';
    root_node_data.path = hs.tabs.SelectedTab.UserData;
    
    hs.tree = uitree(hs.visible_tab_grid, 'SelectionChangedFcn', @select_tree_node);
    hs.rootNode = uitreenode(hs.tree, ...
      'Text',        hs.tabs.SelectedTab.UserData, ...
      'NodeData',    root_node_data);

    archive_root = hs.rootNode.NodeData.path;

    D = dir(archive_root);
    dir_mask = [D.isdir] == true;
    DIRS = D(dir_mask);
    
    for di = 1:length(DIRS)
      this_dir = DIRS(di);
      if this_dir.name(1) == '.'
        % skip hidden and . or ..
        continue
      end
      this_dataset_dir = fullfile(archive_root, this_dir.name);
      this_dataset_file = fullfile(this_dataset_dir, 'pad-c-valve-timing.mat');
      this_node_data = empty_node_data;
      this_node_data.type = 'data_set_node';
      this_node_data.path = this_dataset_dir;
      this_node_data.last_updated = 0;

      % Change icon if valve data are found in the dataset
      if exist(this_dataset_file, 'file')
        this_node_icon = FOLDER_FULL;
      else
        this_node_icon = FOLDER_EMPTY;
      end


      uitreenode(hs.rootNode, ...
        'Text',     this_dir.name,  ...
        'Icon',     this_node_icon, ...
        'NodeData', this_node_data  ...
        );
    end
    
    hs.rootNode.expand();
  end

  
  function select_tree_node(hobj, event)
    switch class(event.SelectedNodes.NodeData)
      case 'struct'
        switch event.SelectedNodes.NodeData.type
          case 'root_node'
            hs.button_process_valve_timing.Enable = 'off';

          case 'data_set_node'
            hs.button_process_valve_timing.Enable = 'on';
            select_dataset_node(hobj, event);

          case 'valve_node'
            hs.button_process_valve_timing.Enable = 'off';
            select_valve_node(hobj, event);

        end
    end
  end


  function select_valve_node(hobj, event)
    % Callback when valve node is selected. Populate the following:
    % - Plot state, command, command times, etc 
    % - Two Tables: Individual cycle results, Overall averages
    % - Populate the 'fd_selection' with cycles for plot-snapping

    % Unset the last selected valve icon (do them all to be sure)
    allNodesToRefresh = hobj.SelectedNodes.Parent.Children;
    for i_n = 1:length(allNodesToRefresh)
      tNode = allNodesToRefresh(i_n);
      tNodeNormalIcon = tNode.NodeData.icon.normal;
      tNode.Icon = tNodeNormalIcon;
    end

    this_node = event.SelectedNodes;
    this_node.Icon = this_node.NodeData.icon.selected;
    
    %% Generate Cycle List for Selection Box 
    % Use report data and apply styling to valve cycles if failed
    T = table([],[],[], [], 'VariableNames', {'time', 'cmd_type', 'cmd_ind', 'passed'});
    node_data = this_node.NodeData;

    % VERSION 1.0 had no 'passed' data
    % Consider all old data to be passing
    if ~isfield(node_data.rep.cycles(1), 'passed')
      thisCycle.passed = true;
      for ci = 1:numel(node_data.rep.cycles)
        thisCycle = node_data.rep.cycles(ci);
        T = [T; {thisCycle.command, thisCycle.direction, ci, true}];
      end
    else
      % VERSION 1.1+ uses 'passed' data
      for ci = 1:numel(node_data.rep.cycles)
        thisCycle = node_data.rep.cycles(ci);
        T = [T; {thisCycle.command, thisCycle.direction, ci, thisCycle.passed}];
      end
    end

    T = sortrows(T, 'time');
    T_failing = find(T.passed == false);
    
    cycle_strs = {};
    for ci = 1:height(T)
      cycle_strs{ci,1} = sprintf('%s cycle', T(ci,:).cmd_type);
    end

    hs.fd_selection.set_items(cycle_strs, T);
    removeStyle(hs.fd_selection.list_box)
    addStyle(hs.fd_selection.list_box, fail_style, 'item', T_failing );

    CycleDirections   = [node_data.rep.cycles.direction]';
    CycleCommandTime  = [node_data.rep.cycles.command]';
    CycleCompleteTime = [node_data.rep.cycles.complete]';
    CycleDuration     = seconds(CycleCompleteTime - CycleCommandTime);


    cycle_table = table(CycleDirections,    ...
                        CycleCommandTime,  ...
                        CycleCompleteTime, ...
                        CycleDuration);

    
    hs.results_table.Data = cycle_table;

    %% Apply Table Styles to Failing Cycle Rows 
    if isfield(node_data.rep.cycles, 'passed')
      CyclePass     = [node_data.rep.cycles.passed];
      failing_rows = find(CyclePass == false);   


      removeStyle(hs.results_table); % Clear previous styles!
      addStyle(hs.results_table, fail_style, 'row', failing_rows);
    end

    avg_time_open  = seconds(mean(node_data.rep.open));
    avg_time_close = seconds(mean(node_data.rep.close));

    num_opens  = numel(node_data.rep.open);
    num_closes = numel(node_data.rep.close);
    num_errors = numel(node_data.rep.errors);
    RowLabels ={ 'Open Cycles';'Close Cycles'; 'Error Cycles' } ;
    ColLabels ={ 'Number of Cycles';'Average Time' } ;

    summary_table = table( ...
      [num_opens;      num_closes;     num_errors], ...
      [avg_time_open;  avg_time_close; nan()], ...
      'RowNames',      RowLabels, ...
      'VariableNames', ColLabels);

    pb = uiprogressdlg(hs.top_window, ...
      'Title', 'Updating valve cycle results');
    pb.Value = 0.5;
    hs.summary_table.Data = summary_table;

    pb.Message = 'Updating valve cycle plots';
    plotValveTimingData(node_data.data, node_data.rep, '', 0);
    pb.Value = 1.0;
    delete(pb);

    %% Populate cycle list
    
  end


  function select_dataset_node(hobj, event)
    % populate child nodes with valves if available and needed.
    % When a "folder" node is selected, available valve timing data are
    % loaded and populated as children. Valve nodes have a separate
    % callback function. No updating if already populated for now
    % TODO: add update time to folder node to detect updates?
    
    % set(hobj.SelectedNodes.Parent.Children, 'Icon', FOLDER_ICON);
    % set(event.SelectedNodes, 'Icon', FOLDER_GOOD);
    % set(event.SelectedNodes, 'Icon', OPEN_FOLDER);
    
    this_data_set_node = event.SelectedNodes;
    data_set_node_data = this_data_set_node.NodeData;
    data_set_path = data_set_node_data.path; % full path of data set
    debugout('Selected: %s',data_set_path);

    timing_file   = fullfile(data_set_path, 'pad-c-valve-timing.mat');
    if ~exist(timing_file, 'file')
      timing_file_modified_time = 0;
    else
      timing_file_modified_time = dir(timing_file).datenum;
    end
    
    %% Valve Timing Data Population
    %  Already been here and the data haven't changed on disk
    if timing_file_modified_time <= data_set_node_data.last_updated 
      return
    end

    delete(this_data_set_node.Children);
    
    if exist(timing_file, 'file') == 2
      pb = uiprogressdlg(hs.top_window, 'Title', 'Loading valve timing data');
      s = load(timing_file); 
      data_version = s.valve_timing_version;

      % Populate valve nodes under data set
      for vi = 1:length(s.data)
        thisData = s.data(vi);
        thisRep  = s.reports(vi);
        thisNodeStr = thisRep.find;
        pb.Message = thisNodeStr;
        if isempty(thisRep.open) && isempty(thisRep.close)
          continue
        end

        this_valve_node_data = empty_node_data;
        this_valve_node_data.type = 'valve_node';
        this_valve_node_data.data = thisData;
        this_valve_node_data.rep  = thisRep;

        if string(data_version) < "1.1"
          this_valve_icon = VALVE_ICON;
          this_valve_icon_selected = VALVE_SELECTED;
        elseif ~isfield(thisRep.cycles, 'passed')
          this_valve_icon = VALVE_ICON;
          this_valve_icon_selected = VALVE_SELECTED;
        elseif all([thisRep.cycles.passed])
          this_valve_icon = VALVE_ICON;
          this_valve_icon_selected = VALVE_SELECTED;
        elseif any([thisRep.cycles.passed])
          this_valve_icon = VALVE_ICON_WARN;
          this_valve_icon_selected = VALVE_SELECTED_WARN;
        else
          this_valve_icon = VALVE_ICON_ERROR;
          this_valve_icon_selected = VALVE_SELECTED_ERROR;
        end

        this_valve_node_data.icon = struct(    ...
          'normal', this_valve_icon,           ...
          'selected', this_valve_icon_selected ...
        );


        uitreenode(this_data_set_node, ...
          'Text', thisNodeStr, ...
          'Icon', this_valve_icon, ...
          'NodeData', this_valve_node_data ...
          );
        pb.Value = vi/length(s.data);
      end
      this_data_set_node.NodeData.last_updated = timing_file_modified_time;
      close(pb);
    end
    
  end


  function temp_search(hobj, event)
    % fprintf('edit value: %s \t event value: %s\n', hobj.Value, event.Value);
    search_str = event.Value;
    
  end

  function plotValveTimingData(data, rep, cmd_type, ind)
    % If ind == 0, then plot all data

    cla(hs.ax, 'reset')
    % hold off;

    thisData = data;
    thisRep  = rep;

    op_tits = repmat(sprintf('%s %s Command', thisRep.name, 'Open'),height(thisData.cmds_open),1);
    cl_tits = repmat(sprintf('%s %s Command', thisRep.name, 'Close'),height(thisData.cmds_close),1);
    all_tits = [cellstr(op_tits); cellstr(cl_tits)];

    all_cmds = vertcat(thisData.cmds_close, thisData.cmds_open);
    all_cmds = sortrows(all_cmds);

    yyaxis(hs.ax, 'left');
    p1s = stairs(hs.ax, thisData.state.Time, thisData.state.State, ...
      'DisplayName', 'Valve State');

    hold(hs.ax, 'on');
    yyaxis(hs.ax, 'right');

    p2c = stairs(hs.ax, all_cmds.Time, all_cmds.Command, ...
      '--r', 'DisplayName', 'Valve Command');
    hold(hs.ax, 'on');

    p3c = stairs(hs.ax, thisData.cmd.Time, thisData.cmd.Command, ...
      'LineStyle',        ':', ...
      'Color',            [0 0.5 0], ...
      'DisplayName',      'All Commands');
    p4cm = plot(hs.ax, all_cmds.Time, all_cmds.Command, ...
      'DisplayName',      'Detected Commands', ...
      'LineStyle', 'none', ...
      'Color',            [1 0 0], ...
      'marker', 'v', ...
      'MarkerSize', 10);

    if isempty(cmd_type)
      hs.plot_title.Text = sprintf('%s All Cycles',thisRep.name);
    else
      hs.plot_title.Text = sprintf('%s %s Cycle',thisRep.name, cmd_type);
    end
    hs.plot_title.HorizontalAlignment = 'center';

    % Find time of indexed command for axes snapping
    if ind
      ax_start = rep.cycles(ind).command;
      ax_stop  = rep.cycles(ind).complete;
      direction_str = rep.cycles.direction;

    else
      ax_start = min(all_cmds.Time);
      ax_stop  = max(all_cmds.Time) + max([rep.close, rep.open]);

    end

    ax_start = ax_start - duration(0,0,2);
    ax_stop  = ax_stop  + duration(0,0,2);

    hs.ax.XLim = [ax_start, ax_stop];
    legend(hs.ax, [p1s, p2c, p3c, p4cm])


  end


  function compute_timing_for_dataset(hobj, event)
    if isempty(hs.tree.SelectedNodes)
      return
    end
    data_set_folder = hs.tree.SelectedNodes.NodeData.path;
    processPadCValves('RootFolder', data_set_folder, ...
      'ProgressFig',    hs.top_window,  ...
      'SaveFile',       true,           ...
      'SaveData',       true);
  end

end


