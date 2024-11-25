function save_fd_to_disk(fd)
%save_fd_by_name saves an fd struct in the currently selected data set
%with an appropriate filename

% config = MDRTConfig.getInstance;
config = getConfig;

filename = fullfile(config.dataFolderPath, ...
    [makeFileNameForFD(fd), '.mat'] );

% if ~exist(filename, "file")
%     fprintf('File not found: %s\n', filename)
%     error('Tried to load non-existant FD: %s', fd)
% end

save(filename, 'fd');

end