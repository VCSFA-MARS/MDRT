function convertDataFilesToFDVersion(pathToData, disk_version_str)

supported_versions = {'v1', 'v2'};
default_version = 'v2';
assert(ismember(disk_version_str, supported_versions));

%% Allow calling as a standalone or with a path;
if nargin == 0
  rootDir_path = uigetdir;
  if rootDir_path == 0
    % User pressed cancel
    return
  end
  
  % Set the default values if no arguments were passed. Why is this so ugly
  pathToData = rootDir_path; % set the input argument from UI response
  disk_version_str = default_version;

end

if ~exist(pathToData, 'dir')
  error('input argument is not a valid directory');
end

debugout(sprintf('Processing data files in the folder: %s', pathToData))

%% Get list of files in directory that contain MDRT data

FDList = updateFDListFromDir(pathToData, 'save', 'no', 'prompt', 'no', 'force', 'no');

if height(FDList) == 0
  % No FD files found
  debugout('No FDs in selected directory')
  return
end

%% Create output folder

export_path   = fullfile(pathToData, ['data_', disk_version_str]);
mkdir(export_path);
debugout(sprintf('Created export directory: %s', export_path))


%% Iterate over FDs in data set

progressbar('Converting files')

% {'fd string', 'filename.ext'}
for i = 1:height(FDList)
  this_fd_str = FDList{i, 1};
  this_filename = FDList{i, 2};
  
  thisFD = load_fd_by_name(this_filename, "isFilename", true, "folder", pathToData);
  debugout(sprintf('Loaded: %s', this_filename))
  save_fd_to_disk(thisFD, "folder", export_path, 'disk-version', disk_version_str)
  debugout(sprintf('Converted: %s', this_filename))
  progressbar(i/height(FDList));
  
end
