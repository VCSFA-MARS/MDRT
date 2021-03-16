classdef MDRTSearchWidget < handle
    %MDRTSearchWidget creates a GUI widget for searching a large list/array
    %with autocomplete options. Can be queried for value or index
    %   
    properties (Constant, Hidden = true)
        DEFAULT_PANELTITLE  = 'Search:';
        DEFAULT_SEARCH_TEXT = 'Enter search terms';
    end
    
    properties
        MasterArray
        MASearchColumn
        SearchBarTitle
        SearchBarDefaultText
        
    end
    
    properties (SetAccess = private)
        hContainer
        
%         hjContainer
%         hjSearchBar
%         hjSearchBarField
%         hjSearchBarIcon
        
        hjSearchButton
        hjSearchField
        jCombo
        jComboField
        
        hjComboBox
    end
    
    methods
        % Constructor - supports "DefaultMessage" and "PanelTitle"
        function self = MDRTSearchWidget(hContainer, MasterArray, MASearchColumn, varargin) 
           
           self.hContainer = hContainer;
           self.MasterArray = MasterArray;
           self.MASearchColumn = MASearchColumn;
            
           % Spawn in blank figure if no container is passed
           if isempty(hContainer)
               self.hContainer = figure;
           elseif isa(hContainer, 'matlab.ui.Figure') || isa(hContainer, 'matlab.ui.container.Panel')
               self.hContainer = hContainer;
           else
               try
                   self.hContainer = gcf;
               catch
                   warning('hContainer must be a figure or uipanel');
               end
           end
           
           if isempty(MasterArray)
               self.MasterArray = {''};
               self.MASearchColumn = 1;
           end
           
           if isempty(MASearchColumn)
               self.MASearchColumn = 1;
           end
           
           % Process Name/Value pairs
           if isempty(varargin)
               % Nothing passed, use defaults
                SearchBarTitle = self.DEFAULT_PANELTITLE;
                SearchBarDefaultText = self.DEFAULT_SEARCH_TEXT;
               
           elseif ~isempty(varargin) && ~mod(numel(varargin), 2)
               % Name/Value pairs present - otherwise user botched it
               
           else
               warningFormatStr = 'Name value parameters must be passed in pairs. User passed %n (odd number)';
               warning(sprintf( warningFormatStr, numel(varargin)))
           end
           
           % Find parent figure and set listener to clear this instance on
           % figure closure
           
           self.generateUIComponents
           
           
        end

        
        % Create UI controls: SearchBox, ComboBox, and container panel
        function this = generateUIComponents(this)
            
            
            callback = []; %{@searchComboUpdated,hContainer};  % set to [] to disable asset combo selection callback
            
            % createComboSelector( hParent, strings, callback, isEditable ) ----------
                strings = { 'All' };
                strings = this.MasterArray(:,this.MASearchColumn);
                
                hParent = this.hContainer;
                isEditable = true;
            % Note: MJComboBox is better than JComboBox: the popup panel has more width than the base control if needed
               jComboBox = com.mathworks.mwswing.MJComboBox(strings);  % =javax.swing.JComboBox(strings);
               jComboBox.setEditable(isEditable);
               jComboBox.setBackground(java.awt.Color.white); % unfortunately, this only affects editable combos
               [jhComboBox, hContainer1] = javacomponent(jComboBox, [], hParent);
               set(jhComboBox, 'ActionPerformedCallback', callback);
               hContainer1 = handle(hContainer1);
               set(hContainer1, 'tag','hAssetContainer', 'UserData',jComboBox);

            
            
            % shrink the popup selector (combo) that was just made!
                set(hContainer1, 'Units','pixels', 'Position',[1,1,2,2])
            
            % ---------------------------------------------------------------------
            
            
            % Create a SearchTextField control on top of the combo-box
                mwSearchField    = com.mathworks.widgets.SearchTextField(this.DEFAULT_SEARCH_TEXT); %jAssetChooser
                mwjpSearchField  = mwSearchField.getComponent;                                      %jAssetComponent
                [jSearchField, hSearchField] = javacomponent(mwjpSearchField,[],this.hContainer);
                hSearchField = handle(hSearchField);
                set(hSearchField, 'tag','MDRTSearchField', 'UserData',mwSearchField, 'Units','norm', 'Position',[0,0,1,1]);
                setappdata(this.hContainer,'mwSearchField',mwSearchField);

            % Expand the SearchTextField component to max available width
                jSize = java.awt.Dimension(9999, 20); % is 20 the height?
                mwjpSearchField.getComponent(0).setMaximumSize(jSize);
                mwjpSearchField.getComponent(0).setPreferredSize(jSize);

            
            % Add callback handlers
                this.hjSearchButton = handle(mwjpSearchField.getComponent(1), 'CallbackProperties');
                this.hjSearchField  = handle(mwjpSearchField.getComponent(0), 'CallbackProperties');
                this.jCombo         = handle(hContainer1.UserData, 'CallbackProperties');
                this.jComboField    = handle(this.jCombo.getComponent(2), 'CallbackProperties');
                                    
                set(this.hjSearchButton, 'MouseClickedCallback', {@updateSearch, this.jCombo, mwSearchField}); 
                set(this.hjSearchField,  'KeyPressedCallback',   {@updateSearch, this.jCombo, mwSearchField});
                set(this.jComboField,    'KeyPressedCallback',   {@updateSearch, this.jCombo, []});
                set(this.jCombo,         'FocusLostCallback',    @(h,e)jCombo.hidePopup);  % hide the popup when another component is selected

                this.hContainer.UserData = [this.jCombo, jSearchField, handle(mwSearchField)];
            
% this.hjSearchButton = hjSearchButton;
% this.hjSearchField  = hjSearchField;
% this.jCombo         = jCombo;
% this.jComboField    = jComboField;
                
                
            
        end
        
        
        
        
        
    end
    
end

function updateSearch(hObj, event, jCombo, jSearchField)
            
    keyboard

end

