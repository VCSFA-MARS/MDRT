dataFolders = { '/Users/engineer/Data Repository/2021-02-19_NG-15_Launch/data';
                '/Users/engineer/Data Repository/2020-10-02 - NG-14 Launch/data';
                '/Users/engineer/Imported Data Repository/2021-05-13 - 414STE test/data';

                };
            
dataFiles = {   '4913 Ghe PT-4913 Press Sensor Mon.mat';
                '4914 Ghe PT-4914 Press Sensor Mon.mat';
                '4915 Ghe PT-4915 Press Sensor Mon.mat'; };

          
mAx = makeManyMDRTSubplots(3, 'VNO1 Actuation', ...
                'newStyle',     true, ...
                'plotsHigh',    3,      'plotsWide',    1, ... 
                'groupAxesBy',  1)
            

            
%% Iterate across data sets and plan plots

DataSet = struct;
PlotParam = [];

for dfi = 1:numel(dataFolders)
    commandCounter = 0;
    metaFile = fullfile(dataFolders{dfi}, 'metadata.mat');
    timeFile = fullfile(dataFolders{dfi}, 'timeline.mat');
    

    
    try
        ms = load(metaFile);
        ts = load(timeFile);
        
        DataSet(dfi).metadata = ms.metaData;
%         DataSet(dfi).timeline = ts.timeline;
        DataSet(dfi).Mission = ms.metaData.operationName;
    catch
    end
    
    
    ThesePTs = [];
    for fdi = 1:numel(dataFiles);
        load(fullfile(dataFolders{dfi}, dataFiles{fdi}));
        ThesePTs = vertcat(ThesePTs, fd);
    end
    
    DataSet(dfi).PTFDs = ThesePTs;
    
end

%% Generate Plots

for di = 1:numel(DataSet)
    
    thisAx = mAx(di);
  
    thisDataSet = DataSet(di);
    
    
    % Helium Pressure Plots
        
    for p = 1:numel(thisDataSet.PTFDs)
        thisAx.addFD(thisDataSet.PTFDs(p));
    end
                    



    dynamicDateTicks(thisAx.hAx);
    setDateAxes(thisAx.hAx, 'YLim', [2500, 3500]);
%     MDRTEvent(thisPlot.event, thisAx);
    
    
    thisAx.title = thisDataSet.Mission;
    


    
end

%% Time "Alignment"
disp('Axes Synchronization Instructions:')
disp('Zoom in on each axis until they are roughly focused on the data you want to see. When you dismiss this dialog, each axis will be slightly resized to show the same time interval')


delta = mAx(1).hAx.XLim(2) - mAx(1).hAx.XLim(1);
mAx(2).hAx.XLim = [mAx(2).hAx.XLim(1), mAx(2).hAx.XLim(1)+delta];
mAx(3).hAx.XLim = [mAx(3).hAx.XLim(1), mAx(3).hAx.XLim(1)+delta];

