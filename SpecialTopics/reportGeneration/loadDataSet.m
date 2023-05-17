function loadDataSet( hObj, ~ )
%loadDataSet used to append a new dataset to the dataGrid tool
    
    ad = getappdata(hObj.Parent);
    dataIndex = ad.dataIndex;
    dataSetNames = ad.dataSetNames;
    hs = ad.hs;
    
    [ dataPath, ~ ] = selectDataSet;
    
    if isempty(dataPath)
        return
    end
    
    s = load(fullfile(dataPath, 'AvailableFDs.mat'));
    FDList = s.FDList;

    s = load(fullfile(dataPath, 'metadata.mat'));
    metaData = s.metaData;
    
    try
        s = load(fullfile(dataPath, 'timeline.mat'));
    catch
        s.timeline = [];
    end
    
    timeline = s.timeline;
    
    if any([isempty(metaData), isempty(FDList)])
        fprintf('Unable to load metadata or FDList from %s', dataPath);
        return
    end
    
    
    n = length(dataIndex) + 1;
    
    dataIndex(n).metaData = metaData;
    dataIndex(n).pathToData = dataPath;
    dataIndex(n).FDList = FDList;
    
    setappdata(hObj.Parent, 'dataIndex', dataIndex);
    
    
    dataSetNames = vertcat(dataSetNames, ...
        sprintf('%s %s', metaData.operationName, metaData.MARSprocedureName));
    setappdata(hObj.Parent, 'dataSetNames', dataSetNames);
    hs.popup_dataSetMain.String = dataSetNames;

end

