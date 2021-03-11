function [dataIndex] = updateDataArchiveIndex(repositoryRootDirectory, autoSaveIndex, isRemoteArchive)
%% updateDataArchiveIndex( repositoryRootDirectory, autoSaveIndex, isRemoteArchive )
%
% updateDataArchiveIndex(  );
% updateDataArchiveIndex( repositoryRootDirectory );
% updateDataArchiveIndex( repositoryRootDirectory, autoSaveIndex );
%
% If no parameters are passed, the function prompts for a starting
% directory and prompts to save the resulting data archive index.
% 
%
% autoSaveIndex:
%         0 = true      - save automatically
%         1 = false     - do not save data index
%         2 = prompt    - prompt user for a filename and path
%
% Based on the function dataIndexForSearching written for VCSFA by Staten
% Longo in Aug 2016.

% autoSaveIndex:
%         0 = true      - save automatically
%         1 = false     - do not save data index
%         2 = prompt    - prompt user for a filename and path

% Purpose: Creates an index of all available data that is ready to be
% searched inside of the current data repository.

% Function input (repositoryRootDirectory) takes every value obtained by the
% dataIndexer function.

% Function output dataToSearch is a file including every metadata structure
% found within the current data repository by the dataIndexer function.
% This file is then loaded back into the current data repository folder.

% Example output:  
%                     foundDataToSearch = 
% 
%                     5x1 struct array with fields:
% 
%                         metaData
%                         pathToData
%                         fdList

% Supporting functions:
%     dataIndexer - provides input filenames and filepaths
 
% Longo 8-11-16, Virginia Commercial Space Flight Authority (VCSFA)
 

% dataIndexForSearching calls dataIndexer function with the following parameters:
% repositoryRootDirectory = path to data repository root directory
	% set this variable equal to the file path before calling the function
% searchExpression = 'metadata'


% Argument Parsing
% ------------------------------------------------------------------------

config = MDRTConfig.getInstance;
defaultDirectory = pwd;
defaultSaveOption = 2;

switch nargin
    case 0
        % Default behavior prompts for a directory
        repositoryRootDirectory = uigetdir(defaultDirectory);
        autoSaveIndex = defaultSaveOption;
        indexFilePath = repositoryRootDirectory;

    case 1
        % Assumes looking for metadata.mat and you passed a directory
        autoSaveIndex = defaultSaveOption;
        indexFilePath = repositoryRootDirectory;
    case 2
        % Passed both arguments
        indexFilePath = repositoryRootDirectory;
    case 3
        % Specified local or remote archive behavior
        if isRemoteArchive
            indexFilePath = config.pathToConfig;
        else
            indexFilePath = repositoryRootDirectory;
        end
    otherwise
        %What on earth did you do?
        warning('updateDataIndex does not support these arguments');
end

% Error checking
% ------------------------------------------------------------------------

warningMsg = '';

if ~exist(repositoryRootDirectory, 'dir')
    % Passed an invalid directory
    warningMsg('Invalid search directory specified.');
end

if ~ ismember(autoSaveIndex, [1 2 0])
    % specified an invalid autoSave mode
    warningMsg = strjoin({warningMsg, 'Invalid auto save mode specified'});
end

if ~ isempty(warningMsg)
    warning(warningMsg)
    return
end

% CONSTANT DEFINITIONS:

dataIndexFileName = 'dataIndex.mat';
dataIndexVariableName = 'dataIndex';




% obtain input for dataIndexForSearching from dataIndexer function
[~, filepaths] = findFilesInDirectory(repositoryRootDirectory, 'metadata.mat');

progressbar('Indexing Data Repository');

% index each file found by dataIndexer function
for i = 1:numel(filepaths);
    
    % load each file found by dataIndexer function
    % {i} generates contents of each cell
    variable = load(filepaths{i} );
    metaData = variable.metaData;
    
    % specify path to data folder in data repository
    pathToData = fileparts(filepaths{i} );
    
    % if checkStructureType function returns metadata
    if strcmp(checkStructureType( metaData ), 'metadata')

        % create structure array dataToSearch 
            
            % creates array structure of metaData
            dataIndex(i).metaData = metaData;

            % creates array structure of filepaths
            dataIndex(i).pathToData = pathToData;

            % creates array structure of FDLists
            dataIndex(i).FDList = metaData.fdList;

    end

    progressbar(i/numel(filepaths));
    
end % end for loop iterating over each filepath

% save dataToSearch as file and put this file in root search path
% ------------------------------------------------------------------------

dataIndexFullFile = fullfile(indexFilePath, dataIndexFileName);

switch autoSaveIndex
    case 0  % save automatically
        
        backupFileName_str = sprintf('dataIndex-%s.bak', ...
                                     datestr(now, 'mmmddyyyy-HHMMSS') );
                                 
        backupFullFile = fullfile(indexFilePath, backupFileName_str);
        
        try
            copyfile(dataIndexFullFile, backupFullFile, 'f');
        catch
            warning('Unable to backup data index file');
        end
        
        
        save(dataIndexFullFile, dataIndexVariableName, '-mat');
        
    case 1  % do not save data index
        
    case 2  % prompt user for a filename and path
        % Start saveas dialog in archive directory with correct filename
        [filename, pathname] = uiputfile(dataIndexFullFile, 'Save Archive Index as');
        if ~ filename
            % User cancelled
            return
        end

        save( fullfile(pathname, filename) , dataIndexVariableName);
end

end % end function dataIndexForSearching
