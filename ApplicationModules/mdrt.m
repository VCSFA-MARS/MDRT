mainGui = uifigure;
    % guiSize = [672 387 + 25];
    % mainGui.Position = [mainGui.Position(1:2) guiSize];
    mainGui.Name = 'Data Comparison Plotter';
    mainGui.NumberTitle = 'off';
    mainGui.MenuBar = 'none';
    mainGui.ToolBar = 'none';
        
mainGuiGrid = uigridlayout(mainGui, [1 1]);
        
tgroup = uitabgroup('Parent', mainGuiGrid);
tab1 = uitab('Parent', tgroup, 'Title', 'Data Viewer');
tab1a = uitab('Parent', tgroup, 'Title', 'Axes Setup');
tab2 = uitab('Parent', tgroup, 'Title', 'Import Data');
tab3 = uitab('Parent', tgroup, 'Title', 'Archive Manager');
tab4 = uitab('Parent', tgroup, 'Title', 'Comparison Tool');
tab5 = uitab('Parent', tgroup, 'Title', 'Settings');


setTimeAxesLimits( tab1a );
dataImportGUI( tab2 );
ArchiveManagerGUI( Parent=tab3 );
% makeDataComparisonGUI( tab4 );
SettingsGUI( tab5 );

