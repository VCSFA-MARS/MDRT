function processPadCcsv(fileList, destFolder, autoSkip)

HEADER_LINES = 1;
disp(fileList)

global pp;
num_files = numel(fileList);
prog_id_file = 1;
pp = ProcessProgress(sprintf('Importing %d files', num_files));
pp.new_max_for_bar(prog_id_file, num_files);
prog_id_fd = pp.add_child_bar('Saving FD Files to disk', 1);
prog_id_read = pp.add_child_bar('Pre-processing raw file',1);
pp.show_bar

% Loop through files
for f = 1:numel(fileList)
    thisFile = fileList{f};
    fid = fopen(thisFile, 'r+');
    first_line = fgetl(fid);
    
    chan_names = getChannelNames(first_line);
    byte_chans = getByteChannelInds(chan_names);

    % Set "Saving FD Files" progress max to the number of channels
    num_fds = numel(chan_names);
    pp.new_max_for_bar(prog_id_fd, num_fds)


    this_file_size = dir(fopen(fid)).bytes;
    pp.new_max_for_bar(prog_id_read, this_file_size);

    % if any(byte_chans)
        % Make a temporary file and do the hard pre-processing in place

        % start_date = get_starting_datenum_from_file(fid,HEADER_LINES,true);
        % start_date_strs = datestr(start_date + [0,1,2], 'yyyy-mm-dd');
        % start_date_strs = cellstr(start_date_strs);
        temp_fileID = fopen(tempname(), "w+");
        % Since we're going to read/write this file, we're processing 2x
        % bytes
        pp.new_max_for_bar(prog_id_read, this_file_size*2);
        % fix_csv_newline(fid, temp_fileID, start_date_strs, HEADER_LINES, prog_id_read);
        fix_csv_newline(fid, temp_fileID, {}, HEADER_LINES, prog_id_read);
        
        % Use fixed temporary file for subsequent processing
        fclose(fid);
        fid = temp_fileID;
    % end

    % all_data = getAllData(fid, chan_names, HEADER_LINES);
    all_data = read_in_chunks(fid, 20000, HEADER_LINES, chan_names, prog_id_read);
    assignin("base", "all_data", all_data);
    
    fclose(fid);
    
    timeVect = makeTimeVect(all_data(1) );
    
    makeFDsFromAllData(timeVect, all_data, chan_names, destFolder, autoSkip, prog_id_fd);
    pp.set_completed(prog_id_file, f)
end







%% Supporting Functions

function makeFDsFromAllData(timeVect, data, chans, saveTo, skipError, varargin)
    numChans = numel(chans);

    use_prog = false;
    if ~isempty(varargin)
        pp_ind = varargin{1};
        use_prog = true;
        % Since we're going to read/write this file, we're processing 2x
        % bytes
        pp.new_max_for_bar(pp_ind, numChans);
    else
        progressbar('Generating Pad-0C FD Data Files')
    end

    % Start on 2nd column (first row of non-time data)
    for c = 2:numChans
        % if any(contains(chans(c), {'Time', 'EpochTime'}, 'IgnoreCase', true))
        %     continue
        % end
        
        if isempty(data{1,c}{1})
            % Something weird resulted in an empty column
            continue
        end

        [fd, unit_str] = makeFdFromChanStr(chans{c});
        
        data_type = getChanType(chans{c});
        if strcmpi(data_type, 'TYPE_STRING')
            continue
        end

        dataVect = makeDataVect(data(c), data_type);
        
        fd.ts = timeseries(dataVect, timeVect, 'Name', fd.FullString);
        fd.ts.DataInfo.Units = unit_str;
        
        filename = fullfile(saveTo, makeFileNameForFD(fd));
        
        save(filename, 'fd');
        
        if use_prog
            pp.set_completed(pp_ind, c);
        else
            progressbar(c/numChans)
        end
        
    end


end

    function [fd, unit_str] = makeFdFromChanStr(chan_str)
    fd = newFD;
    entries = split(chan_str, ';');

    % {'"/GSE_Systems/LC2_WALLOPS/MASTER/PowerPack_HVAC_FSM_LineChill_UnderTemp_Hysteresis{__type__=""TYPE_DOUBLE""'}
    % {'complex=""lc2""'                                                                                            }
    % {'facility=""mars""'                                                                                          }
    % {'source=""valence""'                                                                                         }
    % {'timesource=""/GSE_Systems/LC2_WALLOPS/MASTER/MASTER.ChannelSet""'                                           }
    % {'units=""K""}"'                                                                                              }

    try
        unit_str = regexp(entries{6}, '(?<=")[^"]+(?=")', 'match');
        unit_str = unit_str{1};
    catch
        unit_str = '';
    end

    [~,tag_name,~] = fileparts(extractBetween(entries{1}, '/', '{'));
    while iscell(tag_name)  % unwrap cells just to be sure?
        tag_name = tag_name{1};
    end
    fd.FullString = tag_name;
    debugout(sprintf('Creating FD for: %s\n', tag_name))
end


function dataVect = makeDataVect(data_cell, data_type)

    process_str_to_enum = false;
    formatSpec = '';
    
    switch data_type
        case 'TYPE_DOUBLE'
            % -0.10545220971107483
            % +Inf
            formatSpec = '%f';
            
        case 'TYPE_BOOL'
            % formatSpec = '%u'; This is for 1/0 values, not 'true/false'
            process_str_to_enum = true;
    
        case 'TYPE_UINT'
            formatSpec = '%u';
    
        case 'TYPE_STRING'
            % directly return for now?
            dataVect = data_cell{1,1};
            return
    
        otherwise
            % This is a brutally slow method under most circumstances
            dataVect = str2double(data_cell{1,1});
    end
    
    if ~isempty(formatSpec)
        dataVect = cellfun(@(s) sscanf(s,formatSpec), data_cell{1,1});
    end
    
    if ~process_str_to_enum
        return
    end
    
    switch(lower(data_cell{1,1}{1}) )
        case { 'true' 'on' 'false' 'off' 'yes' 'no' }
            % treat as bool
            trues = {'true', 'on', 'yes'};
            falses = {'false', 'off', 'no'};
            
            false_inds = find(contains(data_cell{1,1}, falses));
            true_inds =  find(contains(data_cell{1,1}, trues));
    
    
            dataVect = false(size(data_cell{1,1}));
            dataVect(true_inds) = true;
            return
        otherwise
    
    end
    
    return
end


function timeVect = makeTimeVect(data_cell)
    % returns an nx1 column vector of datetimes
    data_cell = regexprep(data_cell{:}, '(?<=:\d{2})Z', '.000Z');
    timeVect = datenum(data_cell, 'yyyy-mm-ddTHH:MM:SS.FFF');
end



function fix_csv_newline(original_file, temp_file, start_date_strs, header_lines, varargin)
    % Reads a csv file, replaces bad newline characters and writes to a 
    % temporary file. No open/close is performed. Pass a fileID as
    % arguments.
    
    % This function assumes that the data are within a 3-day range of the
    % first timestamp in the data. If a retrieval is any longer than that,
    % then the speed optimization technique will break and unreliable
    % output will be generated.
    
    use_prog = false;
    if ~isempty(varargin)
        % pp = varargin{1};
        pp_ind = varargin{1};
        use_prog = true;
    end

    % Regular expressions for timestamp and suspect newline
    % timestamp_reg_str = '\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}[\.]?\d*Z';
    suspect_newline_str = '[\n\r]+(?!\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2})';


    % Read the original file
    frewind(original_file);
    contents = fread(original_file, '*char')';

    newline_locs = strfind(contents, newline);
    
    date_str_list = cellstr(start_date_strs)';
    
    % date_locs = [];
    % for d = 1:length(date_str_list)
    %     date_locs = horzcat(date_locs, strfind(contents, date_str_list(d)) );
    % end

    % Write header lines straight through:
    fprintf('Writing to temporary file %s\n', fopen(temp_file))
    assignin("base", "temp_file_name", fopen(temp_file));
    start_ind = 1;
    for ind = 1:header_lines
        this_line = contents(start_ind:newline_locs(ind));
        fwrite(temp_file, this_line, 'char');
        start_ind = newline_locs(ind) + 1;
    end

    % Replace suspect newlines with a space
    contents = regexprep(contents, suspect_newline_str, ' ');
    % nl_inds = regexp(contents, suspect_newline_str);
    % for ni = 2:length(nl_inds)
    %     tok = contents(nl_inds(ni)-9: nl_inds(ni)-1);
    %     if ~ strcmp(tok, 'INHIBITED')
    %         fprintf('location: %d is %s', nl_inds(ni), tok)
    %         % disp(contents(nl_inds(ni) - 10: nl_inds(ni)+10))
    %     end
    % end
    
    % Write to the temp file
    fwrite(temp_file, contents(start_ind:end), 'char');
    
    % Explicitely clean up unneeded variables
    clear contents newline_locs

    % update Progress
    if use_prog
        pp.add_to_completed(pp_ind, dir(fopen(original_file)).bytes);
    end

end



function channels = getChannelNames(headerStr)

    channels = textscan(headerStr, '%s', 'delimiter', ',');
    channels = channels{1};

end

function byte_chan_inds = getByteChannelInds(chan_names)
    byte_chan_inds = find(contains(chan_names, 'Packet_TimeStamp', 'IgnoreCase', true));
end

function type_str = getChanType(chan_name)
    tok = regexp(chan_name, '__type__=""(.*?)""', 'match');
    start_pos = strfind(tok{:}, '=') + 3;
    type_str = tok{1}((start_pos:end-2));
end

function start_time = get_starting_datenum_from_file(fileID, header_lines, rewind_at_end)
    % This function reads the first data line of a file and returns the 
    % timestamp as a datenum. It will rewind the file, skip any header
    % lines, read the first data line, and process it. Optional parameters
    % for passing number of header lines and rewinding the file at the end
    % of processing

    DEFAULT_HEADER_LINES = 1;
    DEFAULT_REWIND_AT_END = true;
    MAX_LINES_TO_SEARCH = 10;

    timestamp_reg_str = "\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}.\d+Z";

    if isempty(header_lines)
        header_lines = DEFAULT_HEADER_LINES;
    end

    if isempty(rewind_at_end)
        rewind_at_end = DEFAULT_REWIND_AT_END;
    end

    jump_to_first_data_in_file(fileID, header_lines);
    
    counter = 0;
    rawTime = [];
    
    while isempty(rawTime) & counter < MAX_LINES_TO_SEARCH
        first_line = fgetl(fileID);
        rawTime = regexp(first_line, timestamp_reg_str, 'match');
        counter = counter + 1;
    end

    if counter == MAX_LINES_TO_SEARCH
        error('No date found in the first %d data lines of %s', MAX_LINES_TO_SEARCH, fopen(fileID))
    end

    start_time = datenum(rawTime, 'yyyy-mm-ddTHH:MM:SS.FFFZ');

    if rewind_at_end
        frewind(fileID);
    end
end


function jump_to_first_data_in_file(fileID, header_lines)
    % move the file pointer to the first line after the specified
    % header_lines.
    % Start at first line with actual data
    frewind(fileID);
    for line_num = 1:header_lines
        fgetl(fileID);
    end
end

function Q = read_in_chunks(fileID, chunk_size, header_lines, chan_name_cell, varargin)
    
    num_cols = numel(chan_name_cell);
    bytes_in_file = dir(fopen(fileID)).bytes;

    use_prog = false;
    if ~isempty(varargin)
        % pp = varargin{1};
        pp_ind = varargin{1};
        use_prog = true;
        % % Since we're going to read/write this file, we're processing 2x
        % % bytes
        % pp.new_max_for_bar(pp_ind, num_cols);
    end

    Q = cell(1,num_cols);

    byte_chans = getByteChannelInds(chan_name_cell);
    fmt_cell = repmat({'%s'},1,num_cols); % First chan is "Time"
    fmt_cell(byte_chans) = {'%q'};
    fmt_str = strip([fmt_cell{:}]);

    
    jump_to_first_data_in_file(fileID, header_lines);
    
    last_byte = ftell(fileID);
    
    % Start Progress Monitor
    if use_prog
        pp.add_to_completed(pp_ind, last_byte)
    else
        progressbar('Reading .csv file into cell array')
    end

    while ~feof(fileID)
        this_chunk = textscan(fileID, fmt_str, chunk_size, "Delimiter",',');
        for col = 1:num_cols
            Q{1,col} = vertcat(Q{1,col}, this_chunk{1,col});
        
            % Update Progress
            if use_prog
                this_chunk_bytes = ftell(fileID) - last_byte;
                last_byte = ftell(fileID);
                
                pp.add_to_completed(pp_ind, this_chunk_bytes);
            else
                progressbar(ftell(fileID)/bytes_in_file);
            end
        end
    end

end

end