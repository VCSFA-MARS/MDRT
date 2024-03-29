function [ output_args ] = processDelimFiles( config, varargin )
%% processDelimFiles - 
%
%   processDelimFiles parses .delim files containing a single FD (for
%   valves, all associated FDs can be included in one FD. e.g. Cmd, State,
%   Closed, Open, Position, etc.).
%
%   processDelimFiles sequentially parses each .delim file in the path
%   passed in the config argument as described below. Debugging status
%   reports are printed to the Matlab command window during execution to
%   help the user find problem spots in data files.
%
%   Arguments:
%
%       processDelimFiles( config )
%       processDelimFiles( config, 'autoskip' )
%
%   'autoskip' as a string, or as a true/false value toggles the "automatic
%   skipping" of malformed delim files. A report will be displated on
%   console indicating which files were skipped.
%  
%   config is a structure variable passed to the function that specifies
%   the location of the .delim files to be processed and the desired
%   storage location for processed .mat files.
%
%   Variable    : config
%   Type        : Struct
%
%   Fields:
%
%           delimFolderPath: string (absolute path with trailing /)
%            dataFolderPath: string (absolute path with trailing /)
%            plotFolderPath: string (absolute path with trailing /)
%
%   NOTE: This has been extended to work on non-*nix operating systems.
%
% N. Counts - Spaceport Support Services. 2013
%

% path = '/Users/nick/Documents/MATLAB/Data Review/12-11-13/delim/';
% savePath = '/Users/nick/Documents/MATLAB/Data Review/12-11-13/data/';

% TODO: Fix this ugly parameter passing!!! GROSS


% script constants:
% ------------------------------------------------------------------------
    USE_FD_NAME_OVERRIDE = false;




if isa(config, 'MDRTConfig')
    
    path = config.workingDelimPath;
    savePath = config.workingDataPath;
else
    path = config.delimFolderPath;
    savePath = config.dataFolderPath;
end

delimFiles = dir(fullfile(path, '*.delim'));
filenameCellList = {delimFiles.name};

    % Process in alphabetical lexographical order, ignoring case.
    [sorted, ~] = sort(lower(filenameCellList));
    filenameCellList = sorted;

skippedFilesList = {};
skipAllErrors = false;

% Handle automated parsing options:
switch nargin
    case 0
    case 1
    case 2
        if varargin{1} || strcmpi('autoskip', varargin{1})
            skipAllErrors = true;
        end
        
    otherwise
        end

        
% Instantiate a progress bar!
progressbar('Processing .delim Files','Parsing File')

% ----------------------------------------------------
% Calculate bytes to process
% ----------------------------------------------------
totalBytes = 0;
bytesProcessed = 0;
for i = 1:length(delimFiles)
    totalBytes = totalBytes + delimFiles(i).bytes;
end

%% iterate through delim files
for i = 1:length(filenameCellList)
    
    skipThisFile = false;
    
    % UI Progress Update
    % ------------------
    frac = 0/5;
    progressbar( (bytesProcessed + delimFiles(i).bytes * frac) / totalBytes, frac);
    
    
    % Process first file on the list!
    filenameCellList(i)
    
    % Check that file is NOT EMPTY
    if delimFiles(i).bytes ~= 0
        
        % Confirmed that file is not literally empty
        % No checking of contents or form. Errors in file may still crash
        % this routine
        
        % TODO: Add additional error catching for textscan
    
    
        % Check data type
        % Valve (different from sensors)

        % PT - TC - FM - LS
        % For all analog measurement types (I think) we dump into a 
        % timeseries
        
        % Name the time series, add time as UTC ?
        
        %% ----------------------------------------------------------------
        % Open ith File for Parsing
        % -----------------------------------------------------------------
        
        tic;
%         fid = fopen([path filenameCellList{i}]); % ### Commented for
%         cross platform compatability
        
        fid = fopen( fullfile(path, filenameCellList{i}) );
        disp(sprintf('Opening file %s took: %f seconds',filenameCellList{i},toc));
        
        % UI Progress Update
        % ------------------
        frac = 1/5;
        progressbar( (bytesProcessed + delimFiles(i).bytes * frac) / totalBytes, frac);

        % Read data in one pass... Do i want to check it first?
        tstart = tic;

            % TODO: Assign columns directly to individual varaibles
           
            % -----------------------------------------------------
            % Commented out original textscan that read the entire 
            % structure. Hopefully we save time!            
            % -----------------------------------------------------
            % Q = textscan(fid, '%s %s %s %s %s %s %s %s %s', 'Delimiter', ',');
            %                     1  2  3  4  5  6  7  8  9

            Q = textscan(fid, '%s %*s %*s %s %s %s %*s %s %s', 'Delimiter', ',');
            
        
        
        % UI Progress Update
        % ------------------
        frac = 2/5;
        progressbar( (bytesProcessed + delimFiles(i).bytes * frac) / totalBytes, frac);
        disp(sprintf('Reading file with textscan took: %f seconds',toc(tstart)));
        
        % Close file after I do my stuff!
        fclose(fid);


        % -----------------------------------------------------------------
        %   Assign important data to their own cell arrays for parsing
        % -----------------------------------------------------------------
        
        tic
        
            % timeCell        = Q{1};
            % shortNameCell   = Q{4};
            % valueTypeCell   = Q{5};
            % longNameCell    = Q{6};
            % valueCell       = Q{8};
            % unitCell        = Q(9);
            
            % We do not use 2 3 7

            timeCell        = Q{1};
            shortNameCell   = Q{2};
            valueTypeCell   = Q{3};
            longNameCell    = Q{4};
            valueCell       = Q{5};
            unitCell        = Q{6};

        
        % UI Progress Update
        % ------------------
        frac = 3/5;
        progressbar( (bytesProcessed + delimFiles(i).bytes * frac) / totalBytes, frac); 
        disp(sprintf('Assigning cell arrays took: %f seconds',toc));
        
        % Optional Cleanup
        tic;
            clear Q;
        disp(sprintf('Clearing textscan result took: %f seconds',toc));




        % Process time values
        tic
        try
            timeVect = makeMatlabTimeVector(timeCell, false, false);
        catch ME
            warning (['unable to generate time vector from file' filenameCellList{i}]);
            printSkipFileInfo;
            skippedFilesList = vertcat(skippedFilesList, filenameCellList(i));
            % UI Progress Update
            % ------------------
                frac = 5/5;
                progressbar( (bytesProcessed + delimFiles(i).bytes * frac) / totalBytes, frac);
                %update bytesProcessed for next file progress bar
                bytesProcessed = bytesProcessed + delimFiles(i).bytes;
            continue
        end
        
        disp(sprintf('Calling makeMatlabTimeVector took: %f seconds',toc));
        
        % UI Progress Update
        % ------------------
        frac = 4/5;
        progressbar( (bytesProcessed + delimFiles(i).bytes * frac) / totalBytes, frac);

        tic
            clear timeCell
        disp(sprintf('Clearing timeCell result took: %f seconds',toc));

        %   ---------------------------------------------------------------
        %   Grab Important Info About this Data Stream:
        %   --------------------------------------------------------------- 
        %         info = 
        % 
        %                     ID: '5923'
        %                   Type: 'TC'
        %                 System: 'ECS'
        %             FullString: 'ECS TC-5923 Temp Sensor  Mon'

        tic;
            info = getDataParams(shortNameCell{1});
        disp(sprintf('Calling getDataParams took: %f seconds',toc));


        % Different handlings for different retrieval types
        switch upper(info.Type)


            case {'RANGE','SETPOINT','SET POINT','BOUND','BOUNDS','BOUNDARY','LIMIT','HTR'}
                %% --------------------------------------------------------
                % Process Flow Control Data
                % ---------------------------------------------------------
                
                % Process data boundary sets
                
                try

                    disp('Processing flow control set-points');


                    % Generate normal time series        
                    tic;
                        % ts = timeseries( sscanf(sprintf('%s', valueCell{:,1}),'%f'), timeVect, 'Name', info.FullString);
                        ts = timeseries( str2double(valueCell), timeVect, 'Name', info.FullString);
                    disp(sprintf('Generating timeseries took: %f seconds',toc));            

                    fd = struct('ID',           info.ID,...
                                'Type',         info.Type,...
                                'System',       info.System,...
                                'FullString',   info.FullString,...
                                'ts',           ts, ...
                                'isLimit',      true);
                            
                            % TODO: Catch ctrl params and add as setpoints

                    % write timeSeries to disk as efficient 'mat' format
                    tic;
    %                     if isequal(info.Type, 'Set Point')
    %                         % Save happy file name
    %                         save([savePath info.ID '.mat'],'fd','-mat')
    %                     else
    %                         save([savePath info.System ' ' info.ID '.mat'],'fd','-mat')
    %                     end

                            saveFDtoDisk(fd)

                    disp(sprintf('Writing data to disk took: %f seconds',toc));

                    disp(sprintf('Finished file %i of %i',i,length(filenameCellList)));
  
                catch (ME)

                    handleParseFailure(ME)

                end
                
  

            otherwise
                %% --------------------------------------------------------
                % Process Standard FD Data
                % ---------------------------------------------------------
                
                %   make timeseries for this data set:
                disp('Processing Standard FD Data')
                
                
                
                tic;
%                     N = sscanf(sprintf('%s', valueCell{:,1}),'%f');

                    switch valueTypeCell{1}
                        case 'D'
                            % Process as discrete to fix integer conversion
                            % use cellfun isempty with regex to find all
                            % values that do not contain 0. These should
                            % all be true.
                            ts = timeseries( cellfun(@isempty,regexp(valueCell,'^0')), timeVect, 'Name', info.FullString);
                            
                            disp('Discrete data type detected')
                            
                        case {'CR', 'SC', 'BA'}
                            % Ignore control stuff that is non-numerical
                            % for now. System Command and Command Response
                            
                            disp('File contains data of type ''CR'' - Skipping file ')
                            skipThisFile = true;
                                                        
                        otherwise
                            % Process with optimized floating point
                            % conversion for maximum speed
                            % Remember the space after %s to prevent
                            % concatenating all values from array into one
                            % long string!!!
                            
                           
                            try
                                ts = timeseries( sscanf(sprintf('%s ', valueCell{:,1}),'%f'), timeVect, 'Name', info.FullString);
                            catch ME
                                
                                handleParseFailure(ME)
                                    
                            end
                            
                            % This is the old way and it was REALLY REALLY slow
                            % ts = timeseries( str2double(valueCell), timeVect, 'Name', info.FullString);
                    end
                    
                    
                    % Parse and assign engineering units to timeseries
                    switch unitCell{1}
                        case { 'F' 'deg F' '�F' }
                            thisUnit = '�F';
                        case { 'psi' }
                            thisUnit = 'psig';
                        case { 'gallons' }
                            thisUnit = 'gal';
                        otherwise
                                thisUnit = unitCell{1};
                    end
                    
                    ts.DataInfo.Units = thisUnit;
                    
                if skipThisFile
                    printSkipFileInfo
                    
                else

                    %   ts.Name = info.FullString;
                    disp(sprintf('Generating timeseries took: %f seconds',toc));

                    tic;
                        fd = struct('ID', info.ID,...
                                    'Type', info.Type,...
                                    'System', info.System,...
                                    'FullString', info.FullString,...
                                    'ts', ts,...
                                    'isValve', false);

                    disp(sprintf('Generating dataStream structure took: %f seconds',toc));


                    % write timeSeries to disk as efficient 'mat' format
                    tic;
                        saveFDtoDisk(fd)
                    disp(sprintf('Writing data to disk took: %f seconds',toc));



                    disp(sprintf('Finished file %i of %i',i,length(filenameCellList)));
                    disp(sprintf('Processing file took: %f seconds',toc(tstart)));
                
                end
        end

    % End of actual processing loop
    else
        % File is literally empty
        disp(sprintf('File %s is empty and will not be processed.',filenameCellList{i}));
        skippedFilesList = vertcat(skippedFilesList, filenameCellList(i));
    end

    
    % UI Progress Update
    % ------------------
    frac = 5/5;
    progressbar( (bytesProcessed + delimFiles(i).bytes * frac) / totalBytes, frac);
    %update bytesProcessed for next file progress bar
    bytesProcessed = bytesProcessed + delimFiles(i).bytes;
    
end
progressbar(1,1)

% Display all files with errors
%TODO: Make a GUI popup with a text area/listbox that has this information
    skippedFilesList

% clean up after yourself!!!
clear fid filenameCellList i longNameCell shortNameCell timeCell timeVect valueCell valueTypeCell info delimFiles



%% Helper Functions for processDelimFiles
%
%       These functions are called by the parsing routine to perform
%       common tasks

    function printSkipFileInfo
        disp('SKIPPING THIS FILE');
        disp(sprintf('Total time spent on this file was: %f seconds',toc(tstart)));
    end


    function saveFDtoDisk(fd)
        % This helper function writes the newly parsed FD to disk, after
        % first checking the structure against a list of special cases and
        % updating the FD fields and filename.
        
        
%% New code to fix overloaded FD file names

        fileName = makeFileNameForFD(info.FullString);
        
        if USE_FD_NAME_OVERRIDE
        
            % Check fullstring against override list

            % TODO: Implement error checking for custom FD list file and 
            %       handle it if this file doesn't exist.
            load('processDelimFiles.cfg','-mat');

            if ismember(fd.FullString,customFDnames(:,1))

                % If match is found, update structure
                n = find(strcmp(customFDnames(:,1),fd.FullString));

                fd.System       = customFDnames{n,2};
                fd.ID           = customFDnames{n,3};
                fd.Type         = customFDnames{n,4};
                fd.FullString   = customFDnames{n,5};

                % If match is found, update filename
                fileName = customFDnames{n,6};

            else
                % Don't update anything!
            end
            
        end
        
        save(fullfile(savePath ,[fileName '.mat']),'fd','-mat')
        
    end





    function showDataSampleWindow
        
        dbugWindow = figure('Position',[100 100 400 150], ...
                            'MenuBar',          'none', ...
                            'NumberTitle',      'off', ...
                            'Name', 'Sample Data from Failed Parse');

        % Column names and column format
        % ------------------------------------------------------------------------
        % columnname = {'Short Name', 'Long Name', 'Type','Value','TimeStamp'};
        columnname = {'Short Name', 'Long Name', 'Type','Value','Units'};

        % columnformat = {'numeric','bank','logical',{'Fixed' 'Adjustable'}};

        % Define the data
        % ------------------------------------------------------------------------
        % d = horzcat(valueTypeCell(1:20), valueCell(1:20), timeVect(1:20) );
        % d = [shortNameCell(1:20), longNameCell(1:20), valueTypeCell(1:20), valueCell(1:20), num2cell(timeVect(1:20))];
        d = [shortNameCell(1:20), longNameCell(1:20), valueTypeCell(1:20), valueCell(1:20), unitCell(1:20)];

        % Create the uitable
        % ------------------------------------------------------------------------
        t = uitable(dbugWindow, 'Data', d, ...
                    'ColumnName', columnname );

        % Set width and height
        % ------------------------------------------------------------------------
        t.Position(3) = t.Extent(3);
        t.Position(4) = t.Extent(4);    

        dbugWindow.Position(3) = t.Extent(3) + 40;
        dbugWindow.Position(4) = t.Extent(4) + 25;
        
        t.Units = 'normalized';
        t.Position = [0.1 0.1 0.8 0.8];
        
    end



    function handleParseFailure(ME)
        
        warning('There was a problem generating a timeseries from these data');
        
            skippedFilesList = vertcat(skippedFilesList, filenameCellList(i));
            
            if skipAllErrors
                return
            end
                                
            % Open a window with some of the data
            showDataSampleWindow();

            % Pause execution for now
            
            % TODO: Add Skip All Button

            skipButton      = 'Skip This File';
            skipAllButton   = 'Skip All Errors';
            haltButton      = 'Halt';

            ButtonName = questdlg('There was an error parsing this data file. How do you want to proceed?', ...
                                'MARS DRT Data Parse Error', ...
                                skipButton, skipAllButton, haltButton, haltButton);

            switch ButtonName
                case skipAllButton
                    disp('User selected SKIP ALL ERRORS');
                    skipThisFile = true;
                    skipAllErrors = true;
                    
                case skipButton
                    disp('User selected SKIP');
                    skipThisFile = true;

                case haltButton

                    disp('User selected HALT');

                    % Add the offending variables to
                    % the main workspace to allow power
                    % users to debug - only if not
                    % deployed!
                    if ~isdeployed
                        disp('Copying data to main workspace for debugging');

                        assignin('base' , 'parseValue', valueCell );
                        assignin('base' , 'parseTime',  timeVect  );
                        assignin('base' , 'parseUnits', unitCell );
                        assignin('base' , 'parseShort', shortNameCell );
                        assignin('base' , 'parseLong',  longNameCell );

                    end


                    % Rethrow the exception and exit
                    error('Parsing data file failed');
%                                         rethrow(ME)


                otherwise
                    % Assume user did something weird
                    % Rethrow the exception and exit
                    skippedFilesList
                    rethrow(ME)
            end
        

        
    end




end