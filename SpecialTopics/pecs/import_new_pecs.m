%% Import data from text file
% Script for importing data from the PECS data csv:


% DEFAULT_FILE = "/Users/nick/data/import/2026-03-04 - PECS Testing/202

fd = newFD;

config = MDRTConfig.getInstance;
[~, folder_name, ~ ] = fileparts(config.userWorkingPath);

prog_bar_str = sprintf('Importing PECS Data to %s', folder_name);
progressbar(prog_bar_str)

num_channels = numel(opts.VariableNames);

for n = 1:num_channels
  thisName = opts.VariableNames{n};
  
  if thisName == "Time"
    continue
  end

  progressbar(n/num_channels)

  fd.System = 'PECS';
  fd.FullString = sprintf('PECS %s', thisName);

  validData = ~isnan(PECS.(thisName));
  
  ts = timeseries(PECS.(thisName)(validData) , ...
    datenum(PECS.Time(validData)));
  ts.Name = fd.FullString;
  fd.ts = ts;

  save_fd_to_disk(fd);

end




%% Clear temporary variables
clear opts