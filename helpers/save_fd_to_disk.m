function save_fd_to_disk(fd, varargin)
%save_fd_by_name saves an fd struct in the currently selected data set
%with an appropriate filename.
%
%This function responds to the version field in the fd struct, saving for
%matfile() streaming if not legacy version (v1)
%
%Accepts 'folder' argument to save to the specified location. If omitted, 
%the file is saved to the currently selected data set

ORIG_VERSION = {'', 'v1'};
is_save_for_streaming = true;


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
        end
    end
end


%% Build fullfile path/name

file_str = [makeFileNameForFD(fd), '.mat'];
filename = fullfile(dest_folder, file_str );


%% Check version and set behavior flags
if isfield(fd, 'version')
    if ismember(fd.version, ORIG_VERSION)
        is_save_for_streaming = false;
    end
end


%% Write to disk in version-dependent format
if is_save_for_streaming == false
    save(filename, 'fd');
elseif is_save_for_streaming
    save(filename, '-struct', 'fd')
end


end