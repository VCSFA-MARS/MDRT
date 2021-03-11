%% Variable creation
clear

s = load('/Users/nick/data/archive/2019-11-01 - NG-12/data/2116 LO2 TC-2116 Temp Sensor Mon.mat');
fd = s.fd;
clear s
fn = '/Users/nick/data/archive/2019-11-01 - NG-12/data/2905 LO2 TC-2905 Temp Sensor Mon.mat';

%% Test figure generation

f = MDRTFigure
f.subplots(1).addFD(fd)
f.subplots(1).addFDfromFile(fn)

