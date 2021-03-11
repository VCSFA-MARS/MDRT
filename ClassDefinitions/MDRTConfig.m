classdef MDRTConfig < handle
    %MDRTConfig All MARS DRT Configuration information, paths, etc. are
    %handled by this class.
    %
    %   MDRTConfig is a SINGLETON. As such, the constructor is not
    %   accessible to outside functions. Callers get an instance or pointer
    %   to the MDRTConfig object instance by calling
    %   configObj = MDRTConfig.getInstance()
    %
    %   Use delete(configObj) to destroy MDRTConfig objects, rather than
    %   clear configObj.
    %
    %
    %
    %   Get and Set methods, 
    %     
    %     set.dataArchivePath
    %     set.graphConfigFolderPath
    %     set.userSavePath
    %     set.userWorkingPath
    %     set.importDataPath
    %   
    %   makeWorkingDirectoryStructure( newWorkingDirectoryRootPath )
    %   makeWorkingDirectoryStructure()
    %
    % Currently supports Data Archive Path and Graph Configuration Path
    
    properties

        % THESE PROPERTIES MUST MATCH validConfigKeyNames!
        % -----------------------------------------------------------------
        
        graphConfigFolderPath   % Directory that contains .gcf files. Plot tool will default to load/save here
        dataArchivePath         % Directory that holds all locally stored, indexed data sets. Comparison tool looks here
        userSavePath            % Target directory for output (graphs, text files, etc) from active data set
        userWorkingPath         % Directory that contains the active data folders (data, delim, plots)
        importDataPath          % Directory that holds all imported data sets. Import tool will create folders here.
        
        % These are normal object properties
        % -----------------------------------------------------------------
        
        configuration           % Meant to emulate the original config struct
        
        % This is a test object to check singleton/handle behavior!
        % -----------------------------------------------------------------
        test
        
    end
    
    properties (Constant)
        prototypeConfigFilePath = 'ClassDefinitions';
        
        % UPDATE THESE from the list above!
        % -----------------------------------------------------------------
        
        % Returns a cell array of the valid public properties of the MDRTConfig class.
        % Used to read/write config files and for other validation tasks. 
        validConfigKeyNames = {...
            'graphConfigFolderPath'; ...
            'dataArchivePath'; ...
            'remoteArchivePath'; ...
            'userSavePath'; ...
            'userWorkingPath'; ...
            'importDataPath'; ...
            };
    end

    properties (Dependent)
        
        workingDataPath         % folder containing the .mat data files, metadata, timeline, and archive index.
        workingDelimPath        % folder where .delim files are copied, processed, and parsed.

    end
    
    properties (Dependent = true, Hidden = true)
        
       pathToConfig
       defaultConfigFile
        
    end
    
    properties (Hidden = true)
        fileContents = {}

        
    end

    
    properties (Constant = true, Hidden = true)
        
        commentSymbol = '#';
        
        applicationName = 'mdrt';

        linuxPrefix = '.';
        configFileName = 'config_linux.txt';

        macConfigFile = 'config_mac.txt';
        winConfigFile = 'config_windows.txt'
        
    end
    
    methods (Access = private)
    %% Contstructor Class - private to allow for singleton implementation    
    % ---------------------------------------------------------------------
        function self = MDRTConfig()

            self.readConfigFile;
                        
            % Dynamically set all config object properties from the
            % configuration structure generated by readConfigFile()
            
%             for i = 1:numel( fields(self.configuration) )
%                 self.(self.validConfigKeyNames{i}) = self.configuration.(self.validConfigKeyNames{i}).value;
%             end
            


        end
        
    end
    
    methods

    %% Set Methods
    %  --------------------------------------------------------------------    
        function set.dataArchivePath(obj,val)
            % Only set if it is a valid path.
            if exist( fullfile(val), 'dir' )
                
                obj.dataArchivePath = fullfile(val);
            else
                
                warning('Invalid path specified. MDRT_DATA_ARCHIVE_PATH not set');
                
                % Invalid path specified. Check if existing value is good
                % and retain or clear
                if exist(obj.dataArchivePath, 'dir')
                    % there is a valid path in the object. Do nothing?
                    
                else
                    % Bad path passed and invalid directory in object.
                    % Clearing object 
                    warning('MDRTConfig.dataArchivePath set to empty string');
                    obj.dataArchivePath = '';
                end
                
            end
            
            obj.updateConfigurationFromProperties;
            
        end
        
        
        function set.remoteArchivePath(obj,val)
            % Only set if it is a valid path.
            if exist( fullfile(val), 'dir' )
                
                obj.remoteArchivePath = fullfile(val);
            else
                
                warning('Invalid path specified. MDRT_REMOTE_ARCHIVE_PATH not set');
                
                % Invalid path specified. Check if existing value is good
                % and retain or clear
                if exist(obj.remoteArchivePath, 'dir')
                    % there is a valid path in the object. Do nothing?
                    
                else
                    % Bad path passed and invalid directory in object.
                    % Clearing object 
                    warning('MDRTConfig.dataArchivePath set to empty string');
                    obj.remoteArchivePath = '';
                end
                
            end
            
            obj.updateConfigurationFromProperties;
            
        end
        
        
        function set.graphConfigFolderPath(obj,val)
            % Only set if it is a valid path.
            if exist( fullfile(val), 'dir' )
                
                obj.graphConfigFolderPath = fullfile(val);
            else
                
                warning('Invalid path specified. MDRT_GRAPH_CONFIG_PATH not set');
                
                % Invalid path specified. Check if existing value is good
                % and retain or clear
                if exist(obj.graphConfigFolderPath, 'dir')
                    % there is a valid path in the object. Do nothing?
                    
                else
                    % Bad path passed and invalid directory in object.
                    % Clearing object 
                    warning('MDRTConfig.graphConfigFolderPath set to empty string');
                    obj.graphConfigFolderPath = '';
                end
                
            end
            
            obj.updateConfigurationFromProperties;
            
        end

        
        function set.userSavePath(obj,val)
            % Only set if it is a valid path.
            if exist( fullfile(val), 'dir' )
                
                obj.userSavePath = fullfile(val);
            else
                
                warning('Invalid path specified. MDRT_USER_OUTPUT_PATH not set');
                
                % Invalid path specified. Check if existing value is good
                % and retain or clear
                if exist(obj.userSavePath, 'dir')
                    % there is a valid path in the object. Do nothing?
                    
                else
                    % Bad path passed and invalid directory in object.
                    % Clearing object 
                    warning('MDRTConfig.userSavePath set to empty string');
                    obj.userSavePath = '';
                end
                
            end
            
            obj.updateConfigurationFromProperties;
            
        end
        
        
        function set.userWorkingPath(obj,val)
            % Only set if it is a valid path.
            if exist( fullfile(val), 'dir' )
                
                obj.userWorkingPath = fullfile(val);

            else
                
                warning('Invalid path specified. MDRT_WORKING_PATH not set');
                
                % Invalid path specified. Check if existing value is good
                % and retain or clear
                if exist(obj.userWorkingPath, 'dir')
                    % there is a valid path in the object. Do nothing?
                    
                else
                    % Bad path passed and invalid directory in object.
                    % Clearing object 
                    warning('MDRTConfig.userWorkingPath set to empty string');
                    obj.userWorkingPath = '';
                end
                
            end
            
            obj.updateConfigurationFromProperties;
            
        end
        
        
        function set.importDataPath(obj,val)
            % Only set if it is a valid path.
            if exist( fullfile(val), 'dir' )
                
                obj.importDataPath = fullfile(val);

            else
                
                warning('Invalid path specified. MDRT_IMPORT_DATA_PATH not set');
                
                % Invalid path specified. Check if existing value is good
                % and retain or clear
                if exist(obj.importDataPath, 'dir')
                    % there is a valid path in the object. Do nothing?
                    
                else
                    % Bad path passed and invalid directory in object.
                    % Clearing object 
                    warning('MDRTConfig.importDataPath set to empty string');
                    obj.importDataPath = '';
                end
                
            end
            
            obj.updateConfigurationFromProperties;
            
        end
        
    %% Get Methods
    %  --------------------------------------------------------------------    
        

        
        
    %% Get Methods for Dependent Properties
        function workingDataPath = get.workingDataPath(this)
            
            root = this.userWorkingPath;
            
            if exist( fullfile(root, 'data'), 'dir' )
                workingDataPath = fullfile(root, 'data');
            else
                % No data folder - set output to empty variable
                workingDataPath = '';
            end
             
        end
        
        
        function workingDelimPath = get.workingDelimPath(this)
            
            root = this.userWorkingPath;
                        
            if exist( fullfile(root, 'delim'), 'dir' )
                workingDelimPath = fullfile(root, 'delim');
                
                
                
            else
                % No data folder - set output to empty variable
                workingDelimPath = '';
            end
             
        end
        
        
        function defaultConfigFile = get.defaultConfigFile(this)
            if ispc
                defaultConfigFile = this.winConfigFile;

            elseif ismac
                defaultConfigFile = this.macConfigFile;

            elseif isunix
                defaultConfigFile = this.macConfigFile;

            end
            
        end
        
        
        function pathToConfig = get.pathToConfig(this)
            
            if ispc
                pathToConfig = fullfile(getenv('appdata'), this.applicationName );
                
            elseif ismac
                pathToConfig = fullfile('~', [this.linuxPrefix, this.applicationName] );
                
            elseif isunix
                pathToConfig = fullfile('~', [this.linuxPrefix, this.applicationName] );

            end
            
        end
        
        
    %% Class Methods
        function this = makeWorkingDirectoryStructure(this, varargin)
            %makeWorkingDirectoryStructure creates the default directory
            %structure for processing delim files.
            %
            % With no arguments, the function defaults to the stored path
            % Pass a path (string) to a desired working directory and the
            % function will create the higherarchy and set the working path
            % envvar.
            
            if nargin == 1
                % Use the existing MDRT_WORKING_PATH
                wpath = this.userWorkingPath;
            elseif nargin == 2
                wpath = fullfile( varargin{1} );
            else
                warning('Too many arguments passed');
                % fail soft for now
                return
            end
             
            datapath  = fullfile( wpath, 'data');
            delimpath = fullfile( wpath, 'delim');
            plotspath = fullfile( wpath, 'plots');
            
            % Check for existing folders and create if necessary
            
            % Create/verify data folder
            if exist( datapath, 'dir')
                
            else
                mkdir(datapath);
            end
            
            % Create/verify delim folder
            if exist( delimpath, 'dir')
                
                % Check for sub-directories and create
                if ~exist(fullfile(delimpath, 'original'), 'dir')
                    mkdir(fullfile(delimpath, 'original'));
                end
                
                % Check for sub-directories and create
                if ~exist( fullfile(delimpath, 'ignore'), 'dir')
                    mkdir(fullfile(delimpath, 'ignore'));
                end
                
            else
                % Delim folder wasn't there - make delim folder tree
                mkdir(delimpath);
                mkdir(fullfile(delimpath, 'original'));
                mkdir(fullfile(delimpath, 'ignore'));
            end
            
            % Create plots path
            if ~isdir(plotspath)
                mkdir(plotspath);
            end
            
            
            % At this point all folders exist
            %     workingDirectory Root
            %         data
            %         delim
            %             original
            %             ignore
            %         plots
            
            % Update Object pointer to working directory root.
            this.userWorkingPath = wpath;
            
        end
        
        
        % Handles finding, reading, and creating the configuration file on
        % multiple platforms, if deployed, if not deployed.
        % -----------------------------------------------------------------
        function this = readConfigFile(this, varargin)
            %readConfigFile
            % Handles finding, reading, and creating the configuration file on
            % multiple platforms, if deployed, if not deployed.
            
            fid = this.getMDRTConfigFile;

            % Read all lines, ignoring comments
            % -------------------------------------------------------------
            Q = textscan(fid, '%s', 'Delimiter', '\n');

            fclose(fid);
            
            

            % Reshape data so it's a columnar cell array
            % -------------------------------------------------------------
            this.fileContents = Q{1};
            
            % Build configuration structure with empty fields
            % -------------------------------------------------------------
            for i = 1:numel(this.validConfigKeyNames)


                                      
                this.configuration.(this.validConfigKeyNames{i}) = struct;

                this.configuration.(this.validConfigKeyNames{i}).index = [];
                this.configuration.(this.validConfigKeyNames{i}).key = '';
                this.configuration.(this.validConfigKeyNames{i}).value = '';

            end

            % Read each line and parse it out
            % -------------------------------------------------------------
            for i = 1:numel(this.fileContents)

                % Exclude all comments
                if ~strcmp(regexp(this.fileContents{i},'\W', 'match'), this.commentSymbol)

                    stuffInQuotes = regexp(this.fileContents{i}, '(?<=")[^"]+(?=")', 'match');

                    keyName = regexp( this.fileContents{i}, '\w+(?==)', 'match');

                    this.setParameterFromFileContents(keyName{1}, stuffInQuotes, i);


                end
            end
            

        
        end
        
        
        % Helpers for data file parsing
        % -----------------------------------------------------------------
        function setParameterFromFileContents( this, name, value, index )
            %setParameterFromFileContents 
            % takes a name string, value string, index integer and the
            % configuration structure. Updates theconfiguration
            % structure property if a valid match is found.
            %
            % Structure fields are dynamically assigned
            
            
            % Un-cell the variable
            % -----------------------------------------------------------------
            while iscell( name )
                name = name{1};
            end
            
            

            [isValid, keyNameStr] = this.isValidParameter(name);

            if isValid

                % Right now, these are all paths... in the future, maybe other
                % settings will be included. This will have to be moved into each
                % case statement

                newValue = this.cleanPath( value );

                this.configuration.(keyNameStr).index  = index;
                this.configuration.(keyNameStr).key    = keyNameStr;
                this.configuration.(keyNameStr).value  = newValue;
                
                
                this.(keyNameStr) = newValue;

            end
            
        end

        
        function pathStr = cleanPath( this, pathStr )
        %cleanPath ( pathStr )
        %
        % Returns a path to an existant directory.
        % Malformed or nonexistant directories return an empty string


            if ~isempty( pathStr )

                % Un-cell the variable
                % -----------------------------------------------------------------
                while iscell( pathStr )
                    pathStr = pathStr{1};
                end

                if ~exist(pathStr, 'dir')
                    % Path contained an ivalid, non-existant directory
                    % return an empty string as a fail state
                    pathStr = '';
                    return
                else
                    % The directory exists - use the passed string
                end


            else
                % Gave us an empty string, return an empty string as a fail state
                pathStr = '';
                return
            end
        end


        function [isValid, fixedKeyName] = isValidParameter(this, keyName )
            %isValidParameter checks the passed keyNameStr against the
            %object's list of valid key names. Returns a true/false and a
            %correctly capitalized version. This allows the configuration
            %file to be case insensitive.

            
            isValid = false;
            fixedKeyName = '';

            bMatchIndex = cellfun(@(x)( ~isempty(x) ), regexpi(keyName, this.validConfigKeyNames) );
            
            if any(bMatchIndex, 1)
                matchIndex = find(bMatchIndex, 1, 'first');
                fixedKeyName = this.validConfigKeyNames{matchIndex};
                if ~ isempty(fixedKeyName)
                    isValid = true;
                end
            end

        end
        
        
        % Update the configuration property prior to writing to disk
        function updateConfigurationFromProperties( self )
            %updateConfigurationFromProperties
            %
            % Updates the configuration structure from the object
            % properties. Call before writing to disk.
            
           validKeys = self.validConfigKeyNames;
           
           for i = 1:numel(validKeys)
               
              self.configuration.(validKeys{i}).value = self.(validKeys{i});
                
           end
            
            
        end
        
        
        function updatePropertiesFromConfiguration( self )
            %updatePropertiesFromConfiguration
            %
            % Updates the opbject properties from the configuration
            % structure.
            %
            % Called after reading in a config file and populating the
            % configuration structure with good key/value/index pairs
            
            validKeys = self.validConfigKeyNames;
           
           for i = 1:numel(validKeys)
               
              self.(validKeys{i}) = self.configuration.(validKeys{i}).value;
                
           end
            
        end
        
        
        % Class methods for writing configuration to disk
        % -----------------------------------------------------------------
        function writeConfigurationToDisk( self )
            
            
            % Check for folder existance and make if required
            if ~exist(self.pathToConfig, 'dir')
                % TODO: Should this be converted to a try/catch?

                [status, message, id] = mkdir(self.pathToConfig);

                if ~status
                   % mkdir failed - maybe a premissions issue? 
                    warndlg(message);

                    warning('MDRT configuration directory not found. Unable to create directory:');
                    warning( self.pathToConfig );

                end

            end
            
            % Update fileContents from configuration structure
            keyNames = self.validConfigKeyNames;
            nextFileLine = size(self.fileContents, 1) + 1;
            
            for i = 1:numel(keyNames)
                
                if isempty(self.configuration.(keyNames{i}).index)
                    % no index means no match - possibly from modified
                    % config file or new feature rollout
                    
                    self.configuration.(keyNames{i}).index = nextFileLine;
                    nextFileLine = nextFileLine + 1;
                    
                else
                    
                    value = self.configuration.(keyNames{i}).value;
                    
                end
                
                index = self.configuration.(keyNames{i}).index;
                self.fileContents{index} = [keyNames{i}, '=', '"', value, '"'];

            end
            
            
            % Open a new filestream to write
            fid = fopen( fullfile( self.pathToConfig, self.configFileName), 'w' );
            
            fprintf(fid, '%s\n', self.fileContents{:} );
            
            fclose(fid);
            
        end
        
    end
    
    
    %% Static functions
    % ---------------------------------------------------------------------
    methods (Static)
        
        % Must call this function to instantiate the object
        function inst = getInstance()
            % Instantiates an MDRTConfig instance or returns a handle to the existing object. 
            % MDRTConfig.getInstance is used to get a handle to the 
            % configuration object's singleton instance. To be used in 
            % place of the traditional constructor. 
            persistent singletonObj
            if isempty(singletonObj) || ~isvalid(singletonObj)
                singletonObj = MDRTConfig();
                inst = singletonObj;
            else
                inst = singletonObj;
            end
        end
        
    end
        
    
    
    methods (Access = private, Hidden = true)
        
              
        function fid = getMDRTConfigFile(self)
            %getMDRTConfigFile
            %
            % finds the configuration file in a platform independent manner, creates a
            % default if it's missing. Opens the file and returns the fid.
            %
            

            %% Set initial values to be determined by Environment Check.

            pathToConfig = '';
            defaultConfigFile = '';

            %% Environment Check

            if ispc
                pathToConfig = fullfile(getenv('appdata'), self.applicationName );
                defaultConfigFile = self.winConfigFile;

            elseif ismac
                pathToConfig = fullfile('~', [self.linuxPrefix, self.applicationName] );
                defaultConfigFile = self.macConfigFile;

            elseif isunix
                pathToConfig = fullfile('~', [self.linuxPrefix, self.applicationName] );
                defaultConfigFile = self.macConfigFile;

            end


            %% Check for folder existance and make if required

            if ~exist(pathToConfig, 'dir')
                % TODO: Should this be converted to a try/catch?

                [status, message, ~] = mkdir(pathToConfig);

                if ~status
                   % mkdir failed - maybe a premissions issue? 
                    warndlg(message);

                    warning('MDRT configuration directory not found. Unable to create directory:');
                    warning( pathToConfig );

                end

            end

            %% Check for configuration File existance and copy a blank if required.

            if ~exist( fullfile(pathToConfig, self.configFileName), 'file')
                % TODO: Should this be converted to a try/catch?

                [status, message, ~] = copyfile( fullfile( self.prototypeConfigFilePath, defaultConfigFile), ...
                                                 fullfile( pathToConfig, self.configFileName ) );

                if ~status
                    % Copy failed!
                    warndlg(message);

                    warning('MDRT could not write configuration file to the following directory:');
                    warning( pathToConfig );
                end

            end

            %% Open the config file and assign a file ID handle
            
            fid = fopen( fullfile( pathToConfig, self.configFileName) );

        end
    
    end
 
        
        
end
    
    