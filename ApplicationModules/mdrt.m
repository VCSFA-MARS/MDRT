mainGui = figure;
    guiSize = [672 387 + 25];
    mainGui.Position = [mainGui.Position(1:2) guiSize];
    mainGui.Name = 'Data Comparison Plotter';
    mainGui.NumberTitle = 'off';
    mainGui.MenuBar = 'none';
    mainGui.ToolBar = 'none';
        
        
        
tgroup = uitabgroup('Parent', mainGui);
tab1 = uitab('Parent', tgroup, 'Title', 'Data Viewer');
tab1a = uitab('Parent', tgroup, 'Title', 'Axes Setup');
tab2 = uitab('Parent', tgroup, 'Title', 'Import Data');
tab3 = uitab('Parent', tgroup, 'Title', 'Archive Manager');
tab4 = uitab('Parent', tgroup, 'Title', 'Comparison Tool');
tab5 = uitab('Parent', tgroup, 'Title', 'Settings');


setTimeAxesLimits( tab1a );
makeDataImportGUI( tab2 );
makeArchiveManagerGUI( tab3 );
makeDataComparisonGUI( tab4 );
makeSettingsGUI( tab5 );

