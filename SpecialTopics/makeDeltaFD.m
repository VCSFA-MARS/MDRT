pressFiles = {
    'TELHS_SYS1 LT11 Mon.mat' ;
    'TELHS_SYS1 LT14 Mon.mat' ;
    };

location = '/Users/nick/data/TEL_Historical/2022-02-15 - NG17 Lift 1/data';

initialFile = fullfile(location, pressFiles{2});
finalFile = fullfile(location, pressFiles{1});

ls = load(initialFile);
d = struct('init', ls.fd);

ls = load(finalFile);
d.final = ls.fd;


%% Make timevector from both FDs

newTimeVect = [d.init.ts.Time; d.final.ts.Time];
newTimeVect = sort(newTimeVect);
newTimeVect = unique(newTimeVect);

%% Interp each FD over new timevector

d.newFinal = d.final.ts.resample( newTimeVect);
d.newInit  = d.init.ts.resample( newTimeVect);

d.muscleDelt = d.newFinal - d.newInit;

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





