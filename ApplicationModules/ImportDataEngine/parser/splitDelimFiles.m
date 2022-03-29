function [ output_args ] = splitDelimFiles( varargin )
%splitDelimFiles reads a .delim file and splits it into discrete .delim
%files for parsing by the MARS Review Tool
%
%   splitDelimFiles( configStruct )
%   splitDelimFiles( MDRTConfig )
%
%   splitDelimFiles( filename, configStruct )
%   splitDelimFiles( filename, configStruct )
%
%   splitDelimFiles( filename, configStruct, combineDelims, importRaw )
%
%       filename        the full filename and path to a .delim file to be
%                       processed. Can be a string or a cell string.
%
%       configStruct    an MDRT Config structure, as returned by the
%                       configuration property of the MDRTConfig object
%
%       combineDelims   true/false - use when combining multiple .delim
%                       files into one data set. Useful for retrievals that 
%                       span multiple TAM files
%
%       importRaw       true/false - use to import raw values from a delim
%                       that contains RAW. default is false, and any raw
%                       data are omitted.
%
%   This tool has been updated to support Windows as well as *nix systems.
%   getFileLineCount.m and countlines.pl are required
%   
%   Counts, Spaceport Support Services. 2014

%   Updated 2018, Counts, VCSFA - Better delim naming convention, should
%   eliminate overloaded filenames. Added support for concatination of
%   .delim files during the split process.


%% Constant definitions

    % Number of lines in a file that will be parsed in one chunk:
    MAX_LINE_COUNT = 50000;
    
    DELIM_SPLIT_LINES = 2000000;
    USE_FD_NAME_OVERRIDE = false;
    
%% Default parameters

    concatinateDelimFiles = false;
    noFilenamePassed = false;
    importRaw = false;
        
    
%% Argument parsing

switch nargin
    case 1
        configVar = varargin{1};
        noFilenamePassed = true;
    case 2
        fileName = varargin{1};
        configVar = varargin{2};
    case 3
        fileName = varargin{1};
        configVar = varargin{2};
        concatinateDelimFiles = varargin{3};
        if concatinateDelimFiles
            debugout('Combining .delim files from multiple TAM files');
        end
    case 4
        fileName = varargin{1};
        configVar = varargin{2};
        concatinateDelimFiles = varargin{3};
        importRaw = varargin{4};
        if concatinateDelimFiles
            debugout('Combining .delim files from multiple TAM files');
        end
        if importRaw
            debugout('Importing RAW data from .delim files');
        end
    otherwise
        error('Invalid arguments for function splitDelimFiles');
        
end
        
% Handle configuration variable argument
if isa(configVar, 'MDRTConfig')
    delimPath = configVar.workingDelimPath;
    
elseif strcmpi( checkStructureType(configVar), 'config')
    delimPath = configVar.delimFolderPath;
    
else
    error('Unknown configuration parameter')
    
end

% Define paths from config structure
%     delimPath = '~/Documents/MATLAB/Data Review/ORB-2/delim';
%     delimPath = config.delimFolderPath;
    % processPath = fullfile(delimPath, '..'); % Not sure why I ever did this
    processPath = fullfile(delimPath);
    
    if noFilenamePassed
        
        [fileName processPath] = uigetfile( {...
                                '*.delim', 'CCT Delim File'; ...
                                '*.*',     'All Files (*.*)'}, ...
                                'Pick a file', fullfile(processPath, '*.delim'));

        if isnumeric(fileName)
            % User cancelled .delim pre-parse
            debugout('User cancelled .delim pre-parse');
            return
        end
        
        fileName = fullfile(processPath, fileName);

    else
        
        % Do error checking here for passed filename
        
        % de-cell the fileName
        while iscell(fileName)
            fileName = fileName{1};
        end
        
    end
                        
% Open the file selected above
% -------------------------------------------------------------------------
fid = fopen(fileName);
debugout(fileName);

%% Get lines in data file to chunk large files
% -------------------------------------------------------------------------
    
    numLines = getFileLineCount(fileName);
    N = 50000;
    flagReadAsChunks = false;
    
    % Instantiate allData for concatenation
    allData = cell(1);
    
    if numLines > N
        
        flagReadAsChunks = true;
        
        % Open a progress bar
        progressbar('Processing Large File');

        for i = 1:N:numLines
            
            % Read a chunk of the file data
            chunkData = textscan(fid,'%*s %*s %*s %s %*[^\n]',N,'Delimiter',',');
            
            % Keep chunkData small for concatenation
            chunkData = unique(chunkData{:});
            
            % tack the chunk of data to the end of allData
            allData = cat(1,allData, chunkData);
            progressbar(i/numLines);
        end
        
        % Clean up first entry (empty cell)
        allData(1) = [];
        
        % Close the progress bar
        progressbar(1);

    else
    
    % Read data file into 
    % -------------------------------------------------------------------------
        allData = textscan(fid,'%*s %*s %*s %s %*[^\n]','Delimiter',',');
    
    end
    
    
    % close file!!!
    fclose(fid);

    
    
    
%% Put data into an nx1 cell array of strings for parsing
% -------------------------------------------------------------------------
    
    % Handle different variable forms from chunk vs direct file parsing
    switch flagReadAsChunks
        case true
            fileData = allData;
            
            
        case false
            fileData = allData{1};
    end    

    
%     % Garbage collection
%     clear allData fid;
    
% 2014/193/13:03:30.450043, , ,__RP1 FM-1016 Input Signal Si__,BA,,----------------,, 
% 2017/314/22:43:05.692136, , ,ECS PCVNC-5256 Globe Valve  Cmd Param, A,FGSE M-P0A-GN2-PCV-5256 Process Outlet Control Valve,----------------,0.000000000000000000E+00, 





%% find all unique FD strings - store in cell array of strings
% -------------------------------------------------------------------------
    uniqueFDs = unique(fileData);
    
    debugout(uniqueFDs)

% %% Legacy code that handled valves as a combined entity
% % -----------------------------------------------------------------------
% find all FDs that are valve related - returns cell array of cells of
% strings
% -------------------------------------------------------------------------
%     valveFDs = regexp(uniqueFDs, '[DP]CVN[CO]-[0-9]{4}','match');


% % Include System ID String
%     valveFDs = regexp(uniqueFDs, '\w* [DP]CVN[CO]-[0-9]{4}','match');
%     
%     debugout('Valve FDs for combined processing:')
%     debugout(valveFDs)
% 
%     % Make FD List for grep without any valve data
%     FDlistForGrep = uniqueFDs(cellfun('isempty',valveFDs));
    
    % Patch to stop combining valve data
    FDlistForGrep = uniqueFDs;
    
    debugout(FDlistForGrep)
    
    % Wrap each unique FD String in commas to prevent accidentally
    % combining FDs that share the same ending.
    FDlistForGrep = cellfun(@(c)[',' c ','], FDlistForGrep, 'uni', false);

% % make cell array of strings containing all unique valve identifiers
% % -------------------------------------------------------------------------
%     uniqueValves = unique(cat(1,valveFDs{:}));
%     
%     debugout(uniqueValves)
    
% % % Generate cell array of cell array of strings (listing FDs for each valve)
% % % -------------------------------------------------------------------------
% %     valveFDBundle = cell(length(uniqueValves),1);
% % 
% %     for i = 1:length(uniqueValves)
% % 
% %         temp = regexp(fds, uniqueValves{i},'match');
% % 
% %         valveFDBundle{i,1} = cat(1, temp{:});
% % 
% %     end
    
    
% Combine Valve FDs with uniqueFDs for .delim grep
% -------------------------------------------------------------------------
%     % Disabling combined valve processing
%     FDlistForGrep = cat(1,FDlistForGrep, uniqueValves);
    
% Remove FDs with leading underscores
    FDlistForGrep(~cellfun('isempty',regexp(FDlistForGrep,'^_'))) = [];
    
    
% Loop through unique FDs with mask
% -------------------------------------------------------------------------

progressbar('Pre-processing .delim files');
reverseStr = '';

    %% Handle special output naming convetions
    % ---------------------------------------------------------------------
    % TODO: rename variabls with semantic names for future clarity 
    
    useCustomNames = false;
    
    if USE_FD_NAME_OVERRIDE
        if exist('processDelimFiles.cfg','file')
            load('processDelimFiles.cfg', '-mat');
            useCustomNames = true;
        end 
    end
    
%% On Mac or Linux, always split the delim file into 2,000,000 line chunks    
% -------------------------------------------------------------------------
%     
% if ispc
%     disp('MS Windows OS does not have naitive file splitting tools and large .delim files may parse very slowly.') 
% else
%     % split by lines, not by size
%     splitCommand = ['split -l ', ...
%                     num2str(DELIM_SPLIT_LINES), ' "', fileName, '" "',...
%                     fullfile(delimPath, 'dataSplit.delim'), '"'];
%                 
% 	fileToGrep = fullfile(delimPath, 'dataSplit.delim*');
%     fileName = fileToGrep;
%     
%     % Split the file no matter what!!
%     system(splitCommand);
%     
% end

    
    
%     % Build list of file chunks to parse
%         dirList = dir( fullfile(processPath, 'dataSplit.delim*') );
%         FilesToGrep = {dirList.name}'



%% GREP for each unique FD and dump to its own .delim file for parsing    
    
    for i = 1:length(FDlistForGrep)
        
%         % Find indices of cells containing FD Identifier
%         FDindexC = strfind(fileData, uniqueFDs{i});
%         FDindex  = find(not(cellfun('isempty', FDindexC)));
%         
	m = regexp(FDlistForGrep{i}, '\w*','match');

        if useCustomNames
            
            % max(max(strcmp('ECS C1ECU Fan Speed Setpoint', customFDnames)));
            isCustomRule = find(strcmp(FDlistForGrep{i}, customFDnames));
        
            if isCustomRule
                outName = strcat(customFDnames{isCustomRule, 6}, '.delim');
            else
                % Use all tokens to guarantee a unique filename
                outName = strcat(m{1:end},'.delim');
            end

        else
                        
        end
        
        % Filter out accidental RAW value retrievals
        grepFilterRAW = ' ';
        grepFileSuffix = '';
        
        if importRaw
            grepFileSuffix = '_RAW' ;
            grepFilterRAW = ' ,RAW ' ;
        else
            grepFilterRAW = '-v ,RAW ' ;
        end
        
        % Use all tokens to guarantee a unique filename
            outName = strcat(m{1:end}, grepFileSuffix, '.delim');
            
        % Handle Spaces in filenames for *nix systems
        outputFile = fullfile(delimPath, outName);
                                
        % Generate grep command to split delim into parseable files
        % time LC_ALL=C grep -F "TELHS_SYS1 PT33  Mon" ../original/TEL-mon-s.delim > test.delim
        
        % Check for faster grep binary
        if exist('/usr/local/bin/grep', 'file')
            grepExecutable = '/usr/local/bin/grep -F ';
        elseif exist('/usr/local/bin/ggrep', 'file')
            grepExecutable = '/usr/local/bin/ggrep -F ';
        else
            grepExecutable = 'grep -F ';
        end
        
        if concatinateDelimFiles
            egrepCommand = [grepExecutable , '"', FDlistForGrep{i}, '" "',fileName, '" | ' , grepExecutable , grepFilterRAW , ' >> "', outputFile , '"'];
        else
            egrepCommand = [grepExecutable , '"', FDlistForGrep{i}, '" "',fileName, '" | ' , grepExecutable , grepFilterRAW , ' > "', outputFile , '"'];
        end
        
        debugout(egrepCommand)
        
        [status,result] = system(egrepCommand);
        
        progressbar(i/length(FDlistForGrep));
        
        
        % Display the progress
        percentDone = 100 * i / length(FDlistForGrep);
        msg = sprintf('Percent done: %3.1f', percentDone); %Don't forget this semicolon
        fprintf([reverseStr, msg]);
        reverseStr = repmat(sprintf('\b'), 1, length(msg));
        
    end
    
    % Print a newline character to clean the console
    fprintf('\n');
        
    %% Cleanup any split files
    

end

