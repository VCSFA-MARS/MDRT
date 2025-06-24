function fd = load_fd_by_name(fd_str, varargin)
%load_fd_by_name returns an fd struct in the currently selected data set
%for the given full string FD name
%
%Accepts 'folder' argument to load from the specified location. If omitted, 
%the file is loaded from the currently selected data set

%% Process optional arguments

if ~length(varargin) > 0
    config = getConfig;
    containing_folder = config.dataFolderPath;
else
    for i = 1:2:length(varargin)
        key = varargin{i};
        value = varargin{i+1};
        switch lower(key)
            case {'folder', 'destination', 'dest', 'path', 'location'}
                assert(isfolder(value));
                containing_folder = value;
        end
    end
end



%% Build fullfile path/name

file_str = [makeFileNameForFD(fd_str), '.mat'];
filename = fullfile(containing_folder, file_str );


%% Fail if file does not exist
if ~exist(filename, "file")
    fprintf('File not found: %s\n', filename)
    error('Tried to load non-existant FD: %s', fd_str)
end

%% Determine version of .mat file

fd = whos('-file', filename);
is_v1 = ismember('fd', {fd.name});


%% Perform loading based on version
if is_v1
    s = load(filename);
    fd = s.fd;
else
    fd = load(filename);

    % Build timeseries (converting back to v1 shape
    fd.ts = timeseries(fd.Data, fd.Time);
    fd.ts.Name = fd.FullString;
    fd.ts.DataInfo.Units = fd.Units;

    % Clean out Time and Data to save memory
    fd = rmfield(fd, {'Data', 'Time'});

end