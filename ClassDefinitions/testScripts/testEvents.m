%% Plot Setup
%
% Load a sample FD and sample timeline.mat file
% Create a basic MDRTFigure with 1 axis and plot the sample FD

load('timeline.mat');
load('2013 LO2 PCVNO-2013 Globe Valve Mon.mat');

MFig = MDRTFigure( MDRTAxes('test axes') );
MFig.addSubplot(MDRTAxes('test axes 2') );

MFig.subplots(1).addFDfromFile('2013 LO2 PCVNO-2013 Globe Valve Mon.mat')

%% Event 
%
% Create an event object using the first milestone in the timeline struct
% and associate it with MFig

Mevent = MDRTEvent(timeline.milestone(1), MFig)

