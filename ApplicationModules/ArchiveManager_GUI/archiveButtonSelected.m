function  archiveButtonSelected( hobj, event )
%archiveButtonSelected Summary of this function goes here
%   Detailed explanation goes here
   
    config = MDRTConfig.getInstance;
    
    ad = getappdata(hobj.Parent);
    
    switch event.OldValue.Tag
        case 'rb_local'
            ad.lcontainer.Visible = 'off';
            
            ad.ltree.SelectedNodes = [];
            %ad.rtree.SelectedNodes = [];
        case 'rb_remote'
            ad.rcontainer.Visible = 'off';
            
            ad.rtree.SelectedNodes = [];
            %ad.ltree.SelectedNodes = [];
            
    end
    
    switch event.NewValue.Tag
        case 'rb_local'
            ad.lcontainer.Visible = 'on';
            ad.ltree.SelectedNodes = [];
            
            setappdata(hobj.Parent, 'isRemoteArchive', false);
            setappdata(hobj.Parent, 'selectedRootPath', config.dataArchivePath);
            setappdata(hobj.Parent, 'indexFilePath',    config.dataArchivePath);
            
            debugout(sprintf('Set %s to %d', 'isRemoteArchive',    false))
            debugout(sprintf('Set %s to %s', 'selectedRootPath',   config.dataArchivePath))
            debugout(sprintf('Set %s to %s', 'indexFilePath',      config.dataArchivePath))
            
        case 'rb_remote'
            ad.rcontainer.Visible = 'on';
            ad.rtree.SelectedNodes = [];
            
            setappdata(hobj.Parent, 'isRemoteArchive', true);
            setappdata(hobj.Parent, 'selectedRootPath', config.remoteArchivePath);
            setappdata(hobj.Parent, 'indexFilePath', config.pathToConfig);
            
            debugout(sprintf('Set %s to %d', 'isRemoteArchive',    true))
            debugout(sprintf('Set %s to %s', 'selectedRootPath', 	config.remoteArchivePath))
            debugout(sprintf('Set %s to %s', 'indexFilePath',      config.pathToConfig))
            
    end

    
end

