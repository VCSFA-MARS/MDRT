function hs = makeSettingsGUI( varargin )
%makeSettingsGUI creates the MARS DRT settings panel.
%
% Called by itself, it generates a stand-alone gui.
% Pass a handle to a parent object, and the settings panel will populate
% the parent object.
%
% makeSettingsGUI returns a handle structure
%
% Counts, 2016 VCSFA

if nargin == 0
    % Run as standalone GUI for testing

    hs.fig = figure;
        guiSize = [672 387];
        hs.fig.Position = [hs.fig.Position(1:2) guiSize];
        hs.fig.Name = 'Data Comparison Plotter';
        hs.fig.NumberTitle = 'off';
        hs.fig.MenuBar = 'none';
        hs.fig.ToolBar = 'none';
        
elseif nargin == 1
    % Populate a UI container
    
    hs.fig = varargin{1};
    
end
        
        
        
%% User Interface Locations/Dimensions - variable definitions        
% -------------------------------------------------------------------------

    % Edit box variables
    eb_x_loc = 200;
    eb_y_loc = [315   271   227   183   138    94    50]; 
    eb_width = 400;
    eb_height= 22;

    % Button variables
    b_x_loc = 50;
    b_y_loc = eb_y_loc;
    b_wide  = 137;
    b_tall  = 21;
    
    editBoxInfo = { 
        'edit_dataArchive' ,    '', 'dataArchivePath';
        'edit_importDataPath' , '', 'importDataPath';
        'edit_remoteDataPath' , '', 'remoteArchivePath';
        'edit_plotOutput' ,     '', 'plotOutputPath';
        'edit_workingPath' ,    '', 'workingPath';
        'edit_graphConfigPath', '', 'graphConfigPath';
    };

               % field                  String                      Tag                % Tooltip
    buttonInfo={'button_archive'        'Data Archive Path'         'dataArchive'       'Set Data Archive Path'             1;
                'button_import'         'Import Data Path'          'importDataPath'    'Set Data Archive Path'             1;
                'button_remote'         'Remote Archive Path'       'remoteArchivePath' 'Set Remote Data Archive Path'      1;
                'button_output'         'Plot Output Path'          'outputPath'        'Set Plot Output Path'              1;
                'button_working'        'Working Path'              'workingPath'       'Set Working Path'                  1;
                'button_graphConfig'    'Graph Configuration Path'  'graphConfig'       'Set Graph Configuration Path'      1;
                'button_saveConfig'     'Save Configuration'        'saveConfig'        'Save Graph Configuration to Disk'  2;
              };
            
        
%% Configuration object instantiation
% -------------------------------------------------------------------------
    
    % MDRTConfig is now a singleton handle class!
    config = MDRTConfig.getInstance;


%% Button Generation
% -------------------------------------------------------------------------

    for n = 1:size(buttonInfo, 1)

        hs.(buttonInfo{n,1}) = 	uicontrol(hs.fig,...
            'String',           buttonInfo{n,2},...
            'Callback',         @pushButtonCallback,...
            'Tag',              buttonInfo{n,3},...
            'ToolTipString',    buttonInfo{n,4},...
            'Position',         [b_x_loc, b_y_loc(n), b_wide, b_tall*buttonInfo{n,5}] ...
        );
        
    end


        
%% Edit Box Generation
% -------------------------------------------------------------------------

    for n = 1:size(editBoxInfo, 1)
        hs.(editBoxInfo{n,1}) =   uicontrol(hs.fig,...
            'Style',                'edit',...
            'String',               editBoxInfo{n,2},...
            'HorizontalAlignment' , 'left',...
            'Position',             [eb_x_loc, eb_y_loc(n), eb_width, eb_height],...
            'tag',                  editBoxInfo{n,3} ...
        );
    end

        

        
%% Populate GUI from Configuration
% -------------------------------------------------------------------------

    populateEditBoxContents();
 
    
    function populateEditBoxContents()
        
        hs.edit_dataArchive.String      = config.dataArchivePath;
        hs.edit_importDataPath.String   = config.importDataPath;
        hs.edit_remoteDataPath.String   = config.remoteArchivePath;
        hs.edit_plotOutput.String       = config.userSavePath;
        hs.edit_workingPath.String      = config.userWorkingPath;
        hs.edit_graphConfigPath.String  = config.graphConfigFolderPath;
        
    end
    

    function pushButtonCallback(hObj, event)
    
        % get a starting path
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
            case 'saveConfig'
                % TODO - move this to its own callback?
                config.writeConfigurationToDisk;
                return;
            otherwise
                % Something's gone very wrong. soft fail
                return
        end
        
        % Check guess path for validity
        if ~exist(guessPath, 'dir')
            % If the path isn't there, default to a different path
            guessPath = pwd;
        end
        
        % UI Choose Folder Window Title:
        windowTitle = strjoin({'Choose', hObj.String});
        targetPath = uigetdir(guessPath, windowTitle);
        
        % Cancel setting value if user presses cancel
        if ~targetPath
            % Just stop execution
            return
        end
        
        
        
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
        
    end
        
end