function FDList = updateFDListFromDir( varargin )
% updateFDListFromDir( [path], 'name', 'value')
%
% Checks the data index file in a directory and updates if any files are
% new, missing, or updated. Reduces time user spends waiting when switching
% data sets.
%
% [path] is an optional argument. If nothing is specified, the function
% will use the MDRTConfig working data path as the target directory
%
% Name/Value Pairs:
%
%   'save'      - write to default is 'yes'
%   'filename'  - user may specify data index filename
%   'prompt'    - prompt user before overwriting an existing index file
%
% Valid 'Yes' Values:
%   {'yes','true',  'on'}
%
% Valid 'No' Values:
%   {'no', 'false', 'off'}
%

config = MDRTConfig.getInstance;



%% Set up function options/arguments/parameters

YES = {'yes','true', 'on'};
NO = {'no', 'false','off'};

% Parameter for index file name
    defaultIndexFileName = 'AvailableFDs.mat';

% Parameter to write index file to disk
    defaultSave = 'no';
    isValidSaveValue = @(x) any(ismember([YES NO],x));
   
% Parameter to prompt when overwriting an existing index file
    defaultPrompt = 'no';
    isVaidPromptValue = @(x) any(ismember([YES NO],x));
% Optional argument to override path    
defaultDataPath = config.workingDataPath;

p = inputParser;
    p.addOptional('path',       defaultDataPath,        @isdir);
    p.addParameter('save',      defaultSave,            isValidSaveValue);
    p.addParameter('filename',  defaultIndexFileName);
    p.addParameter('prompt',    defaultPrompt,          isVaidPromptValue);



%% Parse function options

parse(p,varargin{:});
debugout(p.Results);

dataSetPath = p.Results.path;
dataSetIndexFileName = p.Results.filename;
                                           
shouldSaveIndex = false;
switch p.Results.save
    case YES
        shouldSaveIndex = true;
    case NO
        shouldSaveIndex = false;
    otherwise
        shouldSaveIndex = false;
end

shouldPromptOverwrite = false;
switch p.Results.prompt
    case YES
        shouldPromptOverwrite = true;
    case NO
        shouldPromptOverwrite = false;
    otherwise
        shouldPromptOverwrite = false;
end

%% Get directory and index info

% Get directory listing and discard obvious junk
    files = dir(dataSetPath);
    files(ismember({files.name}, {'.', '..', 'metadata.mat'} )) = [];

% Make matrix of dates and array of filenames
    fileDates = [files.datenum]';
    fileNames = {files.name}';

% Find index of AvailableFDs.mat and last modified time
    AFDIDX = find(strcmp([fileNames], dataSetIndexFileName));
    timeHack = fileDates(AFDIDX);
    
    debugout(sprintf('Found %s : updated at %s', ...
                        dataSetIndexFileName, ...
                        datestr(timeHack) ))

% Remove AvailableFDs from file list
    files(AFDIDX)=[];
    fileDates(AFDIDX)=[];
    fileNames(AFDIDX)=[];
    debugout(sprintf('%d files in %s', length(files), dataSetPath))
    
% Load existing FD List
    load(fullfile(dataSetPath, dataSetIndexFileName))
    debugout(sprintf('%d rows in FDList()', size(FDList, 1)))

% Index initialization
    iFilesToAdd=false(numel(fileNames), 1);
    iRowsToRemove=true(length(FDList), 1);
    newFDListEntries={};
    workingFDList=FDList;
    numEntriesUpdated = 0;
    
% Step through each file that has changed

progressbar( sprintf('Processing %s', dataSetPath) );

for i = 1:numel(fileNames)
    
    iThisFileInDir = ismember(FDList(:,2), fileNames{i});
    
        
    if ~any(iThisFileInDir) % ---------------- Filename not found in FDList
        
        % % mf = matfile(fullfile(dataSetPath, fileNames{i} ));
        c  = who( '-file', fullfile(dataSetPath, fileNames{i} ) ); % Do this in the conditional to avoid unnecessary loading

        % Add info to "newFDListEntries" for merging later
        % % if isprop(mf, 'fd')
        if ismember(c, 'fd')
            % % fd = mf.fd; % Actually loads file
            s = load( fullfile(dataSetPath, fileNames{i}), '-mat' );
            newFDListEntries = vertcat(newFDListEntries, { s.fd.FullString, fileNames{i} });
        end

    else % --------------------------------------- Filename found in FDList
    
        iRowsToRemove(i) = false; % In FDList and Dir. 
        
        if fileDates(i) > timeHack % ------------------------ File is newer
            
            % % mf = matfile(fullfile(dataSetPath, fileNames{i} ));
            c  = who( '-file', fullfile(dataSetPath, fileNames{i} ) ); % Do this in the conditional to avoid unnecessary loading
        
            % % if isprop(mf, 'fd') % update the appropriate row
            if ismember(c, 'fd')
                % % fd = mf.fd; % Actually loads file
                s = load( fullfile(dataSetPath, fileNames{i}), '-mat' );
                % % workingFDList(iThisFileInDir,:) = { fd.FullString, fileNames{i} };
                workingFDList(iThisFileInDir,:) = { s.fd.FullString, fileNames{i} };
                numEntriesUpdated = numEntriesUpdated + 1;
            end
            
        else % ---------------------------------------------- File is older
           
            % Nothing to do - let it go!
            
        end

        % File in FDList but not in directory?
            % Nothing to do here. After loop, clean
    
    end
    
    progressbar( i/numel(fileNames) )
    
end

progressbar(1)

% Report on updated entries
    if numEntriesUpdated
        debugout( sprintf('Updated %d rows ', numEntriesUpdated ));
    else
        debugout( 'Nothing to update')
    end


% Remove invalid FDList Entries
    if any(iRowsToRemove)
        debugout( sprintf('Found %d rows to remove', sum(iRowsToRemove) ));
        debugout( workingFDList(iRowsToRemove, :) );
        debugout( length(workingFDList) )
        workingFDList(iRowsToRemove, :) = [];
        debugout( length(workingFDList) )
    else
        debugout( 'Nothing to remove')
    end
    
    
% Append new FDList Entries
    if numel(newFDListEntries)
        debugout( sprintf('Found %d rows to add', size(newFDListEntries,1) ));
        debugout( newFDListEntries );
    else
        debugout( 'Nothing to add')
    end
    
    debugout( length(workingFDList) )
    workingFDList = vertcat(workingFDList, newFDListEntries);
    debugout( length(workingFDList) )
    
FDList = workingFDList;

%% Save index to file


if shouldSaveIndex
    debugout( sprintf('Saving index to %s', dataSetIndexFileName) );
    
    if exist( fullfile(dataSetPath, dataSetIndexFileName) , 'file' )
        debugout('Prompting user to overwrite existing file' );
        
        if shouldPromptOverwrite
            question = sprintf('Do you want to overwrite the existing %s', ...
                                    dataSetIndexFileName );
            dlgtitle = 'Overwrite file?';
            
            result = questdlg(question, dlgtitle);
            
            switch lower(result)
                case YES
                    % proceed
                    debugout('User selected YES - overwriting')
                otherwise
                    debugout('User selected NO - returning without writing')
                    % Skip writing file
                    return
            end 
        end
    end
    
    save(fullfile(dataSetPath, dataSetIndexFileName), 'FDList')
    
end
