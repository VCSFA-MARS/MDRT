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
%   'path'



config = MDRTConfig.getInstance;

%% Set up function options/arguments/parameters

% Parameter for index file name
defaultIndexFileName = 'AvailableFDs.mat';

% Parameter to write index file to disk
defaultSave = 'no';
    validSaveYES = {'yes','true', 'on'};
    validSaveNO  = {'no', 'false','off'};
    isValidSaveValue = @(x) any(ismember([validSaveNO validSaveYES],x));

% Optional argument to override path    
defaultDataPath = config.workingDataPath;

p = inputParser;
    p.addOptional('path',       defaultDataPath,        @isdir);
    p.addParameter('save',      defaultSave,            isValidSaveValue);
    p.addParameter('filename',  defaultIndexFileName);



%% Parse function options

parse(p,varargin{:})
p.Results.filename

dataSetPath = p.Results.path;               debugout(dataSetPath);
dataSetIndexFileName = p.Results.filename;  debugout(dataSetIndexFileName);
shouldSaveIndex = p.Results.save;           debugout(shouldSaveIndex);



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

% Load existing FD List
    load(fullfile(dataSetPath, dataSetIndexFileName))

% Index initialization
    iFilesToAdd=false(numel(fileNames), 1);
    iRowsToRemove=true(length(FDList), 1);
    newFDListEntries={};
    workingFDList=FDList;
    numEntriesUpdated = 0;
    
% Step through each file that has changed
for i = 1:numel(fileNames)
    
    iThisFileInDir = ismember(FDList(:,2), fileNames{i});
    mf = matfile(fullfile(dataSetPath, fileNames{i} ));
        
    if ~any(iThisFileInDir) % ---------------- Filename not found in FDList

        % Add info to "newFDListEntries" for merging later
        if isprop(mf, 'fd')
            fd = mf.fd; % Actually loads file
            newFDListEntries = vertcat(newFDListEntries, { fd.FullString, fileNames{i} });
        end

    else % --------------------------------------- Filename found in FDList
    
        iRowsToRemove(i) = false; % In FDList and Dir. 
        
        if fileDates(i) > timeHack % ------------------------ File is newer
        
            if isprop(mf, 'fd') % update the appropriate row
                fd = mf.fd; % Actually loads file
                workingFDList(iThisFileInDir,:) = { fd.FullString, fileNames{i} };
                numEntriesUpdated = numEntriesUpdated + 1;
            end
            
        else % ---------------------------------------------- File is older
           
            % Nothing to do - let it go!
            
        end

        % File in FDList but not in directory?
            % Nothing to do here. After loop, clean
    
    end
    
end

% Report on updated entries
    if numEntriesUpdated
        debugout( sprintf('Updated %n rows ', numEntriesUpdated ));
    else
        debugout( 'Nothing to update')
    end


% Remove invalid FDList Entries
    if any(iRowsToRemove)
        debugout( sprintf('Found %n rows to remove', sum(iRowsToRemove) ));
        debugout( workingFDList(iRowsToRemove, :) );
    else
        debugout( 'Nothing to remove')
    end
    workingFDList(iRowsToRemove, :) = [];
    
% Append new FDList Entries
    if numel(newFDListEntries)
        debugout( sprintf('Found %n rows to add', size(newFDListEntries,1) ));
        debugout( newFDListEntries );
    else
        debugout( 'Nothing to add')
    end
    workingFDList = vertcat(workingFDList, newFDListEntries);

FDList = workingFDList;

