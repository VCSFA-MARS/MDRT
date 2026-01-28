
% filename = '/Users/nick/Downloads/unfiled/plecu_export.CDS.txt';

[target_file processPath] = uigetfile( {...
                            '*.xlsx', 'Excel Export'; ...
                            '*.*',     'All Files (*.*)'}, ...
                            'Pick a file', '*.xlsx');

if target_file == 0
    return
end

filename = fullfile(processPath, target_file)

if ~ exist(filename, 'file')
    fprintf("File not found: %s", filename)
    return
end

dataFolderPath = uigetdir(fullfile('~', 'data'));

% Make sure the user selected something!
if dataFolderPath ~= 0
    % We got a path selection. Now append the trailing / for linux
    % Note, we are not implementing OS checking at this time (isunix, ispc)
    dataFolderPath = [dataFolderPath '/'];
else
    return
end





%% Data Location Variables

ch_name_row = 23 + 3;
ch_tag_row = 24 + 3;
ch_unit_row = 25 + 3;
ch_max_min_row = 26 + 3;

data_start_row = 27 + 3;
data_start_col = 4;

%% Read in file

plecuexport = readcell(filename);


%% Create Metadata Vectors for FD creation

% Extract channel names
chan_name_row = plecuexport(ch_name_row,data_start_col:end);
mask = ~ cellfun(@all, cellfun(@ismissing,chan_name_row, 'UniformOutput',false));
chan_names = chan_name_row(mask);
chan_name_row = plecuexport(ch_name_row,:);

% Extract Channel Tags
chan_tag_row = plecuexport(ch_tag_row, data_start_col:end);
mask = ~ cellfun(@all, cellfun(@ismissing,chan_tag_row, 'UniformOutput',false));
chan_tags = chan_tag_row(mask);
chan_tag_row = plecuexport(ch_tag_row, :);

% Extract Channel Units
chan_unit_row = plecuexport(ch_unit_row, data_start_col:end);
mask = ~ cellfun(@all, cellfun(@ismissing, chan_unit_row, 'UniformOutput',false));
chan_units = chan_unit_row(mask);
chan_unit_row = plecuexport(ch_unit_row, :);

%% Generate Time Vector from Strings

date_strs = plecuexport(data_start_row:end, 1);
time_strs = plecuexport(data_start_row:end, 2);

timestamps = cell(length(date_strs),1);
for r = 1:length(date_strs)
    this_row = {date_strs{r}, time_strs{r}};
    this_joined = strjoin(this_row, {' '});
    timestamps{r,1} = this_joined ;
end

time_vector = datenum(timestamps);


%% Loop through data columns

tot_cols = size(plecuexport,2)

invalids = {'NA' '' -99 NaN Inf missing() '-OVER', 'OVER'};
progressbar('Saving PLECU Channels')
last_chan_col = find(strcmp(chan_name_row, chan_names{end}));

for col = data_start_col:2:last_chan_col
    data_col_min = col;
    data_col_max = col + 1;
    
    this_chan_name = chan_name_row{col};
    this_chan_tag = chan_tag_row{col};
    this_chan_unit = chan_unit_row{col};

    this_data = plecuexport(data_start_row:end,data_col_min);
    invalid_mask = cellfun(@all,cellfun(@ismissing, this_data, 'UniformOutput',false));
    offscale_mask = cellfun(@all,cellfun(@ischar, this_data, 'UniformOutput',false));
    this_data( invalid_mask | offscale_mask) = {0};

    
    ts = timeseries( ...
        cell2mat(this_data), ...
        time_vector,...
        "Name", this_chan_name );

    if ~ isempty(this_chan_unit)
        ts.DataInfo.Units = this_chan_unit;
    end

    thisFd = newFD;
    thisFd.System = "PLECU";
    thisFd.ID = this_chan_tag;
    thisFd.Type = 'Yoko';
    thisFd.FullString = ['PLECU Yoko-' this_chan_name ' ' this_chan_tag];
    thisFd.ts = ts;
    thisFileName = makeFileNameForFD(thisFd);

    fd = thisFd;

    save(fullfile(dataFolderPath, thisFileName), 'fd')

    progressbar((col - data_start_col)/( last_chan_col - data_start_col ))

end


