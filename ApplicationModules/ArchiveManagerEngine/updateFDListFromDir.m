config = MDRTConfig.getInstance

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
load(fullfile(config.workingDataPath, 'AvailableFDs.mat'))


% Step through each file that has changed
for i = 1:numel(fileNames)
    
    thisFileIndex = ismember(FDList(:,2), fileNames{i});
    



end

% TODO: Step through FDList and delete entries without corresponding files

% Return FDList array