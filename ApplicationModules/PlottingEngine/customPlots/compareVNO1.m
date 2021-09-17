config = MDRTConfig.getInstance;
    arch = config.dataArchivePath;
    impt = config.importDataPath;


    
dataFolders = { ... %fullfile(arch, '2021-02-19 - NG-15 Launch/data');
                fullfile(arch, '2020-10-02 - NG-14 Launch/data') ;
                fullfile(impt, '2021-05-13 - ITR-2084 OP-120/data');
                fullfile(impt, '2021-05-14 - ITR-2084 OP-121/data');
                };
            
dataFiles = {   '4913 Ghe PT-4913 Press Sensor Mon.mat';
                '4914 Ghe PT-4914 Press Sensor Mon.mat';
                '4915 Ghe PT-4915 Press Sensor Mon.mat';
                '4912 Ghe PT-4912 Press Sensor Mon.mat';
                'CB4 Analog In 02 Mon.mat'};


nSubs = numel(dataFolders);            
            
mAx = makeManyMDRTSubplots(nSubs, 'VNO1 Actuation', ...
                'newStyle',     true, ...
                'plotsHigh',    nSubs,      'plotsWide',    1, ... 
                'groupAxesBy',  1)
            

            
%% Iterate across data sets and plan plots

DataSet = struct;
PlotParam = [];

for dfi = 1:numel(dataFolders)
    commandCounter = 0;
    metaFile = fullfile(dataFolders{dfi}, 'metadata.mat');
    timeFile = fullfile(dataFolders{dfi}, 'timeline.mat');
    

    
    try
        ts = load(timeFile);
        DataSet(dfi).timeline = ts.timeline;
    catch
        DataSet(dfi).timeline = [];
    end
    
    try
        ms = load(metaFile);
        DataSet(dfi).metadata = ms.metaData;
        DataSet(dfi).Mission = ms.metaData.operationName;
    catch
        DataSet(dfi).Mission = '';
    end
    
    
    ThesePTs = [];
    for fdi = 1:numel(dataFiles);
        try
            load(fullfile(dataFolders{dfi}, dataFiles{fdi}));
            ThesePTs = vertcat(ThesePTs, fd);
        catch
            
        end
    end
    
    DataSet(dfi).PTFDs = ThesePTs;
    
end

%% Generate Plots

for di = 1:numel(DataSet)
    
    thisAx = mAx(di);
  
    thisDataSet = DataSet(di);
    
    
    % Helium Pressure Plots
    try
        for p = 1:numel(thisDataSet.PTFDs)
            thisAx.addFD(thisDataSet.PTFDs(p));
        end
    catch
        disp('skipping!')
    end

    


    dynamicDateTicks(thisAx.hAx);
    setDateAxes(thisAx.hAx, 'YLim', [2500, 4500]);
%     MDRTEvent(thisPlot.event, thisAx);
    
    
    thisAx.title = thisDataSet.Mission;
    


    
end
reduce_plot(thisAx.hAx.Children)
%% Time "Alignment"
disp('Axes Synchronization Instructions:')
disp('Zoom in on each axis until they are roughly focused on the data you want to see. When you dismiss this dialog, each axis will be slightly resized to show the same time interval')


delta = mAx(1).hAx.XLim(2) - mAx(1).hAx.XLim(1);
% mAx(2).hAx.XLim = [mAx(2).hAx.XLim(1), mAx(2).hAx.XLim(1)+delta];
% mAx(3).hAx.XLim = [mAx(3).hAx.XLim(1), mAx(3).hAx.XLim(1)+delta];

for ai = 2:numel(mAx)
    mAx(ai).hAx.XLim = [mAx(ai).hAx.XLim(1), mAx(ai).hAx.XLim(1)+delta];
end

