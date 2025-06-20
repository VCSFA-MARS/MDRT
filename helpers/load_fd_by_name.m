function fd = load_fd_by_name(fd_str, varargin)
%load_fd_by_name returns an fd struct in the currently selected data set
%for the given full string FD name
%
%Accepts 'folder' argument to load from the specified location. If omitted, 
%the file is loaded from the currently selected data set
%
%   fd = load_fd_by_name('An FD String', 'folder', '/my/data/folder');
%
%Accepts 'isFilename' argument (default is false). If true, then the
%fd_str is treated as the filename instead of the fd string. Allows you to
%use the function to open a particular file without knowing the fd string.
%
%   fd = load_fd_by_name('my_file', 'isFilename', true);
%
%If no .mat extension is given, one will be appended. If a different
%extension is given, it will be changed to .mat
%
%When specifying by filename, if there is a path in the filename string, it
%will be discarded in favor of the current data set or the 'folder'
%argument.

%% Defaults

use_filename = false;

config = getConfig;
containing_folder = config.dataFolderPath;


%% Process optional arguments

for i = 1:2:length(varargin)
    key = varargin{i};
    value = varargin{i+1};
    switch lower(key)
        case {'folder', 'destination', 'dest', 'path', 'location'}
            assert(isfolder(value));
            containing_folder = value;
        case {'isfilename','byfilename', 'byname'}
            use_filename = value;
    end
end



%% Build fullfile path/name

if iscellstr(fd_str)
    while iscellstr(fd_str) % unwrap the cellstr
        fd_str = fd_str{1};
    end
end
assert(ischar(fd_str))

if use_filename
    [~,name,ext] = fileparts(fd_str);
    % Add .mat extension if missing
    if isempty(ext)
        fd_str = [name, '.mat'];
    else
        % Replace bad extension with .mat
        if ~strcmpi(ext, '.mat')
            fd_str = [name, '.mat'];
        end
    end
    file_str = fd_str;
else
    file_str = [makeFileNameForFD(fd_str), '.mat'];
end

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