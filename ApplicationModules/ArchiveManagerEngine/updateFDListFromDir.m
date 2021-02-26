
% TODO: Add inputParser to handle forced re-indexing and other fun options

config = MDRTConfig.getInstance;
dataSetIndexFileName = 'AvailableFDs.mat'; % For future release when this is from a config file

% Get directory listing and discard obvious junk
    files = dir(config.workingDataPath);
    files(ismember({files.name}, {'.', '..', 'metadata.mat'} )) = [];

% Make matrix of dates and array of filenames
    fileDates = [files.datenum]';
    fileNames = {files.name}';

% Find index of AvailableFDs.mat and last modified time
    AFDIDX = find(strcmp([fileNames], 'AvailableFDs.mat'));
    timeHack = fileDates(AFDIDX);

% Remove AvailableFDs from file list
    files(AFDIDX)=[];
    fileDates(AFDIDX)=[];
    fileNames(AFDIDX)=[];

% Load existing FD List
    load(fullfile(config.workingDataPath, dataSetIndexFileName))

% Index initialization
    iFilesToAdd=false(numel(fileNames), 1);
    iRowsToRemove=true(length(FDList), 1);
    newFDListEntries={};
    workingFDList=FDList;
    
% Step through each file that has changed
for i = 1:numel(fileNames)
    
    iThisFileInDir = ismember(FDList(:,2), fileNames{i});
    mf = matfile(fullfile(config.workingDataPath, fileNames{i} ));
        
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
            end
            
        else % ---------------------------------------------- File is older
           
            % Nothing to do - let it go!
            
        end

        % File in FDList but not in directory?
            % Nothing to do here. After loop, clean
    
    end
    
end

% Rmove invalid FDList Entries
    workingFDList(iRowsToRemove, :) = [];
% Append new FDList Entries
    workingFDList = vertcat(workingFDList, newFDListEntries);

FDList = workingFDList

