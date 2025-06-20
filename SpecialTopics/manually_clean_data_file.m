%% manually_clean_data_file
% This script provides assistance cleaning a artifacts from a data file
% prior to other processing.
%
% If you are performing this on data that are joined from multiple
% TAM files, you should clean out any data artifacts like zeros from 
% project recycles or sensor calibrations, which do not represent actual 
% pressure cycles on a storage vessel.


%% load the old FD from disk and plot
%
% Run this section first and use the data brushing tool to "remove brushed
% data." 

config = MDRTConfig.getInstance();

dataPath = config.workingDataPath;

[loadFileName_str, loadFilePath] = uigetfile( {...
                '*.mat', 'MDRT Data File'; ...
                '*.*',     'All Files (*.*)'}, ...
                'Pick a file', fullfile(dataPath, '*.mat'));

load(fullfile(loadFilePath, loadFileName_str));

fig = figure;
dp = plot(fd.ts);
plotStyle;
dynamicDateTicks;

%% Save the cleaned databrush to workspace as `clean`
% Run this section once the data have been cleaned up

clean = [dp.XData', dp.YData'];

%% Execute after manually cleaning the data to save to disk

fd.FullString = strcat(fd.FullString, ' - Filtered');
fd.ID = strcat(fd.ID, ' Filtered');
ts_unit = fd.ts.DataInfo.Units;

newTS = timeseries(clean(:,2), clean(:,1));
newTS.Name = fd.FullString;
newTS.DataInfo.Units = ts_unit;

fd.ts = newTS;

save_fd_to_disk(fd);