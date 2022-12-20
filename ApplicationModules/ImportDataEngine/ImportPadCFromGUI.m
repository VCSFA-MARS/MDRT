function ImportPadCFromGUI( filesIn, metaData, folderName, autoSkip )
%ImportFromGUI 
%   Automates the data importing process.
%
%   filesIn is a cell array of path/filenames that make up the raw data to
%   be imported. 
%
%   The function generates file/folder structure, names it, moves the
%   files, and starts the import process.
%
%   folderName is a string that is a complete path to the destination root
%   folder
%

COPY_FILES = false;

config = MDRTConfig.getInstance;

if ~iscell(filesIn)
    % convert single string input to a single cellstring
    filesIn = {filesIn};
end

if ~iscell(folderName)
    % convert single string input to a single cellstring
    folderName = {folderName};
end




%% Make sure to handle the file type. and EXIT if bad filetype


%% Build Folder Name String


folderName = strtrim(folderName);

% clean up unhappy reserved filename characters
        folderName = regexprep(folderName,'^[!@$^&*~?.|/[]<>\`";#()]','');
        folderName = regexprep(folderName, '[:]','-');
        debugout(sprintf('Alina-proof folder name created: %s', folderName{1}))
        
if isempty(folderName)
    % User cancelled
    return
else
    
    rootPath = fullfile(config.importDataPath, folderName);
    
    mkdir( rootPath{1} );
    
    config.userWorkingPath = rootPath{1};
    
    config.makeWorkingDirectoryStructure;
    
    config.writeConfigurationToDisk;
    
    
    
end


%% Move files to location to process

if COPY_FILES
    
    workingFiles = {};
    badCopyIndex = [];

    for i = 1:numel(filesIn)

        [a b c] = fileparts(filesIn{i});
        fileBeingCopied = [b, c];

        newFile = fullfile(config.workingDelimPath, 'original', fileBeingCopied);

        workingFiles = vertcat( workingFiles, newFile);

        copyWorked = copyfile(filesIn{i}, newFile );

        if ~copyWorked
            warningMsg = sprintf('Moving file: %s failed', filesIn{i});
            warning(warningMsg)
            badCopyIndex = vertcat(badCopyIndex, i);
    %         return
        end

    end

    % Clear entries for files that didn't copy correctly
    if length(badCopyIndex)
        workingFiles(badCopyIndex) = [];
    end

else
    workingFiles = filesIn;
end




%% Parse .csv files

processPadCcsv(workingFiles, config.workingDataPath, autoSkip);


%% Start Indexing!

% FDList = listAvailableFDs(config.workingDataPath, 'mat');

[FDList, timeSpan] = indexTimeAndFDNames(config.workingDataPath);
save(fullfile(config.workingDataPath, 'AvailableFDs.mat'), 'FDList');


metaData.fdList = FDList;
metaData.timeSpan = timeSpan;

% % save(fullfile(dataPath, 'metadata.mat'), 'metaData');
save(fullfile(config.workingDataPath, 'metadata.mat'), 'metaData');





