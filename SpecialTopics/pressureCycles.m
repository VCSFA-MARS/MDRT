%% Data massager for storage vessel pressure cycle analysis
% This can be stuffed into a function/gui for easier analysis in the future
% but for now it is a fairly manual process.
%
% Point the tool at an archive that contains the data file you want and
% select the data file from the GUI prompt.
%
% NOTE: if you are performing this on data that are joined from multiple
% TAM files, you should run the manually_clean_data_file script to clean
% out any data artifacts like zeros from project recycles or sensor
% calibrations, which do not represent actual pressure cycles on a storage
% vessel.


%% Load the data file and generate the time and data variables
config = MDRTConfig.getInstance();

dataPath = config.workingDataPath;

[loadFileName_str, loadFilePath] = uigetfile( {...
                '*.mat', 'MDRT Data File'; ...
                '*.*',     'All Files (*.*)'}, ...
                'Pick a file', fullfile(dataPath, '*.mat'));

input_data_file = fullfile(loadFilePath, loadFileName_str);

load(input_data_file);
t = fd.ts.Time;
p = fd.ts.Data;


%% Find the peaks and valleys for waterfall analysis
%
% Adjusting the sensor range is the shortcut for setting the "minimum
% prominence" magnitude for local peak detection/rejection.
%
% Run this section of code and observe the plot to sanity check the results

SENSOR_RANGE = 4000;
MPROM = SENSOR_RANGE * 0.05;
MSEP = 50;

lmax = islocalmax([-Inf; p; -Inf], "MinSeparation", MSEP, "MinProminence", MPROM, "FlatSelection","center");
lmin = islocalmin([ Inf; p;  Inf], "MinSeparation", MSEP, "MinProminence", MPROM, "FlatSelection","center");

lmax = lmax(2:end);
lmin = lmin(2:end);

lring = islocalmax(p, "MinSeparation", MSEP);


makeMDRTPlotFigure();
plot(t, p, 'DisplayName', 'TELHS Pressure Peak Analysis');
title(fd.FullString);
hold on;

% pr = plot(t(lring), p(lring), 'LineStyle','none', 'Marker','*','Color','magenta');
pp = plot(t(lmax), p(lmax), 'LineStyle','none', 'Marker','^','Color','r');
pq = plot(t(lmin), p(lmin), 'LineStyle','none', 'Marker','v','Color','r');

dynamicDateTicks;
plotStyle;

lall = lmax | lmin;
%% Save the data to an excel file
%
% Once the previous section completes with a satisfactory set of peaks and
% valleys, you can save the data. The following lines generate the
% spreadsheet's file name. The top line is for typical FCS pressure sensors
% and the bottom line is for typical TELHS. Uncomment the appropriate line
% and then run this section to generate the output file.

excel_file = sprintf('Pressure %s-%s.xlsx', fd.Type, fd.ID);
% excel_file = sprintf('Pressure %s.xlsx', fd.Type);

output_excel_file = fullfile(dataPath, '..', excel_file);

press_table = table(cellstr(datestr(t(lall))), ...
                    m2xdate(t(lall)), p(lall),  ...
                    'VariableNames',{'DateString', 'ExcelDateNum', 'Pressure'})

% writetable(press_table, output_excel_file, 'Sheet',1)
writetable(press_table, output_excel_file)