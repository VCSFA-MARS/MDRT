function hs = valveTimingGUI(varargin)
%% valveTimingGUI launches the valve timing tool
% accepts a parent container for integration into other tools

config = MDRTConfig.getInstance;
FOLDER_ICON    = getMDRTResource('folder-16x16.png');
FOLDER_GOOD    = getMDRTResource('folder-good-16x16.png');
VALVE_ICON     = getMDRTResource('valve_list_icon_transparent_64x64.png');
VALVE_SELECTED = getMDRTResource('valve_list_icon_selected_64x64.png');


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
hs.fd_selection.SelectionChangedFcn = @cycle_selection_changed;

%% Results View UI

hs.tabgroup_results = uitabgroup(hs.grid_fig);
hs.result_tab_plot = uitab(hs.tabgroup_results, 'Title', 'Plots');
hs.result_tab_grid = uitab(hs.tabgroup_results, 'Title', 'Results');


%% Plot / Axes Creation
hs.grid_plot = uigridlayout(hs.result_tab_plot, [2 1], 'RowHeight', {'fit', '5x'});
hs.plot_title = uilabel(hs.grid_plot);
hs.ax = uiaxes(hs.grid_plot);

%% Tabular Results View
hs.grid_results_tab = uigridlayout(hs.result_tab_grid, [2,1], 'RowHeight', {'fit', '4x'});
hs.results_title = uilabel(hs.grid_results_tab, 'Text', 'Results of Valve Cycling');
hs.results_table = uitable(hs.grid_results_tab);


%% +----------------------------------------------------------------------+
%  |                  Utility and Callback Functions                      |
%  +----------------------------------------------------------------------+

  function cycle_selection_changed(hobj, event)
    
    
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
    
    hs.visible_tab_grid.Parent = hs.tabs.SelectedTab;
    if isfield(hs, 'tree')
      hs.tree.delete
    end
    
    hs.tree = uitree(hs.visible_tab_grid, 'SelectionChangedFcn', @node_selection_dispatch);
    hs.rootNode = uitreenode(hs.tree, 'Text', hs.tabs.SelectedTab.UserData, 'NodeData', hs.tabs.SelectedTab.UserData);
    
    D = dir(hs.tabs.SelectedTab.UserData);
    dir_mask = [D.isdir] == true;
    DIRS = D(dir_mask);
    
    for di = 1:length(DIRS)
      this_dir = DIRS(di);
      if this_dir.name(1) == '.'
        % skip hidden and . or ..
        continue
      end
      uitreenode(hs.rootNode, 'Text', this_dir.name, 'Icon',FOLDER_ICON, 'NodeData', fullfile(hs.tabs.SelectedTab.UserData, this_dir.name));
    end
    
    hs.rootNode.expand();
  end

  
  function node_selection_dispatch(hobj, event)
    switch class(event.SelectedNodes.NodeData)
      case 'char'
        % Means a path - a data set root node
        hs.button_process_valve_timing.Enable = 'on';
        dataset_node_selected(hobj, event);
      case 'struct'
        hs.button_process_valve_timing.Enable = 'off';
        valve_node_selected(hobj, event);
      otherwise
    end
  end


  function valve_node_selected(hobj, event)

    set(hobj.SelectedNodes.Parent.Children, 'Icon', VALVE_ICON);
    set(event.SelectedNodes, 'Icon', VALVE_SELECTED);
    
    this_node = event.SelectedNodes;
    node_path = this_node.Parent.NodeData; % full path of data set
    
    cycle = struct('cmd_type', [], 'cmd_ind', []);
    T = table([],[],[], 'VariableNames', {'time', 'cmd_type', 'cmd_ind'});
    node_data = this_node.NodeData;

    for ci = 1:height(node_data.data.cmds_open)
      thisCmd = node_data.data.cmds_open(ci,:);
      T = [T; {thisCmd.Time, thisCmd.Command, ci}];
    end

    for ci = 1:height(node_data.data.cmds_close)
      thisCmd = node_data.data.cmds_close(ci,:);
      T = [T; {thisCmd.Time, thisCmd.Command, ci}];
    end

    T = sortrows(T, 'time');
    
    cycle_strs = {};
    for ci = 1:height(T)
      cycle_strs{ci,1} = sprintf('%s cycle %d', T(ci,:).cmd_type, ci);
    end

    hs.fd_selection.set_items(cycle_strs, T);
    hs.results_table.Data = timetable2table([node_data.data.cmds_close; ...
      node_data.data.cmds_open]);

    plotValveTimingData(node_data.data, node_data.rep, '', 0);


    %% Populate cycle list
    
  end


  function dataset_node_selected(hobj, event)
    % populate child nodes with valves if available and needed.
    % When a "folder" node is selected, available valve timing data are
    % loaded and populated as children. Valve nodes have a separate
    % callback function. No updating if already populated for now
    % TODO: add update time to folder node to detect updates?
    
    set(hobj.SelectedNodes.Parent.Children, 'Icon', FOLDER_ICON);
    set(event.SelectedNodes, 'Icon', FOLDER_GOOD);
    
    this_node = event.SelectedNodes;
    node_path = this_node.NodeData; % full path of data set
    debugout(node_path);

    %% Valve Timing Data Population
    if ~isempty(this_node.Children)
      return
    end
    
    metaDataFile  = fullfile(node_path, 'data', 'metadata.mat');
    fd_index_file = fullfile(node_path, 'data', 'AvailableFDs.mat');
    timing_file   = fullfile(node_path, 'pad-c-valve-timing.mat');
    
    if exist(timing_file, 'file') == 2
      pb = uiprogressdlg(hs.top_window, 'Title', 'Loading valve timing data');
      s = load(timing_file);
      for vi = 1:length(s.data)
        thisData = s.data(vi);
        thisRep  = s.reports(vi);
        thisNodeStr = thisRep.find;
        pb.Message = thisNodeStr;
        if isempty(thisRep.open) && isempty(thisRep.close)
          continue
        end
        uitreenode(this_node, ...
          'Text', thisNodeStr, ...
          'Icon', VALVE_ICON, ...
          'NodeData', struct('data', thisData, 'rep', thisRep) ...
          );
        pb.Value = vi/length(s.data);
      end
      close(pb);
    end
    
  end


  function temp_search(hobj, event)
    % fprintf('edit value: %s \t event value: %s\n', hobj.Value, event.Value);
    search_str = event.Value;
    
  end

  function plotValveTimingData(data, rep, cmd_type, ind)

    cla(hs.ax, 'reset')
    hold off;

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
    switch cmd_type
      case 'Open'
        ax_start = data.cmds_open(ind,:).Time;
        ax_stop  = ax_start + rep.open(ind);

      case 'Close'
        ax_start = data.cmds_close(ind,:).Time;
        ax_stop  = ax_start + rep.close(ind);

      otherwise
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
    data_set_folder = hs.tree.SelectedNodes.NodeData;
    processPadCValves('RootFolder', data_set_folder, ...
      'ProgressFig',    hs.top_window,  ...
      'SaveFile',       true,           ...
      'SaveData',       true);
  end

end


