function parseDelimOnePass( data_file, output_folder, parse_raw, console_output )
%PARSEDELIMONEPASS imports a .delim file with mixed FDs wihtout external
%tools.
%   
%   This tool is noticeably faster than the previous parsing engine due to
%   the significantly reduced number of grep passes and file IO. This tool
%   will attempt to append data to any existing MDRT data file.
%
%   NOTE: this version requires the delim data to be chronological. Mixing
%   dates can cause crashes during the import process. No `restart` is
%   available.
%
%   Future versions will expose additional options: `start fresh`, `chunk
%   size`, and others.
%
%   Counts, VCSFA 2023

% Defaults
tic
CHUNK_SIZE = 800000;
DEFAULT_OUTPUT_FOLDER = fullfile(getuserdir,'Downloads','importdata');
DEFAULT_CONSOLE_OUTPUT = false;

%% Parse Arguments
if ~exist('data_file', 'var')
    error('no data_file argument passed')
end
    
if ~exist('output_folder', 'var')
    output_folder = DEFAULT_OUTPUT_FOLDER;
end

if ~exist('parse_raw', 'var')
    % Default to skipping RAW values
    parse_raw = false;
end

if ~exist('console_output', 'var')
    console_output = DEFAULT_CONSOLE_OUTPUT;
end

%% Get File Info

s = dir(data_file);
file_size = s.bytes;

disp('Pre-scanning file for line count');
lines_in_file = getFileLineCount(data_file);
disp('Opening file to parse');
fid = fopen(data_file);

%% Get/Create output folder
if ~ exist(output_folder, 'dir')
    try
        mkdir(output_folder);
    catch
        error('Could not create folder: %s', output_folder);
    end
end

%% Initialize Progress Calculation and Bar

progressbar('Delim file read', 'Chunk processed')
lines_parsed = 0;


%% Read File in Chunks
for n = 1:CHUNK_SIZE:lines_in_file

    Q = textscan(fid, '%s %*s %*s %s %s %s %*s %s %s', CHUNK_SIZE, ...
                    'Delimiter',        ',');
    
    timeCell        = Q{1};
    shortNameCell   = Q{2};
    valueTypeCell   = Q{3};
    longNameCell    = Q{4};
    valueCell       = Q{5};
    unitCell        = Q{6};


%% Get Unique FDs in This Chunk
    FD_names_in_chunk = unique(shortNameCell);
    num_FDs_in_chunk = numel(FD_names_in_chunk);
    
    
%% Parse Each FD in This Chunk
    for fdn = 1:num_FDs_in_chunk
        %% Create info for this particular FD
        this_FD_string      = FD_names_in_chunk{fdn};
        this_fd_info        = getDataParams(this_FD_string);
        
        this_FD             = newFD();
        this_FD.ID          = this_fd_info.ID;
        this_FD.Type        = this_fd_info.Type;
        this_FD.System      = this_fd_info.System;
        this_FD.FullString  = this_fd_info.FullString;
        
%% Create timeseries for This FD From This Chunk
        
        % Get indices and logical mask for this FD
        this_mask = strcmp(shortNameCell, this_FD_string);
        this_index = find(this_mask);
        
        %% Update parsed line total for progress calculation
        this_lines_to_parse = sum(this_mask);
        lines_parsed = lines_parsed + this_lines_to_parse;
        

        %% Skip this FD if index is empty
        if numel(this_index) == 0
            continue
        end
        
        if console_output
            sample_line = strjoin( ...
                {   timeCell{this_index(1)};
                    shortNameCell{this_index(1)};
                    valueTypeCell{this_index(1)};
                    longNameCell{this_index(1)};
                    valueCell{this_index(1)};
                    unitCell{this_index(1)};
                }, ',');
        
            disp(sample_line)
        end
        
        if isempty(this_FD_string)
            continue
        end
            
        
        %% Parse the FD Data From This Chunk
        % Extract the data type (for parsing method) and any engineering
        % unit data. Pass to the parsing subroutine for timeseries
        % generation
        
        % Handle RAW Value Parsing
        this_raw_mask = strcmp(unitCell, 'RAW');
        this_raw_index = find(this_raw_mask);
        
        if parse_raw
            this_mask = this_mask & this_raw_mask;
            % this_FD_string = strcat(this_FD_string, ' RAW');
            % this_FD.Fullstring = this_FD_string;
            this_FD.DataType = 'RAW';
            this_FD.Units = unitCell{'RAW'};
        else
            this_mask = this_mask & ~this_raw_mask;
            this_FD.DataType = valueTypeCell{this_index(1)};
            this_FD.Units = unitCell{this_index(1)};
        end
        
        
        
        this_ts = parse_by_value_type( ...
                        makeMatlabTimeVector(timeCell(this_mask), false, false), ...
                        valueCell(this_mask), ...
                        this_FD.DataType, ...
                        this_FD_string);
        
        % Parsing complete, update progress calculation and display
        progressbar( ...
            percent_file_imported(lines_parsed, lines_in_file), ...
            percent_of_fds_in_chunk(fdn, num_FDs_in_chunk))
                    
        % Don't write to disk if timeseries is empty (bad parsing)
        if isempty(this_ts)
            continue
        end
        
        % Add engineering units to timeseries, if present
        if ~isempty(this_FD.Units)
            this_ts.DataInfo.Units = this_FD.Units;
        end
        
        % Add new timeseries to the fd struct
        this_FD.ts = this_ts;

        % Update FD Fullstring from timeseries (handles RAW case)
        this_FD.FullString = this_ts.Name;


%% Create file to hold them if needed
        this_filename = makeFileNameForFD(this_FD.FullString);
        this_fullfile = strcat(fullfile(output_folder, this_filename), '.mat');
        
        if ~exist(this_fullfile, 'file')
            fd = this_FD;
            save(this_fullfile, 'fd');
        else
%% Append data to existing FD file
            from_file = load(this_fullfile);
            merged_ts = merge_timeseries(from_file.fd.ts, this_FD.ts);
            
            if isempty(merged_ts)
                % empty merged_ts means no work to do, skip writing to disk
                % since no change is made.
                continue
            end
                
            from_file.fd.ts = merged_ts;
            fd = from_file.fd;
            save(this_fullfile, 'fd');
        end

        
    end

end

fclose(fid);
toc

end

%% Subroutines
% These functions are utilities used by the main business logic to perform
% required operations that clutter the flow of the main function.



function done = percent_file_imported(lines_parsed, total_lines)
%percent_file_imported returns a progress calculation for the progress bar
    done = lines_parsed / total_lines;
end

function done = percent_of_fds_in_chunk(current_fd_ind, total_fds)
%percent_of_fds_in_chunk returns a progress calculation for the progress bar
    done = current_fd_ind / total_fds;
end

function ts = merge_timeseries(ts_orig, ts_add)
%MERGE_TIMESERIES attempts to merge timeseries in an order-insensitive
%manner.
% Adds missing data from ts_add to ts_orig. Uses ts_orig.TimeInfo.Units and
% ts_orig.DataInfo.Units in merged result.

    debugout(sprintf('Merging %s and %s', ts_orig.Name, ts_add.Name))
    if ts_orig.Time(end) == ts_add.Time(1)
        ts = ts_orig.append(ts_add);
    else
        
        % setdiff(N, O) retirns elements from N not found in O
        [times_to_add, inds] = elements_from_not_in(ts_add.Time, ts_orig.Time);
        
        % If nothing new (like in a re-parse) then skip and return empty
        if isempty(inds)
            ts = [];
            return
        end
        
        % We have new times to add, grab corresponding new data.
        % are thes orders guaranteed?
        data_to_add = ts_add.Data(inds);
        
        newTimeVect = vertcat(ts_orig.Time, times_to_add);
        newDataVect = vertcat(ts_orig.Data, data_to_add);
        
        ts = timeseries(newDataVect, newTimeVect, 'Name', ts_orig.Name);
        ts.DataInfo = ts_orig.DataInfo;
        ts.TimeInfo.Units = ts_orig.TimeInfo.Units;
%             ts = addsample(ts_orig, 'Data', newData, 'Time', newTimes, 'OverwriteFlag', true);
%         end
    end
end

function [vect, from_inds] = elements_from_not_in(from_vect, not_in_vect)
    [vect, from_inds] = setdiff(from_vect, not_in_vect);
end

function new_ts = parse_by_value_type(time, data, type, fullstring)
% PARSE_BY_VALUE_TYPE is the main parsing engine for MDRT/CCTK Data.
%
%   This function takes the following arguments:
%       time        [cell array of strings]
%       data        [cell array of strings]
%       type        char
%       fullstring  char
%
%   These numerical parsing methods have been optimized using the MATLAB
%   profiler to be as efficient as possible at extracting data from the
%   comma separated data files produced by UGFCS.
%
%   Any data that are unparsable (or are intentionally skipped) will return
%   an empty variable []. This allows the invoking function to check for an
%   empty timeseries easily.

    new_ts = [];
    
    switch type
        case 'D'
            % Process as discrete to fix integer conversion
            % use cellfun isempty with regex to find all
            % values that do not contain 0. These should
            % all be true.
            debugout('Discrete data type detected')
            new_ts = timeseries( cellfun(@isempty,regexp(data,'^0')), time, 'Name', fullstring);
            

        case {'CR', 'SC', 'BA'}
            % Ignore control stuff that is non-numerical
            % for now. System Command and Command Response

            debugout('File contains data of type ''CR'' - Skipping FD')
            new_ts = [];


        case { 'RAW' }
            % convert hex to decimal - byte swap happens
            % after conversion.
            RAW_SUFFIX = ' RAW';
            
            debugout('Importing RAW data');
            fullstring = strcat(fullstring, RAW_SUFFIX);
            new_ts = timeseries(swapbytes(uint16( hex2dec( data(:) ) ) ), ...
                            time, ...
                            'Name', fullstring );
    
        otherwise
            % Process with optimized floating point
            % conversion for maximum speed
            % Remember the space after %s to prevent
            % concatenating all values from array into one
            % long string!!!

            try
                new_ts = timeseries( sscanf(sprintf('%s ', data{:,1}),'%f'), time, 'Name', fullstring);
            catch ME
%                 handleParseFailure(ME)
            end
    end
                   
    return

end
