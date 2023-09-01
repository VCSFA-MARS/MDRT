function hs = makeDataImportGUI( varargin )
%makeDataImportGUI creates the MARS DRT settings panel.
%
% Called by itself, it generates a stand-alone gui.
% Pass a handle to a parent object, and the settings panel will populate
% the parent object.
%
% makeDataImportGUI returns a handle structure
%
% Counts, 2016 VCSFA

Config = MDRTConfig.getInstance;

figureName = 'Data Import GUI';
overrideWindowDelete = true;

MAX_TRYS = 10; % Lines of a .csv to read before giving up

if nargin == 0
    % Run as standalone GUI for testing
    % Run as standalone GUI for testing

    hs.fig = figure;
        guiSize = [672 387];
        hs.fig.Position = [hs.fig.Position(1:2) guiSize];
        hs.fig.Name = figureName;
        hs.fig.NumberTitle = 'off';
        hs.fig.MenuBar = 'none';
        hs.fig.ToolBar = 'none';
        hs.fig.Tag = 'importFigure';
        
        if overrideWindowDelete
            hs.fig.DeleteFcn = @windowCloseCleanup;
        end

elseif nargin == 1
    % Populate a UI container
    
    hs.fig = varargin{1};
    
end


%% Shared variabls for GUI

fileArray = {};
metaData = newMetaDataStructure;






%% Button Parameters

buttonPositions = { [50 321 151 49];
                    [15 240 101 21];
                    [500 19 151 49];
                    };
                    
buttonTags          =   {   'button_newSession';
                            'button_selectFiles';
                            'button_importFiles';
                        };
                    

buttonStrings       =   {   'New Data Import Session';
                            'Select Files';
                            'Import FCS Data'
                        };


buttonCallbacks     =   {   @resetGUI;
                            @selectFiles;
                            @startImport
                        };
                            
                
buttonParents       =   {   'fig';
                            'panel_files';
                            'fig'
                        };
                    

%% Checkbox Parameters

checkboxPositions       = { [300 339 117 23];
                            [14 114 111 23];
                            [14 81 111 23];
                            [14 48 111 23];
                            [14 15 111 23];
                            [300 130 200 23];
                            [300 100 200 23];
                            [300  70 200 23];
                            [300  40 200 23];
                            [300  10 200 23]
                            };

                        
checkboxTags            = { 'checkbox_autoName';
                            'checkbox_isOperation';
                            'checkbox_isMARS';
                            'checkbox_hasUID';
                            'checkbox_vehicleSupport';
                            'checkbox_autoSkipErrors';
                            'checkbox_combineDelims';
                            'checkbox_importRaw';
                            'checkbox_pad_c_data';
                            'checkbox_legacy_importer';
                            };
                            

checkboxStrings         = { 'Auto-name folder';
                            'Operation';
                            'MARS Procedure';
                            'Has MARS UID';
                            'Vehicle support';
                            'Auto-skip parsing errors';
                            '.delims are from different TAMs';
                            'Import RAW data';
                            'Import Pad-0C .csv';
                            'Use legacy parser';
                            };


checkboxParents         =   {   'fig';
                                'panel_metaData';
                                'panel_metaData';
                                'panel_metaData';
                                'panel_metaData';
                                'fig';
                                'fig';
                                'fig';
                                'fig';
                                'fig';
                            };
                        
checkboxValue           =   {   true;
                                false;
                                false;
                                false;
                                false;
                                true;
                                false;
                                false;
                                false;
                                false;
                            };
                        
%% Edit Box Parameters

editPositions           =   {   [417 339 233 22];
                                [150 114 190 22];
                                [150  81 190 22];
                                [150  48 190 22]
                            };


editTags                =   {   'edit_folderName';
                                'edit_operationName';
                                'edit_procedureName';
                                'edit_UID'
                            };


editStrings             =   {   '';
                                '';
                                '';
                                '';
                            };


editEnabled             =   {   'inactive';
                                'off';
                                'off';
                                'off'
                            };
                        
editParents             =   {   'fig';
                                'panel_metaData';
                                'panel_metaData';
                                'panel_metaData';
                                'panel_metaData'
                            };
                        
%% Panel Properties

panelPositions      =   {   [50   13 234 301];
                            [300 152 351 156]
                        };

panelStrings        =   {   'Raw data file selection';
                            'Data Set Metadata Entry'
                        };
                    
panelTags           =   {   'panel_files';
                            'panel_metaData'
                        };



%% Listbox Propertiess
                    
listboxPosition = [15 16 201 201];


%% GUI Label Properties

labelStrings        =   {   'Choose files to import';
                            'Retrieval files to import'
                        };


labelPositions      =   {   [ 14 266 201  13];
                            [ 15 222 201  13]
                        };


labelParents        =   {   'panel_files';
                            'panel_files'
                        };


%% GUI Generation

% UI Panel Generation
for i = 1:numel(panelPositions)
    
    hs.(panelTags{i}) = uipanel( hs.fig, ...
                            'Units',            'pixels',...
                            'Position',         panelPositions{i} ,...
                            'Title',            panelStrings{i},...
                            'Tag',              panelTags{i} ...
                        );

end

% Checkbox Generation
for i = 1:numel(checkboxTags)
    
    hs.(checkboxTags{i}) = uicontrol( ...
                            hs.(checkboxParents{i}), ...
                            'Style',            'checkbox',...
                            'Units',            'pixels',...
                            'Position',         checkboxPositions{i} ,...
                            'String',           checkboxStrings{i},...
                            'Tag',              checkboxTags{i}, ...
                            'Value',            checkboxValue{i}, ...
                            'Callback',         @controllerDataImportGUI ...
                        );

end

% Edit Box Generation
for i = 1:numel(editTags)
    
    hs.(editTags{i}) = uicontrol( ...
                            hs.(editParents{i}), ...
                            'Style',            'edit', ...
                            'Units',            'pixels', ...
                            'Position',         editPositions{i}, ...
                            'String',           editStrings{i}, ...
                            'Tag',              editTags{i}, ...
                            'HorizontalAlignment',  'left', ...
                            'Enable',           editEnabled{i}, ...
                            'Callback',         @controllerDataImportGUI ...
                        );

end

% Button Generation
for i = 1:numel(buttonTags)
    
    hs.(buttonTags{i}) = uicontrol( ...
                            hs.(buttonParents{i}), ...
                            ...
                            'Units',            'pixels', ...
                            'Position',         buttonPositions{i}, ...
                            'String',           buttonStrings{i}, ...
                            'Tag',              buttonTags{i}, ...
                            'Callback',         buttonCallbacks{i} ...
                        );

end

% Label Generation
for i = 1:numel(labelPositions)
    
                            uicontrol( ...
                            hs.(labelParents{i}), ...
                            'Style',            'text', ...
                            'Units',            'pixels', ...
                            'Position',         labelPositions{i}, ...
                            'HorizontalAlignment', 'left', ...
                            'String',           labelStrings{i} ...
                        );

end
                            
% Listbox Generation - for import file list and drag/drop

flbManager = FileListBox;
flbManager.makeAndPlaceListBox(     hs.panel_files, ...
                                    'Units',            'pixels', ...
                                    'Position',         listboxPosition ...
                               );
                           
%% Add Listeners to GUI properties and flibManager

addlistener(flbManager, 'fileList', 'PostSet', @updateFolderGuess);

el(1) = addlistener(hs.edit_folderName,    'String', 'PostSet', @updateFolderGuess);
el(2) = addlistener(hs.edit_operationName, 'String', 'PostSet', @updateFolderGuess);
el(3) = addlistener(hs.edit_procedureName, 'String', 'PostSet', @updateFolderGuess);
el(4) = addlistener(hs.edit_UID,           'String', 'PostSet', @updateFolderGuess);
el(5) = addlistener(hs.checkbox_autoName,  'Value',  'PostSet', @updateFolderGuess);





    
    

%% Set Initial Value Cell Array from GUI Generation Results

initialValues =    ...
    {   'checkbox_autoName',        'Value',    hs.checkbox_autoName.Value;
        'checkbox_isOperation',     'Value',    hs.checkbox_isOperation.Value; 
        'checkbox_isMARS',          'Value',    hs.checkbox_isMARS.Value;
        'checkbox_hasUID',          'Value',    hs.checkbox_hasUID.Value;
        'checkbox_vehicleSupport',  'Value',    hs.checkbox_vehicleSupport.Value;
        'checkbox_legacy_importer', 'Value',    hs.checkbox_legacy_importer.Value;
        
        'edit_folderName',          'String',   hs.edit_folderName.String;
        'edit_operationName',       'String',   hs.edit_operationName.String;
        'edit_procedureName',       'String',   hs.edit_procedureName.String;
        'edit_UID',                 'String',   hs.edit_UID.String;
        
        'edit_folderName',          'Enable',   hs.edit_folderName.Enable;
        'edit_operationName',       'Enable',   hs.edit_operationName.Enable;
        'edit_procedureName',       'Enable',   hs.edit_procedureName.Enable;
        'edit_UID',                 'Enable',   hs.edit_UID.Enable
    };


    function updateMetaDataFromGUI
        % Grab contents of relevent metadata entry uicontrols
            metaData.operationName     = hs.edit_operationName.String;
            metaData.MARSprocedureName = hs.edit_procedureName.String;
            metaData.MARSUID           = hs.edit_UID.String;

            metaData.isOperation        = hs.checkbox_isOperation.Value; 
            metaData.isMARSprocedure    = hs.checkbox_isMARS.Value;
            metaData.hasMARSuid         = hs.checkbox_hasUID.Value;
            metaData.isVehicleOp        = hs.checkbox_vehicleSupport.Value;
    end

    fixFontSizeInGUI(hs.fig, Config.fontScaleFactor);


    function updateFolderGuess(varargin)
        
        updateMetaDataFromGUI;
        
        
        
        files = flbManager.getFileCellArray;
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
            if any(ismember(fopen('all'), fid))
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
                hs.edit_folderName.String = guessName;
            end
        el(1).Enabled = true;
        
    end


    function startImport(~, ~, varargin)
        
        updateFolderGuess;
        
        delim_list = flbManager.getFileCellArray;
        
        if hs.checkbox_pad_c_data.Value
            % PLACEHOLDER for PAD-C import call
            metaData.site = 'Pad-0C';
            ImportPadCFromGUI(  delim_list, ... 
                                metaData, ...
                                hs.edit_folderName.String, ...
                                hs.checkbox_autoSkipErrors.Value );
            metaData = rmfield(metaData, 'site');
            return
        end
        

        ImportFromGUI(  delim_list, ... 
                        metaData, ...
                        hs.edit_folderName.String, ...
                        hs.checkbox_autoSkipErrors.Value, ...
                        hs.checkbox_combineDelims.Value, ...
                        hs.checkbox_importRaw.Value, ...
                        hs.checkbox_legacy_importer.Value);
        return

        
    end


    function selectFiles(~, ~, varargin)
        
        [filename, pathname, filterindex] = uigetfile( ...
                       {'*.delim','FCS Retrievals (*.delim)'; ...
                        '*.csv','MARDAQ Files (*.csv)'; ...
                        '*.*',  'All Files (*.*)'}, ...
                        'Pick a file', ...
                        'MultiSelect', 'on');
                    
        
        
        if isempty(filename)
            % User cancelled - do nothing
            return
        end
        
        
        if filterindex == 2; errordlg('MARDAQ and .csv importing is not supported at this time');return;end
        
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
        
        % Add files to the file list box manager
        for j = 1:numel(filesToAdd)
            flbManager.addFilesToList( filesToAdd{j} );
        end
        
    end


    function resetGUI(src, event, varargin)
        
        % Reset import variables
        flbManager.clearFileList;
        
        % Pause event listeners to GUI objects being reset
        for j = 1:numel(el)
            el(j).Enabled = false;
        end
        
        % Set GUI elements to initialValues
        for j = 1:length(initialValues)
            hs.(initialValues{j,1}).(initialValues{j,2}) = initialValues{j,3};
        end
        
        % Resume event listeners to GUI objects being reset
        for j = 1:numel(el)
            el(j).Enabled = true;
        end
        
        metaData = newMetaDataStructure;
%         updateMetaDataFromGUI;
        
        
    end

       
    function windowCloseCleanup(varargin)

        debugout('Closing window')

        delete(flbManager)

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



end



