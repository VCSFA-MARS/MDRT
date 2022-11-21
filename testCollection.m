%% Test MDRTEvent.asdlfasdf
close all
clear all
clc

load('/Users/nick/Documents/MATLAB/graphconfig/ECS Core Overview.gcf', '-mat')
load('/Users/nick/data/archive/2022-11-06 - NG-18 Launch/data/timeline.mat')

plotGraphFromGUI(graph, timeline)
hFig = gcf;

%% Collection Creation


EC = MDRTEventCollection(hFig)
setappdata(hFig, 'EventCollection', EC);


%% 

EC.addEventsFromTimeline(timeline)