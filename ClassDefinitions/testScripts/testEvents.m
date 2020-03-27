%% Plot Setup

load('timeline.mat');
load('2013 LO2 PCVNO-2013 Globe Valve Mon.mat');

MFig = MDRTFigure;

MFig.subplots.addFDfromFile('2013 LO2 PCVNO-2013 Globe Valve Mon.mat')

%% Event 

Mevent = MDRTEvent(timeline.milestone(1), MFig)

