function [ output_args ] = parseDelimOnePass( data_file, output_folder )
%PARSEDELIMONEPASS imports a .delim file with mixed FDs wihtout external
%tools.
%   

% Defaults

CHUNK_SIZE = 50000;
DEFAULT_OUTPUT_FOLDER = fullfile(getuserdir,'Downloads','importdata');


%% Parse Arguments
if ~exist('output_folder', 'var')
    output_folder = DEFAULT_OUTPUT_FOLDER;
end

%% Get File Info

s = dir(data_file);
file_size = s.bytes;

lines = getFileLineCount(data_file);

fid = fopen(data_file);

%% Get/Create output folder
if ~ exist(output_folder, 'dir')
    try
        mkdir(output_folder);
    catch
        error('Could not create folder: %s', output_folder);
    end
end

progressbar('Delim file read', 'Chunk processed')

for n = 1:CHUNK_SIZE:lines

    
%% Read a chunk
    Q = textscan(fid, '%s %*s %*s %s %s %s %*s %s %s', CHUNK_SIZE, 'Delimiter', ',');
    
    timeCell        = Q{1};
    shortNameCell   = Q{2};
    valueTypeCell   = Q{3};
    longNameCell    = Q{4};
    valueCell       = Q{5};
    unitCell        = Q{6};

%% Update import progress
progressbar(percent_file_imported(n, lines, CHUNK_SIZE), []);
    
%% Get unique FD list
    FD_names_in_chunk = unique(shortNameCell);
    num_FDs_in_chunk = numel(FD_names_in_chunk);
    
%% Create FD variable to hold this chunk
    for fn = 1:num_FDs_in_chunk
        this_FD_string      = FD_names_in_chunk{fn};
        this_fd_info        = getDataParams(this_FD_string);
        
        this_FD             = newFD();
        this_FD.ID          = this_fd_info.ID;
        this_FD.Type        = this_fd_info.Type;
        this_FD.System      = this_fd_info.System;
        this_FD.FullString  = this_fd_info.FullString;
        
%% Create timeseries from this FD string in this chunk
        this_mask = strcmp(shortNameCell, this_FD_string);
        this_index = find(this_mask);
        
        if numel(this_index) == 0
            continue
        end
        
        this_FD.Units = unitCell{this_index(1)};
        
        this_ts = parse_by_value_type( ...
                        makeMatlabTimeVector(timeCell(this_mask), false, false), ...
                        valueCell(this_mask), ...
                        this_FD.Type, ...
                        this_FD_string);
                    
        this_FD.ts = this_ts;
                    
        progressbar([], percent_of_fds_in_chunk(fn, num_FDs_in_chunk))
        
        if isempty(this_ts)
            continue
        end


%% Create file to hold them if needed
        this_filename = makeFileNameForFD(this_FD_string);
        this_fullfile = strcat(fullfile(output_folder, this_filename), '.mat');
        
        if ~exist(this_fullfile, 'file')
            fd = this_FD;
            save(this_fullfile, 'fd');
        else
%% Append data to existing FD file
            existing_file = load(this_fullfile);
            new_ts = append(existing_file.fd.ts, this_ts);
            existing_file.fd.ts = new_ts;
            fd = existing_file.fd;
            save(this_fullfile, 'fd');
        end

        
    end

end

fclose(fid);


end

function done = percent_file_imported(current_index, total_lines, chunk_size)
    if current_index + chunk_size >= total_lines
        current_line = total_lines;
    else
        current_line = current_index + chunk_size;
    end
    done = current_line / total_lines;
end

function done = percent_of_fds_in_chunk(current_fd_ind, total_fds)
    done = current_fd_ind / total_fds;
end



function new_ts = parse_by_value_type(time, data, type, fullstring)
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
            
            debugout('Importing RAW data');
            fullstring = strcat(fullstring, RAW_Suffix);
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
