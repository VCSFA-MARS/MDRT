function hs = makeRetrievalGUI(varargin)

% Commented out - trying to create GUI inside a parent object

    if nargin == 0
        
        hs.fig = figure;
            guiSize = [672 387];
            hs.fig.Position = [hs.fig.Position(1:2) guiSize];
            hs.fig.Name = 'Data Retrieval Tool';
            hs.fig.NumberTitle = 'off';
            hs.fig.MenuBar = 'none';
            hs.fig.ToolBar = 'none';
            
    elseif nargin == 1
        hs.fig = varargin{1};
        
    end
    
%     hs.fig.ResizeFcn = @doWindowResize;
    

        

    
%% Button Generation

    hs.button_graph =       uicontrol(hs.fig,...
            'String',       'Generate Plot',...
            'Callback',     @plotComparison,...
            'Tag',          'button',...
            'ToolTipString','Plot Data Comparison',...
            'Position',      [50 37 168 50]);
        

        
%% Listbox Generation - Maybe one day add drag/drop?
    % TODO: add doubleclick callback behavior to select/delete
        
    hs.listSearchResults =  uicontrol(hs.fig,...
            'Style',        'listbox',...
            'String',       {'FD-0001','FD-0002'},...
            'tag',          'listSearchResults',...
            'Position',     [50 97 251 140], ...
            'callback',     @fdListClickCallback);
        
    hs.listSelectedFDs =    uicontrol(hs.fig,...
            'Style',        'listbox',...
            'String',       {},...
            'Position',     [350 97 251 140],...
            'callback',     @fdListClickCallback,...
            'tag',          'op1FDlist',...
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
        

    




%% Text Label Generation

    position = {    [50 287 151 13];
                    [50 237 151 13];
                    [282 337 151 13];
                    [481 287 151 13] };

    string = {      'Search FDs';
                    'Matching FDs';
                    'Comparison Plot Title';
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

%     u = fieldnames(hs);
%     for i = 1:numel(u)
%         hs.(u{i}).Units = 'normalized';
%     end
% 
%     hLinkUI = linkprop([hs.(u{2}), hs.(u{3})], 'FontSize');
% 
%     for i = 4:numel(u)
%         hLinkUI.addtarget(hs.(u{i}))
%     end
% 
% 
%     defaultLabelFontSize = labels(1).FontSize;
%     defaultEditFontSize  = hs.edit_plotTitle.FontSize;
%     defaultWindowHeight  = hs.fig.Position(3);
%         

%% Populate GUI with stuff from dataIndex

TAMFDs = getTAMcontents([]);

% Set appdata
    setappdata(hs.fig, 'fdMasterList',      TAMFDs.FD);
    setappdata(hs.fig, 'TAMFDs',            TAMFDs);
    setappdata(hs.fig, 'targetOpFDList',    hs.listSelectedFDs);
                        
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




