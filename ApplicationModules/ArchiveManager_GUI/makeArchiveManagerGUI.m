function hs = makeArchiveManagerGUI( varargin )
% %makeArchiveManagerGUI creates the MARS DRT archive management panel.
%
% Called by itself, it generates a stand-alone gui.
% Pass a handle to a parent object, and the settings panel will populate
% the parent object.
%
% makeArchiveManagerGUI returns a handle structure
%
% Counts, 2016 VCSFA
%

Config = MDRTConfig.getInstance;

figureName = 'Archive Manager GUI';
overrideWindowDelete = true;
start_tree_hidden = false;
child_objects = [];

if nargin == 0
    % Run as standalone GUI for testing
    % Run as standalone GUI for testing

    hs.fig = figure;
        guiSize = [672 387];
        hs.fig.Position = [hs.fig.Position(1:2) guiSize];
        hs.fig.Name = figureName;
        hs.fig.NumberTitle = 'off';
        hs.fig.MenuBar = 'none';
        hs.fig.ToolBar = 'none';
        hs.fig.Tag = 'archiveManagerFigure';
        
        if overrideWindowDelete
            hs.fig.DeleteFcn = @windowCloseCleanup;
        end

elseif nargin == 1
    % Populate a UI container
    
    hs.fig = varargin{1};
    start_tree_hidden = true;
    
end



%% 
setappdata(hs.fig, 'SelectedDataSet', []);

config = MDRTConfig.getInstance;


%% Archive UITree Generation

hs.panel_tree = uipanel( hs.fig, ...
                        'Units',        'normalized', ...
                        'Position',     [0.01 0.01 0.45 0.9], ...
                        'Title',        'Archive Folders', ...
                        'Tag',          'am_panel_tree' );

[ltree, lcontainer]  = uitree('v0', 'Root', config.dataArchivePath, ... 
                             'Parent',       hs.panel_tree, ...
                             'SelectionChangeFcn',    @nodeSelected ...
                             );
                   
[rtree, rcontainer]  = uitree('v0', 'Root', config.remoteArchivePath, ... 
                             'Parent',       hs.panel_tree, ...
                             'SelectionChangeFcn',    @nodeSelected ...
                             );

set(lcontainer, 'Parent', hs.panel_tree, 'Units', 'Normalized', 'Position', [0.05, 0.05, 0.9, 0.9] );
set(rcontainer, 'Parent', hs.panel_tree, 'Units', 'Normalized', 'Position', [0.05, 0.05, 0.9, 0.9] );
                         
                         
rcontainer.Visible  = 'off';

% if start_tree_hidden
%     rcontainer.Visible = 'off';
%     lcontainer.Visible = 'off';
% end

% Expand the roots!!!
ltree.expand(ltree.Root);
rtree.expand(rtree.Root);


setappdata(hs.fig, 'ltree', ltree);
setappdata(hs.fig, 'rtree', rtree);
setappdata(hs.fig, 'lcontainer', lcontainer);
setappdata(hs.fig, 'rcontainer', rcontainer);

setappdata(hs.fig, 'selectedRootPath', config.dataArchivePath);
setappdata(hs.fig, 'indexFilePath',    config.dataArchivePath);
setappdata(hs.fig, 'isRemoteArchive', false);


%% Archive Information Labels

                % MetaData field        Default Text    Position
liveStrings = { 'operationName',        'OP name',      [0.47, 0.6, 0.5, 0.1] ;
                'MARSprocedureName',    'MARS name',    [0.47, 0.5, 0.5, 0.1] ;
                'MARSUID',              'Schedule UID', [0.47, 0.4, 0.5, 0.1] ;
                'dataSetPath',          'Folder Path',  [0.47, 0.3, 0.5, 0.1] };

            
hlabel = gobjects(length(liveStrings),1);

for n = 1:length(liveStrings)
    hlabel(n) = uicontrol(hs.fig, ...
                   'style',                     'text', ...
                   'units',                     'normalized', ...
                   'position',                  liveStrings{n,3}, ...
                   'String',                    liveStrings{n,2}, ...
                   'Tag',                       liveStrings{n,1}, ...
                   'horizontalalignment',       'left');
end

setappdata(hs.fig, 'hlabel', hlabel);
setappdata(hs.fig, 'liveStrings', liveStrings);
            
               
%% Button Controls               
               
hs.check_saveBackup      = uicontrol(hs.fig, ...
        'style',            'checkbox',...
        'Units',            'normalized', ...
        'Position',         [0.3000    0.9100    0.2976    0.07750], ...
        'String',           'Automatically Save Data Index', ...
        'Tag',              'SaveBackupIndex', ...
        'Value',            1);
    
    hs.check_saveBackup.Units = 'normalized';
    hs.check_saveBackup.Position(1:2) = [0.3, 0.91];               

hs.button_indexAllFolders = uicontrol(hs.fig, ...
        'style',            'pushbutton', ...
        'Units',            'normalized', ...
        'Position',         [0.0500    0.9100    0.2232    0.0775], ...
        'String',           'Index All Folders', ...
        'FontUnits',        'normalized', ...
        'FontSize',         0.3226, ...
        'Tag',              'IndexAllFoldersButton', ...
        'Callback',         @(hobj,event)updateDataArchiveIndex( ...
                                getappdata(gcf, 'selectedRootPath'), ...
                                ~hs.check_saveBackup.Value*2, ...
                                getappdata(gcf, 'isRemoteArchive')) ...
        );
    
    hs.button_indexAllFolders.Units = 'normalized';
    hs.button_indexAllFolders.Position(1:2) = [0.05, 0.91];
    

    
hs.button_fixSelectedSet = uicontrol(hs.fig, ...
        'style',            'pushbutton', ...
        'Units',            'normalized', ...
        'Position',         [0.75   0.05   0.225   0.0775], ...
        'FontUnits',        'normalized', ...
        'FontSize',         0.3333, ...
        'String',           'Fix Selected Data Set', ...
        'Tag',              'FixSelectedSetButton', ...
        'Callback',         @(hobj,event)updateRepositoryDataSet( ...
                                getappdata(gcf, 'SelectedPathFF'), ...
                                getappdata(gcf, 'indexFilePath') ) ...
        );

    
%% Archive Selection Controls
    
hs.bg = uibuttongroup('Visible',    'on',...
        'Parent',           hs.fig, ...
        'Title',            'Archive Selection', ...
        'Position',         [0.6000 0.8000 0.3750 0.2000], ...
        'SelectionChangedFcn',  @archiveButtonSelected);

hs.r1 = uicontrol(hs.bg,'Style',   'radiobutton', ...
        'String',               'Local Archive', ...
        'Tag',                  'rb_local', ...
        'Units',                'normalized', ...
        'Position',             [0.1000 0.1000 0.4000 0.9000], ...
        'HandleVisibility',     'off');    
    
hs.r2 = uicontrol(hs.bg,'Style',   'radiobutton', ...
        'String',               'Remote Archive', ...
        'Tag',                  'rb_remote', ...
        'Units',                'normalized', ...
        'Position',             [0.5000 0.1000 0.4000 0.9000], ...
        'HandleVisibility',     'off');



    
    
    function windowCloseCleanup(varargin)
        % cleans up any spawned objects registered in child_objects

        debugout('Closing window')
        for i = 1:numel(child_objects)
            delete(child_objects(i))
        end

    end
end