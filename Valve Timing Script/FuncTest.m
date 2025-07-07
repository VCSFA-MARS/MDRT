clear;clc;
close all force

DataPath = ['C:\Users\AustinThomas\Desktop\data\import\' ...
    'TestData_Morning\data'];
ExportFileName = 'ValveTimingTestResults.mat';

ValveTimingFunc(DataPath,ExportFileName)