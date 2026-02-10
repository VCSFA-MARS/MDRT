function hs = dataBrowserGUI(varargin)
%% dataBrowserGUI launches the data browser tool
% accepts a parent container for integration into other tools

config = MDRTConfig.getInstance;
FOLDER_ICON = getMDRTResource('folder-16x16.png');
FOLDER_GOOD = getMDRTResource('folder-good-16x16.png');

archives = {
  config.dataArchivePath, 'Archive';
  config.importDataPath, 'Import';
  config.remoteArchivePath, 'Remote';
  };


if nargin == 0
  hs.fig = uifigure();
  hs.fig.Name = 'Data Browser GUI';
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
hs.tab_pane_grid = uigridlayout(hs.tab_pane, [1 1]);
hs.tabs = uitabgroup(hs.tab_pane_grid, 'SelectionChangedFcn', @populate_tab_tree);

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
hs.fd_selection.SelectionChangedFcn = @fd_selection_changed;


%% Plot / Axes Creation

hs.ax = uiaxes(grid_fig );


%% +----------------------------------------------------------------------+
%  |                  Utility and Callback Functions                      |
%  +----------------------------------------------------------------------+

  function fd_selection_changed(hobj, event)
    
    
    if isempty(hs.tree.SelectedNodes)
      % Guard against selecting an FD without a data set selcted
      return
    end
    disp(event)
    
    fd_file = fullfile(hobj.Value);
    this_fd = load_fd_by_name(fd_file, 'isFilename', 'true', 'folder', fullfile(hs.tree.SelectedNodes.NodeData, 'data'));
    
    hs.quick_plot_line = stairs(hs.ax, datetime(this_fd.ts.Time, 'convertfrom', 'datenum'), this_fd.ts.Data, 'DisplayName', this_fd.FullString);
    
    ylims = [0, max(this_fd.ts.Data) * 1.05]; % These are bad bounds setters
    if ylims == [0,0];
      ylims = [0,1];
    end
    
    % Axes Bounds Calculation
    y_max = max(this_fd.ts.Data, [], 'omitnan');
    y_min = min(this_fd.ts.Data, [], 'omitnan');
    
    x_max = max(this_fd.ts.Time, [], 'omitnan');
    x_min = min(this_fd.ts.Time, [], 'omitnan');
    
    if isnan(x_max) || x_max == 0; x_max = 1; end
    if isnan(x_min); x_min = 0; end
    if isnan(y_max) || y_max == 0; y_max = 1; end
    if isnan(y_min) || y_min > 0; y_min = 0; end
    
    hs.ax.YLim = [y_min, y_max] * 1.05;
    
    time_bounds = [x_min, x_max];
    delta_t = diff(time_bounds);
    time_pad = delta_t * 0.05;
    hs.ax.XLim = datetime([time_bounds(1) - time_pad, time_bounds(2) + time_pad], 'convertfrom', 'datenum');
    
    disp(event)
    disp(hobj)
    
  end

  function populate_tab_tree(~, ~)
    
    hs.visible_tab_grid.Parent = hs.tabs.SelectedTab;
    if isfield(hs, 'tree')
      hs.tree.delete
    end
    
    hs.tree = uitree(hs.visible_tab_grid, 'SelectionChangedFcn', @node_selected);
    hs.rootNode = uitreenode(hs.tree, 'Text', hs.tabs.SelectedTab.UserData, 'NodeData', hs.tabs.SelectedTab.UserData);
    
    D = dir(hs.tabs.SelectedTab.UserData);
    dir_mask = [D.isdir] == true;
    DIRS = D(dir_mask);
    
    for i = 1:length(DIRS)
      this_dir = DIRS(i);
      if this_dir.name(1) == '.'
        % skip hidden and . or ..
        continue
      end
      uitreenode(hs.rootNode, 'Text', this_dir.name, 'Icon',FOLDER_ICON, 'NodeData', fullfile(hs.tabs.SelectedTab.UserData, this_dir.name));
    end
    
    hs.rootNode.expand();
  end

  function node_selected(hobj, event)
    disp(event);
    set(event.PreviousSelectedNodes, 'Icon', FOLDER_ICON);
    set(event.SelectedNodes, 'Icon', FOLDER_GOOD);
    
    node_path = event.SelectedNodes.NodeData; % full path of data set
    debugout(node_path);
    
    metaDataFile  = fullfile(node_path, 'data', 'metadata.mat');
    fd_index_file = fullfile(node_path, 'data', 'AvailableFDs.mat');
    
    %% Data Set Selection Population
    s = load(fd_index_file);
    FDList = s.FDList;
    hs.fd_selection.set_items(FDList(:,1), FDList(:,2));
    
  end

  function temp_search(hobj, event)
    % fprintf('edit value: %s \t event value: %s\n', hobj.Value, event.Value);
    search_str = event.Value;
    
  end

end
