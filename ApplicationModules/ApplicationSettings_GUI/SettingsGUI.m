function hs = SettingsGUI(Parent)

  if nargin == 1
    if ~ishghandle(Parent)
      error('Expected a hghandle/container. Was passed a %s', class(Parent));
    end
  end

  config = MDRTConfig.getInstance();
  backupConfig = struct;
  make_backup_config();

  hs = struct;

  if nargin == 0
    hs.fig = uifigure();
      hs.fig.Name = 'MDRT Settings';
      hs.fig.NumberTitle = 'off';
      hs.fig.MenuBar = 'none';
      hs.fig.ToolBar = 'none';
  else
    hs.fig = Parent;
  end

  hs.fig_grid = uigridlayout(hs.fig, [4 1]);
  hs.fig_grid.RowHeight = {'fit', 'fit', 'fit', '1x'};

  hs.path_panel = uipanel(hs.fig_grid, 'Title', 'Configuration Paths')

  hs.path_grid = uigridlayout(hs.path_panel, [1 2]);
  hs.path_grid.ColumnWidth = {'fit', '1x'};

  editboxPathSettings = { 
    'edit_dataArchive' ,    '', 'dataArchivePath';
    'edit_importDataPath' , '', 'importDataPath';
    'edit_remoteDataPath' , '', 'remoteArchivePath';
    'edit_graphConfigPath', '', 'graphConfigPath';
  };

  buttonPathSettings={
    % field                  String                      Tag                % Tooltip
    'button_archive'        'Data Archive Path'         'dataArchive'       'Set Data Archive Path'             1;
    'button_import'         'Import Data Path'          'importDataPath'    'Set Data Archive Path'             1;
    'button_remote'         'Remote Archive Path'       'remoteArchivePath' 'Set Remote Data Archive Path'      1;
    'button_graphConfig'    'Graph Configuration Path'  'graphConfig'       'Set Graph Configuration Path'      1;
  };

  editboxActiveSetSettings = {
    'edit_workingPath' ,    '', 'workingPath';
    'edit_workingDataPath', '', 'workingDataPath';
    'edit_workingDelimPath','', 'workingDelimPath'
    'edit_workingPlotPath', '', 'workingPlotPath';
  };

  buttonActiveSetSettings={
    % field                  String                      Tag                % Tooltip
    'button_selected'       'Active Data Set'           'workingPath'       'Set Working Path'                  1;
    'button_actData'        'Active Data Path'          'workingDataPath'   'Active Data Set Data Path'         1;
    'button_actDelim'       'Active Delim Path'         'workingDelimPath'  'Active Data Set Delim Path'        1;
    'button_actPlot'        'Active Plot Path'          'workingPlotPath'   'Active Data Set Plot Path'         1;
    'button_saveConfig'     'Save Configuration'        'saveConfig'        'Save Graph Configuration to Disk'  2;
  };

hs.path_grid.RowHeight = repmat({'fit'}, ...
    height(editboxPathSettings), 1);

hs.selected_grid.RowHeight = repmat({'fit'}, ...
    height(editboxActiveSetSettings), 1);



for r = 1:height(editboxPathSettings)
  this_btn_handle = buttonPathSettings{r,1};
  this_btn_string = buttonPathSettings{r,2};
  this_btn_tag    = buttonPathSettings{r,3};
  this_btn_tip    = buttonPathSettings{r,4};

  hs.(this_btn_handle) = uibutton(hs.path_grid, ...
      'Text',             this_btn_string, ...
      'Tag',              this_btn_tag, ...
      'Tooltip',          this_btn_tip, ...
      'ButtonPushedFcn',  @pushButtonCallback ...
    );

  this_handle = editboxPathSettings{r,1};
  this_value  = editboxPathSettings{r,2};
  this_tag    = editboxPathSettings{r,3};
  hs.(this_handle) = uieditfield(hs.path_grid, ...
                        'Enable', 'off', ...
                        'Value', this_value, ...
                        'Tag', this_tag);
end

%% Selected Data Set Controls

  hs.selected_panel = uipanel(hs.fig_grid, 'Title', 'Configuration Paths')

  hs.selected_grid = uigridlayout(hs.selected_panel, [1 2]);
  hs.selected_grid.ColumnWidth = {'fit', '1x'};

  for r = 1:height(editboxActiveSetSettings)

    if r == 1 % ------- Only have a button for the data set selection -------
      this_btn_handle = buttonActiveSetSettings{r,1};
      this_btn_string = buttonActiveSetSettings{r,2};
      this_btn_tag    = buttonActiveSetSettings{r,3};
      this_btn_tip    = buttonActiveSetSettings{r,4};

      hs.(this_btn_handle) = uibutton(hs.selected_grid, ...
        'Text',             this_btn_string, ...
        'Tag',              this_btn_tag, ...
        'Tooltip',          this_btn_tip, ...
        'ButtonPushedFcn',  @pushButtonCallback ...
      );
    else % add the text labels
      this_text_handle = buttonActiveSetSettings{r, 1};
      this_text_string = buttonActiveSetSettings{r, 2};
      uilabel(hs.selected_grid, 'Text', this_text_string);
    end

    this_handle = editboxActiveSetSettings{r,1};
    this_value  = editboxActiveSetSettings{r,2};
    this_tag    = editboxActiveSetSettings{r,3};

    hs.(this_handle) = uieditfield(hs.selected_grid, ...
      'Enable', 'off', ...
      'Value', this_value, ...
      'Tag', this_tag);
  end

%% Save / Load Controls

hs.load_save_panel = uipanel(hs.fig_grid, 'Title', 'Modify MDRT Configuration')
hs.load_save_grid = uigridlayout(hs.load_save_panel, [1 3]);

hs.button_loadConfig = uibutton(hs.load_save_grid, 'Text', 'Load Config', ...
                          'Tag',             'readConfig', ...
                          'ButtonPushedFcn', @pushButtonCallback);
hs.button_resetGui   = uibutton(hs.load_save_grid, 'Text', 'Reset Changes',...
                          'Tag',             'resetConfig', ...
                          'ButtonPushedFcn', @pushButtonCallback);
hs.button_saveConfig = uibutton(hs.load_save_grid, 'Text', 'Write Config', ...
                          'Tag',             'writeConfig', ...
                          'ButtonPushedFcn', @pushButtonCallback);

populateEditBoxContents();


%% End of GUI Creation - Start of helper/callbacks


  %% Populate GUI From Config
  function populateEditBoxContents()
    hs.edit_dataArchive.Value = config.dataArchivePath;
    hs.edit_remoteDataPath.Value = config.remoteArchivePath;
    hs.edit_importDataPath.Value = config.importDataPath;
    hs.edit_graphConfigPath.Value = config.graphConfigFolderPath;

    hs.edit_workingPath.Value       = config.userWorkingPath;
    hs.edit_workingDataPath.Value   = config.workingDataPath;
    hs.edit_workingDelimPath.Value  = config.workingDelimPath;
    hs.edit_workingPlotPath.Value   = config.workingPlotPath;
  end


  function pushButtonCallback(hObj, event)

    % Get starting folder for selection or handle button callback 
    switch hObj.Tag
      case 'dataArchive'
          guessPath = config.dataArchivePath;
      case 'importDataPath'
          guessPath = config.importDataPath;
      case 'remoteArchivePath'
          guessPath = config.remoteArchivePath;
      case 'outputPath'
          guessPath = config.userSavePath;
      case 'workingPath'
          guessPath = config.userWorkingPath;
      case 'graphConfig'
          guessPath = config.graphConfigFolderPath;

      case 'writeConfig'
        config.writeConfigurationToDisk;
        return;

      case 'readConfig'
        make_backup_config();      % store the last config for restore
        config.readConfigFile();   % update config from disk
        populateEditBoxContents(); % update GUI
        return;

      case 'resetConfig'
        config_from_backup();
        populateEditBoxContents();
        return;

      otherwise
          % Something's gone very wrong. soft fail
          return
      end

      % Default to working dir if guessPath is invalid
      if ~isfolder(guessPath)
        guessPath = pwd;
      end

      % UI Choose Folder Window
      windowTitle = strjoin({'Choose', hObj.Text});
      targetPath = uigetdir(guessPath, windowTitle);

      if ~targetPath
        return
      end
      
      make_backup_config();
      % Set the appropriate configuration variable
      switch hObj.Tag
        case 'dataArchive'
            config.dataArchivePath = targetPath;
        case 'importDataPath'
            config.importDataPath = targetPath;
        case 'remoteArchivePath'
            config.remoteArchivePath = targetPath;
        case 'outputPath'
            config.userSavePath = targetPath;
        case 'workingPath'
            config.userWorkingPath = targetPath;
        case 'graphConfig'
            config.graphConfigFolderPath = targetPath;
        otherwise
            % Something's gone very wrong. soft fail
            return
      end
      populateEditBoxContents();
  end % pushButtonCallback

  function make_backup_config();
    for i = 1:length(config.validConfigKeyNames)
      thisKey = config.validConfigKeyNames{i};
      backupConfig.(thisKey) = config.(thisKey);
    end
  end

  function config_from_backup()
    for i = 1:length(config.validConfigKeyNames)
      thisKey = config.validConfigKeyNames{i};
      config.(thisKey) = backupConfig.(thisKey);
    end
  end


end % SettingsGUI()



