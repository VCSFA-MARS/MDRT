function fd = load_fd_by_name(fd_str)
%load_fd_by_name returns an fd struct in the currently selected data set
%for the given full string FD name

% config = MDRTConfig.getInstance;
config = getConfig;

filename = fullfile(config.dataFolderPath, ...
    [makeFileNameForFD(fd_str), '.mat'] );

if ~exist(filename, "file")
    fprintf('File not found: %s\n', filename)
    error('Tried to load non-existant FD: %s', fd_str)
end

s = load(filename);
fd = s.fd;

end