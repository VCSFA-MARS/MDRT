function hs = dataImportGUI(Parent)

config = MDRTConfig.getInstance();
hs = struct;
MAX_TRYS = 10; % Lines of a .csv to read before giving up

fileArray = {}; % {fullfile, filename;}
allowable_extensions = {'.delim', '.csv'};

metaData = newMetaDataStructure;

  %% Argument Parsing - handle stand-alone or tabbed/windowed

  if nargin == 1
    if ~ishghandle(Parent)
      error('Expected a hghandle/container. Was passed a %s', class(Parent));
    end
  end


  %% Figure Creation

  if nargin == 0
    hs.fig = uifigure();
    hs.fig.Name = 'MDRT Data Importer';
    hs.fig.NumberTitle = 'off';
    hs.fig.MenuBar = 'none';
    hs.fig.ToolBar = 'none';
  else
    hs.fig = Parent;
  end

LAYOUT_GRID = [5, 2];
g = uigridlayout(hs.fig, LAYOUT_GRID);
g.RowHeight = {'fit','fit','fit','fit','fit'};

%% Component Creation

% button_new_session = uibutton(g, 'Text', 'New Data Import Session');
% button_new_session.Layout.Row = 1;

%% Auto Name Creation

gl_folder_row = uigridlayout(g, [1,2]);
gl_folder_row.Layout.Row = 1;
gl_folder_row.Layout.Column = [1,2];
gl_folder_row.ColumnWidth = {'fit', '1x'};
 
hs.checkbox_autoName = uicheckbox(gl_folder_row, 'Text', 'Auto-name folder', 'Value', true);
hs.checkbox_autoName.Layout.Column = 1;

hs.edit_folderName = uieditfield(gl_folder_row);
hs.edit_folderName.Layout.Column = 2;


%% File selection and list

file_pane = uipanel(g, 'Title', 'Data File Selection');
file_pane.Layout.Row = [2,3];
file_pane.Layout.Column = 1;

gf_file_pane = uigridlayout(file_pane, [4,1] );

hs.button_select_file = uibutton(gf_file_pane,  ...
  'Text',             'Select Files',           ...
  'Tag',              'button_selectFiles',     ...
  'ButtonPushedFcn',  @button_callback);


hs.file_listbox = uilistbox(gf_file_pane, 'Value', {});
hs.file_listbox.Layout.Row = [2,4];
DnD_uifigure(hs.file_listbox, @file_dropped);


%% Metadata Panel Creation

pane_metadata = uipanel(g, 'Title', 'Data Set Metadata Entry');
pane_metadata.Layout.Row = 2;

gl_metadata = uigridlayout(pane_metadata,[4,2]);
gl_metadata.ColumnWidth = {'fit', '1x'};

hs.checkbox_isOperation   = uicheckbox(gl_metadata, 'Text', 'Operation', 'Tag', 'checkbox_isOperation');
hs.checkbox_isOperation.Layout.Row = 1;
hs.checkbox_isOperation.Layout.Column = 1;

hs.checkbox_isMARS   = uicheckbox(gl_metadata, 'Text', 'MARS Procedure', 'Tag', 'checkbox_isMARS');
hs.checkbox_isMARS.Layout.Row = 2;
hs.checkbox_isMARS.Layout.Column = 1;

hs.checkbox_hasUID = uicheckbox(gl_metadata, 'Text', 'Has MARS ID', 'Tag', 'checkbox_hasUID');
hs.checkbox_hasUID.Layout.Row = 3;
hs.checkbox_hasUID.Layout.Column = 1;

hs.checkbox_vehicleSupport     = uicheckbox(gl_metadata, 'Text', 'Vehicle Support', 'Tag', 'checkbox_vehicleSupport');
hs.checkbox_vehicleSupport.Layout.Row = 4;
hs.checkbox_vehicleSupport.Layout.Column = 1;


hs.edit_operationName = uieditfield(gl_metadata, ...
  'Tag',                        'edit_operationName', ...
  'ValueChangedFcn',            @updateMetaDataFromGUI);
hs.edit_operationName.Layout.Column = 2;
hs.edit_operationName.Layout.Row = 1;

hs.edit_procedureName = uieditfield(gl_metadata, 'Tag', 'edit_procedureName', 'ValueChangedFcn', @updateMetaDataFromGUI);
hs.edit_procedureName.Layout.Row = 2;
hs.edit_procedureName.Layout.Column = 2;


hs.edit_UID = uieditfield(gl_metadata, 'Tag', 'edit_UID', 'ValueChangedFcn', @updateMetaDataFromGUI);
hs.edit_UID.Layout.Row = 3;
hs.edit_UID.Layout.Column = 2;

%% Option Pane

pane_options = uipanel(g, 'Title', 'Import Options');
pane_options.Layout.Row = 3;

gl_options = uigridlayout(pane_options,[7,1]);
% gl_options.ColumnWidth = {'fit', '1x'};
gl_options.RowHeight = {'fit'};

hs.checkbox_autoSkipErrors   = uicheckbox(gl_options, ...
                        'Text',     'Auto-skip parsing errors', ...
                        'Value',    true);
hs.checkbox_autoSkipErrors.Layout.Row = 1;
hs.checkbox_autoSkipErrors.Layout.Column = 1;

hs.checkbox_combineDelims   = uicheckbox(gl_options, ...
                        'Text',     '.delims are from different TAMs', ...
                        'Value',    false);
hs.checkbox_combineDelims.Layout.Row = 2;
hs.checkbox_combineDelims.Layout.Column = 1;

hs.checkbox_importRaw   = uicheckbox(gl_options, ...
                        'Text',     'Import RAW data', ...
                        'Value',    false);
hs.checkbox_importRaw.Layout.Row = 3;
hs.checkbox_importRaw.Layout.Column = 1;

hs.checkbox_pad_c_data   = uicheckbox(gl_options, ...
                        'Text',     'Import Pad-0C csv', ...
                        'Value',    false);
hs.checkbox_pad_c_data.Layout.Row = 4;
hs.checkbox_pad_c_data.Layout.Column = 1;


hs.checkbox_legacy_importer = uicheckbox(gl_options, ...
                        'Text',     'Use Legacy parser', ...
                        'Value',    false);
hs.checkbox_legacy_importer.Layout.Row = 5;
hs.checkbox_legacy_importer.Layout.Column = 1;

hs.checkbox_valve_timing   = uicheckbox(gl_options, ...
                        'Text',     'Process Pad-0C Valve Timing', ...
                        'Value',    false);
hs.checkbox_valve_timing.Layout.Row = 6;
hs.checkbox_valve_timing.Layout.Column = 1;

%% Control Buttons

gl_controls = uigridlayout(g, [1,3]);
gl_controls.Layout.Column = [1,2];
gl_controls.RowHeight = {'2x'};

button_new_session = uibutton(gl_controls, 'Text', 'New Data Import Session', 'ButtonPushedFcn', @button_callback, 'Tag', 'button_newSession');
button_new_session.Layout.Column = 1;

button_start_import = uibutton(gl_controls, 'Text', 'Import Data', 'Tag', 'button_importFiles', 'ButtonPushedFcn', @button_callback);
button_start_import.Layout.Column = 3;


%% Initial Values --------------------------------
% Building initial values based on properties from object instantiation (in
% code above). Only the items in this array will be 'reset' for a new
% session.

initialValues =    ...
    ... % UI_object_tag             Property    Value
    {   'checkbox_autoName',        'Value',    hs.checkbox_autoName.Value;
        'checkbox_isOperation',     'Value',    hs.checkbox_isOperation.Value; 
        'checkbox_isMARS',          'Value',    hs.checkbox_isMARS.Value;
        'checkbox_hasUID',          'Value',    hs.checkbox_hasUID.Value;
        'checkbox_vehicleSupport',  'Value',    hs.checkbox_vehicleSupport.Value;
        'checkbox_legacy_importer', 'Value',    hs.checkbox_legacy_importer.Value;
        
        'edit_folderName',          'Value',    hs.edit_folderName.Value;
        'edit_operationName',       'Value',    hs.edit_operationName.Value;
        'edit_procedureName',       'Value',    hs.edit_procedureName.Value;
        'edit_UID',                 'Value',    hs.edit_UID.Value;
        
        'edit_folderName',          'Enable',   hs.edit_folderName.Enable;
        'edit_operationName',       'Enable',   hs.edit_operationName.Enable;
        'edit_procedureName',       'Enable',   hs.edit_procedureName.Enable;
        'edit_UID',                 'Enable',   hs.edit_UID.Enable
    };

resetGUI();


%% +---------------------------------------------------------------------+
%  |              End of GUI Creation - Start of Callbacks               |
%  +---------------------------------------------------------------------+

    function resetGUI(hobj, event)
        % Reset the import file list
        fileArray = {};
        hs.file_listbox.Value = {};
        hs.file_listbox.Items = {};

        % Pause event listeners ?

        % Set GUI elements to initial values
        for j = 1:height(initialValues)
            this_obj = hs.(initialValues{j,1});
            this_prop = initialValues{j,2};
            this_val  = initialValues{j,3};
            this_obj.(this_prop) = this_val;
        end

        % Resume event listeners

        % reset GUI metadata var
        updateMetaDataFromGUI()
        

    end

  function reset_file_list()
    fileArray = {};
    hs.file_listbox.Value = {};
    hs.file_listbox.Items = {};
  end

  function add_files_to_listbox(files_to_add)
    % Add files to the file list box manager
    if ischar(files_to_add)
      files_to_add = {files_to_add};
    end

    for j = 1:numel(files_to_add)
      this_fullfile = files_to_add{j};
      [~, fname, ext] = fileparts(this_fullfile);
      this_filename = [fname, ext];
      fileArray = vertcat(fileArray, {this_fullfile, this_filename});
    end

    hs.file_listbox.Items = fileArray(:,2);

  end



  function button_callback(hobj, event)

    switch hobj.Tag
      case 'button_newSession'
        resetGUI();
      case 'button_selectFiles'
        selectFiles();
      case 'button_importFiles'
        startImport();
      otherwise
        disp(hobj);
    end

  end


  function updateMetaDataFromGUI(~, ~)

    % update global metaData from GUI state
    metaData.operationName     = hs.edit_operationName.Value;
    metaData.MARSprocedureName = hs.edit_procedureName.Value;
    metaData.MARSUID           = hs.edit_UID.Value;

    metaData.isOperation        = hs.checkbox_isOperation.Value;
    metaData.isMARSprocedure    = hs.checkbox_isMARS.Value;
    metaData.hasMARSuid         = hs.checkbox_hasUID.Value;
    metaData.isVehicleOp        = hs.checkbox_vehicleSupport.Value;


    updateFolderGuess();

  end


  function file_dropped(~, event)
    % Callback for DnD_uifigure - event has `names` field, which is a cell
    % array of fullfile paths.

    for i = 1:numel(event.names)

      this_file = char(event.names{i});

      [~, ~, ext] = fileparts(this_file);
      if ~isempty(fileArray) && any(contains(fileArray(:,1), this_file))
        debugout(sprintf('File already in list: %s', this_file));
        return
      end

      if ~contains(allowable_extensions, ext)
        debugout(sprintf('Skipping file for unsupported extension: %s', ext));
        return
      end

      add_files_to_listbox(this_file);
    end

    updateFolderGuess();
  end


  function updateFolderGuess(varargin)
    if ~ hs.checkbox_autoName.Value
      return
    end

    if isempty(fileArray)
      return
    end

    files = fileArray(:,1);
    guessFile = cell(numel(files), 1);

    for j = 1:numel(files)
      finfo = dir(files{j});
      [~, ~, ext] = fileparts(finfo.name);
      if any(strcmpi({'.csv', '.delim'}, ext)) && (finfo.bytes > 0) % if delim and not empty
        guessFile{j} = files{j}; % fullfile path
      end
    end

    if isCellArrayEmpty(guessFile)
      % No suitable file was found
      return
    end

    % Read the first line of each .delim file and keep the timestamp.
    guessFile = nonEmptyCellContents(guessFile);
    startTime = zeros(numel(guessFile), 1);

    for j = 1:numel(guessFile)

      % Open guess file to read a few lines
      fid = fopen(guessFile{j});
      finfo = dir(guessFile{j});
      [~, ~, ext] = fileparts(finfo.name);

      % Make sure to handle the file type. and EXIT if bad filetype
      % -----------------------------------------------------------------

      switch lower(ext)
        case '.delim'
          debugout('Pre-processing .delim file')
          textParseString = '%s %*s %*s %*s %*s %*s %*[^\n]';
          try
            rawTime = textscan(fid,textParseString,1,'Delimiter',',');
          catch
            % If you're here, then the file was called .delim,
            % it had a non-zero size, and the text-parse still
            % failed. File must be malformed.
            warning(['delim file ' finfo.name ' was malformed.']);
          end

          fclose(fid); % cleanup your mess!

          % Keep the timestamp we found for later
          try
            startTime(j,1) = makeMatlabTimeVector(rawTime{1}, false, false);
          catch
            % If you're here, then the file was called .delim,
            % it had a non-zero size, but the contents didn't
            % contain data the way we expected. The file must
            % be malformed.
            warning(['delim file ' finfo.name ' was malformed.']);
          end

        case '.csv'
          debugout('Processing .csv file')
          RL_Time_RE = '\d{4}-\d{2}-\d{2}[Tt]\d{2}:\d{2}:\d{2}.\d+Z';
          RL_Time_fmt = 'yyyy-mm-ddTHH:MM:SS.FFF';

          for n = 1:MAX_TRYS
            this_line = fgetl(fid);
            if any(regexp(this_line, RL_Time_RE))
              time_str = regexp(this_line, RL_Time_RE, 'match');
              startTime(j, 1) = datenum(time_str, RL_Time_fmt);
              break
            end
          end

        otherwise
          warning(['The file ' finfo.name ' is of a type not currently supported for automatic import']);
          fclose(fid);
          return
      end

      %This was throwing errors sometimes saying fid was already
      %closed. Added a check to squash. Is there really a path
      % through the case statement that doesn't close the file?
      if verLessThan('matlab', '24')
        all_open_fileIDs = ismember(fopen('all'), fid);
      else
        all_open_fileIDs = openedFiles;
      end

      if any(all_open_fileIDs == fid)
        fclose(fid);
      end

    end

    startTime = min(startTime(startTime ~= 0));

    % Build Folder Name String
    % -----------------------------------------------------------------

    nameParts = {   metaData.operationName;
      metaData.MARSprocedureName
      };

    if isempty(startTime)
      return
    end

    guessName = strjoin( {  datestr(startTime, 'YYYY-mm-dd');
      '-';
      strjoin(nameParts);
      });

    guessName = strtrim(guessName);

    % Listener triggers on this update. Disabling/enabling around the
    % programatic update. In a class, this should be a set method to
    % handle it. Ugly workaround to clean up console output.

    el(1).Enabled = false;
    if hs.checkbox_autoName.Value
      hs.edit_folderName.Value = guessName;
    end
    el(1).Enabled = true;

  end


  function outCell = nonEmptyCellContents(inCell)
    if iscell(inCell)
      outCell = inCell(~cellfun('isempty',inCell));
    else
      % not a cell as input!
      outCell = cell(1,1);
    end
  end


  function result = isCellArrayEmpty(inCell)
    if iscell(inCell)
      result = ~max(~cellfun('isempty', inCell));
      if isempty(result)
        result = true;
      end
    else
      result = [];
    end
  end


  function selectFiles()

    [filename, pathname, ~] = uigetfile( ...
      {'*.delim','FCS Retrievals (*.delim)'; ...
      '*.csv','Pad-0C Files (*.csv)'; ...
      '*.*',  'All Files (*.*)'}, ...
      'Pick a file', ...
      'MultiSelect', 'on');

    if isempty(filename)
      % User cancelled - do nothing
      return
    end

    filesToAdd = {};

    if isa(filename, 'cell')
      % Multiple files selected!
      for i = 1:numel(filename)
        filesToAdd = vertcat(filesToAdd, ...
          fullfile(pathname, filename{i}));
      end
    elseif isa(filename, 'char')
      filesToAdd = vertcat(filesToAdd, ...
        fullfile(pathname, filename));
    else
      % What would cause this?
      return
    end

    add_files_to_listbox(filesToAdd)

  end


      function startImport(~, ~, varargin)
        
        updateFolderGuess();
        
        if isempty(fileArray)
          return
        end

        delim_list = fileArray(:,1);
        
        if hs.checkbox_pad_c_data.Value
            % PLACEHOLDER for PAD-C import call
            metaData.site = 'Pad-0C';
            ImportPadCFromGUI(  delim_list, ... 
                                metaData, ...
                                hs.edit_folderName.Value, ...
                                hs.checkbox_autoSkipErrors.Value );
            metaData = rmfield(metaData, 'site');
            return
        end
        

        ImportFromGUI(  delim_list, ... 
                        metaData, ...
                        hs.edit_folderName.Value, ...
                        hs.checkbox_autoSkipErrors.Value, ...
                        hs.checkbox_combineDelims.Value, ...
                        hs.checkbox_importRaw.Value, ...
                        hs.checkbox_legacy_importer.Value);
        return

        
    end


end % dataImportGUI()