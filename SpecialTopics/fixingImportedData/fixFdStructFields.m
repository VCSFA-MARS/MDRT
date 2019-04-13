%% Fixes fd metadata (fd.ID, etc) from badly parsed data.
%
%   This script alters the data folder without making a backup. Use only if
%   you really understand the implications and how to fix any issues.
%
%   Steps to run:
%
%   1. Select a data folder (archive/mission/data)
%   2. The script loops through each file in the folder, non-recursively
%   3. It opens each file, grabs the FD struct and passes the FD.FullString
%      parameter to getDataParam()
%   4. It then reassigns the values of fd.ID, fd.Type, and fd.System with
%      new, correctly parsed strings
%   5. The file is saved, overwriting the original without making any
%      backup.
%
%   Counts, 2018 - VCSFA



path = uigetdir();

files = dir(fullfile(path,'*.mat'));

%%

progressbar('Re-parsing ID, Type, and System');

for i = 1:numel(files)
    
    if (~files(i).isdir && ~strcmpi('timeline.mat', files(i).name) && ~strcmpi('metadata.mat', files(i).name) && ~strcmpi('AvailableFDs.mat', files(i).name) )
        
        s = load(fullfile(path, files(i).name), '-mat');
        
        if isfield(s, 'fd')
            fd = s.fd;
        else
            fd = s;
        end
            
%       
        p = getDataParams(fd.FullString);
        
        fd.ID         = p.ID;
        fd.Type       = p.Type;
        fd.System     = p.System;
        
        save(fullfile(path, files(i).name), 'fd', '-mat')

    end
    
    progressbar(i/numel(files));
end