function save_fd_to_disk(fd, varargin)
%save_fd_to_disk saves an fd struct in the currently selected data set
%with an appropriate filename.
%
%This function responds to the version field in the fd struct, saving for
%matfile() streaming if not legacy version (v1)
%
%Accepts 'disk-version' argument to save in the legacy `.mat` structure and
%file formats. If not supplied, the legacy disk format will be used.
%   valid arguments: 'v1', 'v2', 'latest'
%
%Accepts 'folder' argument to save to the specified location. If omitted, 
%the file is saved to the currently selected data set

%% Disk Format
%
% In order to support exporting to python-based tools, as well as to
% improve the performance of MDRT imports of large files, a new disk-format
% has been implemented. The 'version 2' disk format will keep the Time and
% Data vectors as primary fields in the `fd` struct.
% This will also allow for direct indexing into large data files without
% loading the entire contents into memory.
%
% For incremental writing to work, the .mat file needs to be saved with the
% '-v7.3' flag. This is done by default when a .mat file is created using
% `matfile(filename, 'writable', true)`
% 
%TODO
% .mat file compression should be off for faster writes, but maybe on for
% best file size and performance? Not sure what to do here

ORIG_VERSIONS = {'', 'v1'};

use_legacy_format = true; % default to legacy disk-format


%% Process optional arguments

if ~length(varargin) > 0
    config = getConfig;
    dest_folder = config.dataFolderPath;
else
    for i = 1:2:length(varargin)
        key = varargin{i};
        value = varargin{i+1};
        switch lower(key)
            case {'folder', 'destination', 'dest', 'path', 'location'}
                assert(isfolder(value));
                dest_folder = value;

            case {'disk-version', 'version', 'disk_version'}
                assert(ischar(value));
                switch value
                    case {'v2', 'latest'}
                        use_legacy_format = false;
                    case ORIG_VERSIONS
                        use_legacy_format = true;
                    otherwise
                        use_legacy_format = true;
                end
        end
    end
end


%% Build fullfile path/name

file_str = [makeFileNameForFD(fd), '.mat'];
filename = fullfile(dest_folder, file_str );
mf = matfile(filename, 'Writable', true);

%% Save in legacy format if needed:

if use_legacy_format
    fd_fields = fieldnames(fd);
    assert(~isempty(fd_fields))
    mf.fd = fd;
    % Should we explicitly add the disk-version here, even for legacy
    % support? It *changes* the struct on the disk, but it makes it clear.
    % Punting this for another rev

    return
end


%% Write to disk in version-dependent format

% We only have one format right now, so no switch/case nonsense yet
mf.disk_version = 'v2';

mf.Time = fd.ts.Time;
mf.Data = fd.ts.Data;
mf.Units = fd.ts.DataInfo.Units;
mf.Name = fd.ts.Name;

fd.ts = [];

% Loop through the remaining fd fields and write to disk
fd_fields = fieldnames(fd);
assert(~isempty(fd_fields))
for f = 1:length(fd_fields)
    this_field = fd_fields{f};
    mf.(this_field) = fd.(this_field);
end


end