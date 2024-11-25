t = readtable('/Users/nick/data/plecu-3/ambient_data.xlsx', FileType = "spreadsheet", TextType="char");
weather = rmmissing(t(:,[13,14,15]));
dest = uigetdir();

%% Make Temperature FD
fd = newFD;
ts = timeseries(str2double(weather.Temp_F_), ...
                datenum(weather.Timestamp), ...
                "Name", "Ambient Dry Bulb");

fd.ts = ts;
fd.FullString = "Ambient Dry Bulb";
fd.System = "AMB";
fd.ID = "TEMP";
fd.ts.DataInfo.Units = "°F";

save(fullfile(dest, horzcat(makeFileNameForFD(fd), '.mat')), 'fd', '-mat');


%% Make Dewpoint FD
fd = newFD;
ts = timeseries(str2double(weather.DewPoint_F_), ...
                datenum(weather.Timestamp), ...
                "Name", "Ambient Dew Point");

fd.ts = ts;
fd.FullString = "Ambient Dew Point";
fd.System = "AMB";
fd.ID = "DP";
fd.ts.DataInfo.Units = "°F";

save(fullfile(dest, horzcat(makeFileNameForFD(fd), '.mat')), 'fd', '-mat');

