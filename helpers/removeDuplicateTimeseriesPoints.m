function newTs = removeDuplicateTimeseriesPoints(ts)
%% removeDuplicateTimeseriesPoints returns a copy of the timeseries object
%   with any duplicated timestamps removed. Keeps the first instance. All
%   other timeseries object properties are retained

    masterInd = 1:length(ts.Time);
    [C,IA,IC] = unique(ts.Time);
    
    duplicateIndices = setdiff(masterInd, IA);
    
    newTs = ts.delsample('Index', duplicateIndices);
    
