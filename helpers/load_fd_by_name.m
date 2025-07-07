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

%% Disk Format
%
% A 'version 2' disk format is now in use for exporting data to customers
% and for some large-import tasks. The legacy (version 1) disk format has
% no version identifier. This tool will treat any .mat file with a somewhat
% valid fd structure as 'version 1' if it is explicitely tagged, or if
% there is no version information.
%
% This function loads data from disk and stuffs it into the standard fd
% structure that all MDRT tools use. The intention is to keep the in-memory
% fd struct consistent and to abstract away from the on-disk
% representation.
 
%TODO
% .mat file compression should be off for faster writes, but maybe on for
% best file size and performance? Not sure what to do here

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

%% Create matfile() link to file and read stored variables
mf = matfile(filename);
fields = fieldnames(mf);
assert(~isempty(fields));

%% Determine version of .mat file

disk_version = 'v1'; % default

if any(ismember(fields, 'disk_version')) && strcmpi(mf.disk_version, 'v2')
    disk_version = 'v2';
end


%% Perform loading based on version
switch disk_version
    case 'v1'
        fd = mf.fd;
        
    case 'v2'
        fd = newFD();

        % Build timeseries (converting back to v1 shape
        fd.ts = timeseries(mf.Data, mf.Time);
        
        if ismember(fields, 'Name')
            fd.ts.Name = mf.Name;
        else
            fd.ts.Name = mf.FullString;
        end

        fd.ts.DataInfo.Units = mf.Units;
    
    otherwise
        error('Unknown data file structure in %s\n%s', filename, mf);
end



