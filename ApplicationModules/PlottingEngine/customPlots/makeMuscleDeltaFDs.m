pressFiles = {
    '5070 GN2 PT-5070 Press Sensor Mon.mat' ;
    '5903 GN2 PT-5903 Press Sensor Mon.mat' ;
    };

config = MDRTConfig.getInstance;
load(fullfile(config.dataArchivePath, 'dataindex.mat'));


location = dataIndex(end-8).pathToData;

sourceFile = fullfile(location, pressFiles{2});
doghouseFile = fullfile(location, pressFiles{1});

ls = load(sourceFile);
d = struct('src', ls.fd);

ls = load(doghouseFile);
d.dog = ls.fd;


%% Make timevector from both FDs

newTimeVect = [d.src.ts.Time; d.dog.ts.Time];
newTimeVect = sort(newTimeVect);
newTimeVect = unique(newTimeVect);

%% Interp each FD over new timevector

d.newDog = d.dog.ts.resample( newTimeVect);
d.newSrc = d.src.ts.resample( newTimeVect);

d.muscleDelt = d.newDog - d.newSrc;

fd = newFD;
fd.ID = '5070-5903';
fd.Type = 'dPT';
fd.System = 'GN2';
fd.FullString = 'Muscle Delta between 5903 and 5070';
d.muscleDelt.Name = fd.FullString;
fd.ts = d.muscleDelt;

%% Save the new FD

newFileName = '5070-5903 Muscle Delta.mat';
save(fullfile(location, newFileName), 'fd');





