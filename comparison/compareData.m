

%% Debugging Tasks - variable loading, etc...

    load('dataIndex.mat');
    
    % TODO: appdata - how should I use this?
        % setappdata(mdrt, 'dataIndex', dataIndex);

%% Figure Creation (is this needed if called as a UI component?)

    hs.fig = figure;
        guiSize = [672 387];
        hs.fig.Position = [hs.fig.Position(1:2) guiSize];
        hs.fig.Name = 'Data Comparison Plotter';
        hs.fig.NumberTitle = 'off';
        hs.fig.MenuBar = 'none';
        hs.fig.ToolBar = 'none';
    
%% Button Generation

    hs.button_graph =       uicontrol(hs.fig,...
            'String',       'Generate Plot',...
            'Callback',     @runCalculations,...
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
            'String',       'Op 1 FDs Here',...
            'Position',     [281 97 170 140]);
    
    hs.listOp2FDs =         uicontrol(hs.fig,...
            'Style',        'listbox',...
            'String',       'Op 2 FDs Here',...
            'Position',     [481 97 170 140]);
        
%% Edit Box Generation
    % TODO: callback for search field
    
    hs.edit_searchField =   uicontrol(hs.fig,...
            'Style',        'edit',...
            'String',       '',...
            'HorizontalAlignment' , 'left',...
            'KeyReleaseFcn',@updateSearchResults,...
            'Position',     [50 265 168 22]);
        
    hs.edit_plotTitle =     uicontrol(hs.fig,...
            'Style',        'edit',...
            'String',       'Plot Title',...
            'HorizontalAlignment' , 'left',...
            'Position',     [282 315 369 22]);
    
%% Popup Menu Generation
    
    hs.popup_dataSetMain =  uicontrol(hs.fig,...
            'Style',        'popupmenu',...
            'String',       {'A230 Stage Test','A230 WDR'},...
            'Position',     [50 310 168 27]);

    hs.popup_dataSetOp1 =   uicontrol(hs.fig,...
            'Style',        'popupmenu',...
            'String',       {'A230 Stage Test','A230 WDR'},...
            'Position',     [281 260 170 27]);    

    hs.popup_dataSetOp2 =   uicontrol(hs.fig,...
            'Style',        'popupmenu',...
            'String',       {'A230 Stage Test','A230 WDR'},...
            'Position',     [481 260 170 27]); 

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
            'Position',     [.05 .1 .4 .8]);

    hs.popup_eventSetOp2 =  uicontrol(hs.eventPanel,...
            'Style',        'popupmenu',...
            'String',       {'TEL Rapid Retract','T-0'},...
            'Units',        'normalized',...
            'Position',     [.55 .1 .4 .8]);

%% Text Label Generation
    
    uicontrol(hs.fig,       'Style','text',...
            'String',       'Select a data set.',...
            'HorizontalAlignment',    'left',...
            'Position',     [50 337 151 13]);
        
    uicontrol(hs.fig,       'Style','text',...
            'String',       'Search FDs',...
            'HorizontalAlignment',    'left',...
            'Position',     [50 287 151 13]);
    
    uicontrol(hs.fig,       'Style','text',...
            'String',       'Matching FDs',...
            'HorizontalAlignment',    'left',...
            'Position',     [50 237 151 13]);

    uicontrol(hs.fig,       'Style','text',...
            'String',       'Comparison Plot Title',...
            'HorizontalAlignment',    'left',...
            'Position',     [282 337 151 13]);
        
    uicontrol(hs.fig,       'Style','text',...
            'String',       'Data Set for Top Plot',...
            'HorizontalAlignment',    'left',...
            'Position',     [281 287 151 13]);
        
    uicontrol(hs.fig,       'Style','text',...
            'String',       'Data Set for Bottom Plot',...
            'HorizontalAlignment',    'left',...
            'Position',     [481 287 151 13]);

        

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


hs.popup_dataSetMain.String = allDataSetNames;
hs.popup_dataSetOp1.String = allDataSetNames;
hs.popup_dataSetOp2.String = allDataSetNames;

hs.listSearchResults.String = dataIndex(1).FDList(:,1);
setappdata(hs.fig, 'fdMasterList', dataIndex(1).FDList(:,1));
setappdata(hs.fig, 'searchBoxString', hs.edit_searchField.String);

