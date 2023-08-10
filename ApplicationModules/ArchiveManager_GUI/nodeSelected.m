function [ output_args ] = nodeSelected( hobj, event, varargin )
%nodeSelected 
%   
    
    cn = event.getCurrentNode;
    
%     cn.setIcon(java.awt.Toolkit.getDefaultToolkit.createImage('folder-warning-16x16.png'))
%     drawnow
    
    path = arrayfun(@(nd) char(nd.getName), cn.getPath, 'Uniform', false);
    
    npath = '';
    for i = 1:length(path)
        npath = fullfile(npath, path{i});
    end
    debugout(npath)
    
    metaDataFile = fullfile(npath, 'data', 'metadata.mat');
    
    %% Load metadata and update AppData
    
    if exist(metaDataFile, 'file')
        load(metaDataFile);
        debugout(metaData);
        setappdata(hobj.Parent, 'SelectedDataSet', metaData);
    else
        % No metadata file found!
        tempMD = newMetaDataStructure;
        tempMD.timeSpan = [ now - 1, now ];
        tempMD.MARSprocedureName = 'NO METADATA FOUND';
        tempMD.fdList = {'NO METADATA', 'NO METADATA'};
        metaData = tempMD;
        setappdata(hobj.Parent, 'SelectedDataSet', metaData);
    end
    
    
    %% Update GUI Display ?
    liveStrings = getappdata(hobj.Parent.Parent, 'liveStrings');
    hlabel      = getappdata(hobj.Parent.Parent, 'hlabel');
    
    for n = 1:length(liveStrings)
    
        fieldName = liveStrings{n,1};
        if isfield(metaData, fieldName )
            if ~strcmp('', metaData.(fieldName))
                newString = metaData.(fieldName);
            else
                newString = sprintf('NO %s', fieldName);
            end
            hlabel(n).String = newString;
        else
            switch fieldName
                case 'dataSetPath'
                    hlabel(n).String = npath;
            end
        end

        
    
    setappdata(gcf, 'SelectedPathFF', npath);


end


