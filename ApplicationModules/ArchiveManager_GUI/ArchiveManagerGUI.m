function hs = ArchiveManagerGUI(options)
    arguments
        options.Parent (1,1) = [];
    end


%% Constants / Global
FOLDER_ICON = 'folder-16x16.png';
FOLDER_GOOD = 'folder-good-16x16.png';
config = MDRTConfig.getInstance;
model = struct();
model.loaded_metadata = [];
model.gui_metadata = newMetaDataStructure();
model.auto_save = true;


%% Init Figure

if isempty(options.Parent)
 
    hs = struct();
    hs.fig = uifigure();
        hs.fig.Name = 'Archive Manager GUI';
        hs.fig.NumberTitle = 'off';
        hs.fig.MenuBar = 'none';
        hs.fig.ToolBar = 'none';
        hs.fig.Tag = 'archiveManagerFigure';

else
    hs.fig = options.Parent;
end

hs.fig_grid = uigridlayout(hs.fig, [1,2]);


    


%% Archive Tree Layout and Controls:
hs.arch_grid = uigridlayout(hs.fig_grid, [3,1]);
hs.arch_grid.RowHeight = {'fit', 'fit', '1x'};
hs.check_saveBackup = uicheckbox(hs.arch_grid, "Text",'Automatically Save Data Index', 'Value', model.auto_save);
hs.button_indexAllFolders = uibutton(hs.arch_grid, 'Text','Index All Folders', 'ButtonPushedFcn', @index_all_folders);


%% Generate Folder Tree

hs.tabs = uitabgroup(hs.arch_grid, 'SelectionChangedFcn', @populate_tab_tree);
hs.tab_arch = uitab(hs.tabs, 'Title', 'Archive', 'UserData', config.dataArchivePath);
hs.tab_impt = uitab(hs.tabs, 'Title', 'Import', 'UserData', config.importDataPath);
hs.visible_tab_grid = uigridlayout(hs.tabs.SelectedTab, [1,1]);

populate_tab_tree();


%% Right-hand Controls and MetaData
hs.right_grid = uigridlayout(hs.fig_grid, [4,1]);
hs.right_grid.RowHeight = {'fit', 'fit', 'fit', '1x'}

hs.meta_pane = uipanel(hs.right_grid, 'Title', 'Meta Data');
hs.meta_grid = uigridlayout(hs.meta_pane, [8,1]);

% Operation flag and title
hs.check_is_op = uicheckbox(hs.meta_grid, 'text', 'Operation', 'ValueChangedFcn', @checkbox_callback);
hs.edit_op_name = uieditfield(hs.meta_grid, 'Enable', 'off');
hs.check_is_op.UserData = hs.edit_op_name; % set enable target

% MARS Procedure flag and title
hs.check_is_mars_proc = uicheckbox(hs.meta_grid, 'text', 'Procedure', 'ValueChangedFcn', @checkbox_callback);
hs.edit_proc_name = uieditfield(hs.meta_grid, 'Enable', 'off');
hs.check_is_mars_proc.UserData = hs.edit_proc_name; % set enable target

% MARS UID flag and title
hs.check_has_uid = uicheckbox(hs.meta_grid, 'Text', 'MARS UID', 'ValueChangedFcn', @checkbox_callback);
hs.edit_mars_uid = uieditfield(hs.meta_grid, 'Enable', 'off');
hs.check_has_uid.UserData = hs.edit_mars_uid; % set enable target

% Vehicle support flag
hs.check_is_vehicle = uicheckbox(hs.meta_grid, 'Text', 'Vehicle Support');

% Non-editable metadata (timehacks, lists, etc?)


% Save and Reset Controls
hs.meta_button_grid = uigridlayout(hs.meta_grid, [1 2]);
hs.button_meta_save = uibutton(hs.meta_button_grid, 'Text', 'Write Metadata', 'ButtonPushedFcn',@save_metadata);
hs.button_meta_reset = uibutton(hs.meta_button_grid, 'Text', 'Reset Metadata', 'ButtonPushedFcn',@update_gui_from_metadata);

row_height = repmat({'fit'}, ...
    numel(hs.meta_grid.RowHeight), ...
    numel(hs.meta_grid.ColumnWidth));

hs.meta_grid.RowHeight = row_height;


%% Major Buttons

hs.button_convertSelectedSet = uibutton(hs.right_grid, 'Text', 'Convert Data Files to v2');
hs.button_fixSelectedSet = uibutton(hs.right_grid, 'Text', 'Fix Selected Data Set');



%% Supporting Functions


    function update_metadata_on_selection(hobj, event)
        set(event.PreviousSelectedNodes, 'Icon', FOLDER_ICON);
        set(event.SelectedNodes, 'Icon', FOLDER_GOOD);
        
        node_path = event.SelectedNodes.NodeData; % the full path to the data set folder
        debugout(node_path)
    
        metaDataFile = fullfile(node_path, 'data', 'metadata.mat');

        if exist(metaDataFile, 'file')
            load(metaDataFile);
            debugout(metaData);
            setappdata(hobj.Parent, 'loaded_metadata', metaData);
        else
            % No metadata file found!
            tempMD = newMetaDataStructure;
            tempMD.timeSpan = [ now - 1, now ];
            tempMD.MARSprocedureName = 'NO METADATA FOUND';
            tempMD.fdList = {'NO METADATA', 'NO METADATA'};
            metaData = tempMD;
            setappdata(hobj.Parent, 'metadata', metaData);
        end
        
        fields = fieldnames(metaData);
        for i = 1:numel(fields)
            field = fields{i};
            model.loaded_metadata.(field) = metaData.(field);
            % TODO: Add code to clear out fields not loaded from disk?
        end

        update_gui_from_metadata();
    end



    function update_gui_from_metadata(~, ~)
        hs.check_is_op.Value = model.loaded_metadata.isOperation;
        hs.check_is_mars_proc.Value = model.loaded_metadata.isMARSprocedure;
        hs.check_has_uid.Value = model.loaded_metadata.hasMARSuid;
        hs.check_is_vehicle.Value = model.loaded_metadata.isVehicleOp;

        hs.edit_op_name.Value = model.loaded_metadata.operationName;
        hs.edit_proc_name.Value = model.loaded_metadata.MARSprocedureName;
        hs.edit_mars_uid.Value = model.loaded_metadata.MARSUID;

        update_gui_from_checkboxes()
    end

    function checkbox_callback(hobj, event)
        if ~isempty(hobj.UserData)
            if hobj.Value
                hobj.UserData.Enable = "on";
            else
                hobj.UserData.Enable = "off";
            end
        end
    end

    function update_gui_from_checkboxes()
        cbs = [
            hs.check_is_op;
            hs.check_is_mars_proc;
            hs.check_has_uid;
        ];

        for i = 1:numel(cbs)
            cb = cbs(i);
            tgt = cb.UserData;

            if cb.Value
                tgt.Enable = 'on';
            else
                tgt.Enable = 'off';
            end
        end
    end

    function update_model_from_gui(~,~)
        
        % Operation Flag and Name
        model.loaded_metadata.isOperation = hs.check_is_op.Value;
        if model.loaded_metadata.isOperation
            model.loaded_metadata.operationName = hs.edit_op_name.Value;
        else
            model.loaded_metadata.operationName = '';
        end

        % Procedure Flag and Name
        model.loaded_metadata.isMARSprocedure = hs.check_is_mars_proc.Value;
        if model.loaded_metadata.isMARSprocedure
            model.loaded_metadata.MARSprocedureName = hs.edit_proc_name.Value;
        else
            model.loaded_metadata.MARSprocedureName = '';
        end

        % MARS UID Flag and Name
        model.loaded_metadata.hasMARSuid = hs.check_has_uid.Value;
        if model.loaded_metadata.hasMARSuid
            model.loaded_metadata.MARSUID = hs.edit_mars_uid.Value;
        else
            model.loaded_metadata.MARSUID = '';
        end

        % Vehicle Support Flag
        model.loaded_metadata.isVehicleOp = hs.check_is_vehicle.Value;

    end

    function save_metadata(~,~)
        debugout(model.loaded_metadata)
        update_model_from_gui();
        node_path = hs.tree.SelectedNodes.NodeData;
        metaDataFile = fullfile(node_path, 'data', 'metadata.mat');


    end

    function index_all_folders(~,~)
        % remote archive not implemented
        isRemote = false;

        updateDataArchiveIndex( ...
            hs.rootNode.NodeData, ...
            ~hs.check_saveBackup.Value*2, ...
            isRemote ...
        );
    end

    function populate_tab_tree(~, ~)
        hs.visible_tab_grid.Parent = hs.tabs.SelectedTab;
        if isfield(hs, 'tree')
            hs.tree.delete
        end
        

        hs.tree = uitree(hs.visible_tab_grid, 'SelectionChangedFcn', @update_metadata_on_selection);
        hs.rootNode = uitreenode(hs.tree, 'Text', hs.tabs.SelectedTab.UserData, 'NodeData', hs.tabs.SelectedTab.UserData);

        D = dir(hs.tabs.SelectedTab.UserData);
        dir_mask = [D.isdir] == true;
        DIRS = D(dir_mask);

        for i = 1:length(DIRS)
            this_dir = DIRS(i);
            if this_dir.name(1) == '.'
                % skip hidden and . or ..
                continue
            end
            uitreenode(hs.rootNode, 'Text', this_dir.name, 'Icon',FOLDER_ICON, 'NodeData', fullfile(hs.tabs.SelectedTab.UserData, this_dir.name));
        end

        hs.rootNode.expand()
    end
end