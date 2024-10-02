
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

delimFolderPath = uigetdir(fullfile('~', 'data'));

% Make sure the user selected something!
if delimFolderPath ~= 0
    % We got a path selection. Now append the trailing / for linux
    % Note, we are not implementing OS checking at this time (isunix, ispc)
    delimFolderPath = [delimFolderPath '/'];
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
chan_names = plecuexport(ch_name_row,data_start_col:end);
mask = ~ cellfun(@all, cellfun(@ismissing,chan_names, 'UniformOutput',false));
chan_names = chan_names(mask);

% Extract Channel Tags
chan_tags = plecuexport(ch_tag_row, data_start_col:end);
mask = ~ cellfun(@all, cellfun(@ismissing,chan_tags, 'UniformOutput',false));
chan_tags = chan_tags(mask);

% Extract Channel Units
chan_units = plecuexport(ch_unit_row, data_start_col:end);
mask = ~ cellfun(@all, cellfun(@ismissing, chan_units, 'UniformOutput',false));
chan_units = chan_units(mask);

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

for ind = 1:numel(chan_tags)
    data_col_min = data_start_col + ind;
    data_col_max = data_start_col + ind + 1;

    this_data = plecuexport(data_start_row:end,data_col_min);
    invalid_mask = cellfun(@all,cellfun(@ismissing, this_data, 'UniformOutput',false));
    offscale_mask = cellfun(@all,cellfun(@ischar, this_data, 'UniformOutput',false));
    this_data( invalid_mask | offscale_mask) = {0};

    
    ts = timeseries( ...
        cell2mat(this_data), ...
        time_vector,...
        "Name", chan_names{ind}  );

    thisFd = newFD;
    thisFd.System = "PLECU";
    thisFd.ID = chan_names{ind};
    thisFd.Type = 'Yoko';
    thisFd.FullString = ['PLECU Yoko-' chan_names{ind} ' ' chan_tags{ind}];
    thisFd.ts = ts;
    thisFileName = makeFileNameForFD(thisFd);

    fd = thisFd;

    save(fullfile(delimFolderPath, thisFileName), 'fd')
    progressbar(ind/numel(chan_tags))

end


