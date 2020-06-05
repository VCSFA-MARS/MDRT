% config = MDRTConfig.getInstance;
config = getConfig;

% d = dir(config.workingDataPath);
% m = dir(fullfile(config.workingDataPath, 'metadata.mat'));

d = dir(config.dataFolderPath);
m = dir(fullfile(config.dataFolderPath, 'metadata.mat'));

newInd = ([d.datenum] > [m.datenum])';

