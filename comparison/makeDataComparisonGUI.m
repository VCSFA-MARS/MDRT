function hs = makeDataComparisonGUI(varargin)

% Commented out - trying to create GUI inside a parent object

    if nargin == 0
        
        hs.fig = figure;
            guiSize = [672 387];
            hs.fig.Position = [hs.fig.Position(1:2) guiSize];
            hs.fig.Name = 'Data Comparison Plotter';
            hs.fig.NumberTitle = 'off';
            hs.fig.MenuBar = 'none';
            hs.fig.ToolBar = 'none';
            
    elseif nargin == 1
        hs.fig = varargin{1};
        
    end
    
    hs.fig.ResizeFcn = @doWindowResize;
    keyboard

        
    %% Debugging Tasks - variable loading, etc...
    
    % MDRTConfig is now a singleton handle class!
    config = MDRTConfig.getInstance;
    
    dataIndexName = 'dataIndex.mat';
    dataIndexPath = config.dataArchivePath;
    
    
    % Load the data index using the environment variable and the specified
    % filename.
    if exist(fullfile(dataIndexPath, dataIndexName), 'file')
        load(fullfile(dataIndexPath, dataIndexName) );
    else
        warning(['Data Repository Index file not found.' ,...
                 'Check MDRTdataRepositoryPath environment variable. ', ...
                 'Verify there is a ' dataIndexName ' file.']);
        return
    end
    
    debugout(dataIndex)
    
    setappdata(hs.fig, 'dataIndex', dataIndex);
    setappdata(hs.fig, 'topPlot', {} );
    setappdata(hs.fig, 'botPlot', {} );
    
    % TODO: appdata - how should I use this?
        % setappdata(mdrt, 'dataIndex', dataIndex);
    
%% Button Generation

    hs.button_graph =       uicontrol(hs.fig,...
            'String',       'Generate Plot',...
            'Callback',     @plotComparison,...
            'Tag',          'button',...
            'ToolTipString','Plot Data Comparison',...
            'Position',      [50 37 168 50]);
        
%% Panel Generation
    
    
    hs.eventPanel =         uipanel(hs.fig, ...
            'Title',        'Event Synchronization',...
             'Units',        'pixels', ...
            'Position',     [281 36 370 51]);
        
%% Listbox Generation - Maybe one day add drag/drop?
    % TODO: add doubleclick callback behavior to select/delete
        
    hs.listSearchResults =  uicontrol(hs.fig,...
            'Style',        'listbox',...
            'String',       {'FD-0001','FD-0002'},...
            'tag',          'listSearchResults',...
            'Position',     [50 97 169 140], ...
            'callback',     @fdListClickCallback);
        
    hs.listOp1FDs =         uicontrol(hs.fig,...
            'Style',        'listbox',...
            'String',       {},...
            'Position',     [281 97 170 140],...
            'callback',     @fdListClickCallback,...
            'tag',          'op1FDlist',...
            'min',          1,...
            'value',        1);
    
    hs.listOp2FDs =         uicontrol(hs.fig,...
            'Style',        'listbox',...
            'String',       {},...
            'Position',     [481 97 170 140],...
            'callback',     @fdListClickCallback,...
            'tag',          'op2FDlist',...
            'min',          1,...
            'value',        1);
        
%% Edit Box Generation
    % TODO: callback for search field
    
    hs.edit_searchField =   uicontrol(hs.fig,...
            'Style',        'edit',...
            'String',       '',...
            'HorizontalAlignment' , 'left',...
            'KeyReleaseFcn',@updateSearchResults,...
            'Position',     [50 265 168 22],...
            'tag',          'searchBox');
        
    hs.edit_plotTitle =     uicontrol(hs.fig,...
            'Style',        'edit',...
            'String',       'Plot Title',...
            'HorizontalAlignment' , 'left',...
            'Position',     [282 315 369 22],...
            'tag',          'plotTitle');
    
%% Popup Menu Generation
    
    hs.popup_dataSetMain =  uicontrol(hs.fig,...
            'Style',        'popupmenu',...
            'String',       {'A230 Stage Test','A230 WDR'},...
            'Position',     [50 310 168 27],...
            'Tag',          'selectDataList');

    hs.popup_dataSetOp1 =   uicontrol(hs.fig,...
            'Style',        'popupmenu',...
            'String',       {''},...
            'Position',     [281 260 170 27],...
            'Tag',          'opList1');    

    hs.popup_dataSetOp2 =   uicontrol(hs.fig,...
            'Style',        'popupmenu',...
            'String',       {'A230 Stage Test','A230 WDR'},...
            'Position',     [481 260 170 27],...
            'Tag',          'opList2'); 
        
        
%     hs.popup_dataSetOp1.Callback = {@updateDataSelectionPopup,hs.popup_dataSetMain, hs.popup_dataSetOp1, hs.popup_dataSetOp2, hs};
%     hs.popup_dataSetOp2.Callback = {@updateDataSelectionPopup,hs.popup_dataSetMain, hs.popup_dataSetOp1, hs.popup_dataSetOp2, hs};

    hs.popup_dataSetOp1.Callback = @updateDataSelectionPopup;
    hs.popup_dataSetOp2.Callback = @updateDataSelectionPopup;
    
    hs.popup_dataSetMain.Callback = @updateMatchingFDList;

%% Popup Menus for Event Synchronization 

%     hs.popup_eventSetOp1 =  uicontrol(hs.eventPanel,...
%             'Style',        'popupmenu',...
%             'String',       {'TEL Rapid Retract','T-0'},...
%             'Position',     [282 37 168 27]);
% 
%     hs.popup_eventSetOp2 =  uicontrol(hs.eventPanel,...
%             'Style',        'popupmenu',...
%             'String',       {'TEL Rapid Retract','T-0'},...
%             'Position',     [482 37 168 27]);
            
    hs.popup_eventSetOp1 =  uicontrol(hs.eventPanel,...
            'Style',        'popupmenu',...
            'String',       {'TEL Rapid Retract','T-0'},...
            'Units',        'normalized',...
            'Position',     [.05 .1 .4 .8],...
            'Tag',          'eventList1');

    hs.popup_eventSetOp2 =  uicontrol(hs.eventPanel,...
            'Style',        'popupmenu',...
            'String',       {'TEL Rapid Retract','T-0'},...
            'Units',        'normalized',...
            'Position',     [.55 .1 .4 .8],...
            'Tag',          'eventList2');
        
        
    % hs.popup_eventSetOp1.Callback = {@update

%% Text Label Generation

    position = {    [50 337 151 13];
                    [50 287 151 13];
                    [50 237 151 13];
                    [282 337 151 13];
                    [281 287 151 13];
                    [481 287 151 13] };

    string = {      'Select a data set.';
                    'Search FDs';
                    'Matching FDs';
                    'Comparison Plot Title';
                    'Data Set for Top Plot';
                    'Data Set for Bottom Plot' };
    labels = [];
    
    for i = 1:numel(position)
        t = uicontrol(	hs.fig,         'Style', 'text', ...
            'String',                   string(i), ...
            'HorizontalAlignment',      'left',...
            'Position',                 position{i} );
        t.Units = 'normalized';
        labels = vertcat(labels, t);
    end
    
    hLinkLabels = linkprop(labels, 'FontSize');

        
%% Set rescale behavior

    u = fieldnames(hs);
    for i = 1:numel(u)
        hs.(u{i}).Units = 'normalized';
    end

    hLinkUI = linkprop([hs.(u{2}), hs.(u{3})], 'FontSize');

    for i = 4:numel(u)
        hLinkUI.addtarget(hs.(u{i}))
    end


    defaultLabelFontSize = labels(1).FontSize;
    defaultEditFontSize  = hs.edit_plotTitle.FontSize;
    defaultWindowHeight  = hs.fig.Position(3);
        

%% Populate GUI with stuff from dataIndex

allDataSetNames = {};
matchingFDList = {};
op1eventList = {};
op2eventList = {};

for i = 1:numel(dataIndex)
    
    allDataSetNames = vertcat(allDataSetNames, ...
         makeDataSetTitleStringFromActiveConfig(dataIndex(i).metaData) );
    
    allDataSetNames = strtrim(allDataSetNames); 
    
end

debugout(allDataSetNames)

% Set appdata
    setappdata(hs.fig, 'dataSetNames', allDataSetNames)
    setappdata(hs.fig, 'fdMasterList', dataIndex(1).FDList(:,1));
    setappdata(hs.fig, 'targetOpFDList', hs.listOp1FDs);

% Populate Data Set selection popups    
    hs.popup_dataSetOp1.String = allDataSetNames;
    hs.popup_dataSetOp2.String = allDataSetNames;
    hs.popup_dataSetMain.String = allDataSetNames(1);
    
    
    updateMatchingFDList( hs.popup_dataSetMain, 1);



    updateDataSelectionPopup(hs.popup_dataSetOp1, []);
                        
% Populate fd list

    updateSearchResults(hs.edit_searchField);

    
    function doWindowResize(o, ~)
        defaultLabelFontSize;
        defaultEditFontSize;
        defaultWindowHeight;
                
        scaleFactor  = o.Position(3) / defaultWindowHeight;
        newLabelSize = round(defaultLabelFontSize * scaleFactor);
        newEditSize  = round(defaultEditFontSize * scaleFactor);
        
        hs.button_graph.FontSize = newEditSize;
        labels(1).FontSize = newLabelSize; 

        
    end

end




