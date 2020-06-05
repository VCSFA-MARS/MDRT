% This script joins FDs from different data sets to allow easy data
% plotting from multiple TAMs.
%
%   set 'early' to the data folder that contains the earlier data
%   set 'late' to the data folder that contains the later data
%   set 'new' to the folder where the new, combined FD will be saved as a
%       .mat file.
%

% Counts - VCSFA 2018


early = '/Users/nick/data/archive/2018-11-12 - NG10 ECS/data';
late = '/Users/nick/data/archive/2018-11-16 - NG-10 Launch/data';
new = '/Users/nick/data/imported/ecs';

files = dir(early);

progressbar('Combining FD.mat files...');

for i = 1:numel(files)
    
    if regexpi(files(i).name, '.mat')
        
        if exist(fullfile(late, files(i).name))
        
            contents = whos('-file', fullfile(late, files(i).name));
            if strcmp(contents.name, 'fd')

                fd1 = load(fullfile(early, files(i).name), 'fd');
                fd2 = load(fullfile(late,  files(i).name), 'fd');

                tsNew = fd1.fd.ts.append(fd2.fd.ts);

                fd = fd1.fd;
                fd.ts = tsNew;

                save(fullfile(new, files(i).name), 'fd')

            end
        
        end
        
    end
    
    progressbar(i/numel(files));
    
end

progressbar(1)
