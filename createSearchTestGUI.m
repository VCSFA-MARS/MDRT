function createSearchTestGUI()
   handles.fig = figure;
   handles.hAssetSearchPanel = uipanel('Position', [0.1, 0.8, 0.8, 0.1]);
   handles.cbAssetSearch = createAssetSelector(handles.hAssetSearchPanel);
   ...
end
 
% Create the asset-name selector control within a parent container (panel/figure/tab/...)
function hContainer = createAssetSelector(hParent)
    % Create a uipanel to hold both sub-components below, one occluding the other:
    hContainer = handle(uipanel('BorderType','none', 'Parent',hParent));
 
    % Create a standard editable combo-box (drop-down) control
    callback = {@searchComboUpdated,hContainer};  % set to [] to disable asset combo selection callback
    hContainer1 = createComboSelector(hContainer, {'All'}, callback, true);
    set(hContainer1, 'Units','pixels', 'Position',[1,1,2,2]);
 
    % Create a SearchTextField control on top of the combo-box
    jAssetChooser = com.mathworks.widgets.SearchTextField('Select FD:');
    jAssetComponent = jAssetChooser.getComponent;
    [jhAssetComponent, hContainer2] = javacomponent(jAssetComponent,[],hContainer);
    hContainer2 = handle(hContainer2);
    set(hContainer2, 'tag','hAssetContainer', 'UserData',jAssetChooser, 'Units','norm', 'Position',[0,0,1,1]);
    setappdata(hContainer,'jAssetChooser',jAssetChooser);
 
    % Expand the SearchTextField component to max available width
    jSize = java.awt.Dimension(9999, 20);
    jAssetComponent.getComponent(0).setMaximumSize(jSize);
    jAssetComponent.getComponent(0).setPreferredSize(jSize);
 
    jCombo = handle(hContainer1.UserData, 'CallbackProperties');
    jComboField = handle(jCombo.getComponent(2), 'CallbackProperties');
    set(jComboField, 'KeyPressedCallback', {@updateSearch,jCombo,[]});
    set(jCombo, 'FocusLostCallback', @(h,e)jCombo.hidePopup);  
    
    % hide the popup when another component is selected% Add callback handlers
    hjSearchButton = handle(jAssetComponent.getComponent(1), 'CallbackProperties');
    set(hjSearchButton, 'MouseClickedCallback', {@updateSearch,jCombo,jAssetChooser});
 
    hjSearchField = handle(jAssetComponent.getComponent(0), 'CallbackProperties');
    set(hjSearchField, 'KeyPressedCallback', {@updateSearch,jCombo,jAssetChooser});
 
    
 
    % Return the containing panel handle
    hContainer.UserData = [jCombo, jhAssetComponent, handle(jAssetChooser)];
end  % createAssetSelector
 
function hContainer = createComboSelector(hParent, strings, callback, isEditable)
   % Note: MJComboBox is better than JComboBox: the popup panel has more width than the base control if needed
   jComboBox = com.mathworks.mwswing.MJComboBox(strings);  % =javax.swing.JComboBox(strings);
   jComboBox.setEditable(isEditable);
   jComboBox.setBackground(java.awt.Color.white); % unfortunately, this only affects editable combos
   [jhComboBox, hContainer] = javacomponent(jComboBox, [], hParent);
   set(jhComboBox, 'ActionPerformedCallback', callback);
   hContainer = handle(hContainer);
   set(hContainer, 'tag','hAssetContainer', 'UserData',jComboBox);
end

% Callback function for the asset selector combo
function searchComboUpdated(jCombo, eventData, hPanel)
    selectedItem = regexprep(char(jCombo.getSelectedItem),'<[^>]*>','');  % strip away HTML tags
    jSearchTextField = hPanel.UserData(2).getComponent(0);
    jSearchTextField.setText(selectedItem);
    jSearchTextField.repaint; drawnow; pause(0.01);
    jAssetChooser = getappdata(hPanel,'jAssetChooser');
    updateSearch([],[],jCombo,jAssetChooser);
end  % searchComboUpdated



% Asset search popup combo button click callback
function updateSearch(hObject, eventData, jCombo, jAssetChooser) %#ok<INUSL>
    persistent lastSearchText
    if isempty(lastSearchText),  lastSearchText = '';  end
 
    try
        % event occurred on the search field component
        try
            searchText = jAssetChooser.getSearchText;
            jSearchTextField = jAssetChooser.getComponent.getComponent(0);
        catch
            % Came via asset change - always update
            jSearchTextField = jAssetChooser.getComponent(0);
            searchText = jSearchTextField.getText;
            lastSearchText = '!@#$';
        end
    catch
        try
            % event occurred on the jCombo-box itself
            searchText = jCombo.getSelectedItem;
        catch
            % event occurred on the internal edit-field sub-component
            searchText = jCombo.getText;
            jCombo = jCombo.getParent;
        end
        jSearchTextField = jCombo.getComponent(jCombo.getComponentCount-1);
    end
    searchText = strrep(char(searchText), '*', '.*');  % turn into a valid regexp
    searchText = regexprep(searchText, '<[^>]+>', '');
    if strcmpi(searchText, lastSearchText) && ~isempty(searchText)
        jCombo.showPopup;
        return;  % maybe just clicked an arrow key or Home/End - no need to refresh the popup panel
    end
    lastSearchText = searchText;
 
    assetClassIdx = getappdata(handles.cbAssetClass, 'assetClassIdx');
    if isempty(assetClassIdx)
        jCombo.hidePopup;
        return;
    elseif isempty(searchText)
        assetNamesIdx = assetClassIdx;
    else
        searchComponents = strsplit(searchText, ' - ');
        assetCodeIdx = ~cellfun('isempty',regexpi(data.header.AssetCode(assetClassIdx),searchComponents{1}));
        assetNameIdx = ~cellfun('isempty',regexpi(data.header.AssetName(assetClassIdx),searchComponents{end}));
        if numel(searchComponents) > 1
            assetNamesIdx = assetClassIdx(assetCodeIdx & assetNameIdx);
        else
            assetNamesIdx = assetClassIdx(assetCodeIdx | assetNameIdx);
        end
    end
    setappdata(handles.cbAssetSearch, 'assetNameIdx', assetNamesIdx);
    if isempty(assetNamesIdx)
        jCombo.hidePopup;
        jSearchTextField.setBackground(java.awt.Color.yellow);
        jSearchTextField.setForeground(java.awt.Color.red);
        newFont = jSearchTextField.getFont.deriveFont(uint8(java.awt.Font.BOLD));
        jSearchTextField.setFont(newFont);
        return;
    else
        jSearchTextField.setBackground(java.awt.Color.white);
        jSearchTextField.setForeground(java.awt.Color.black);
        newFont = jSearchTextField.getFont.deriveFont(uint8(java.awt.Font.PLAIN));
        jSearchTextField.setFont(newFont);
    end
 
    % Compute the filtered asset names (highlight the selected search term)
    assetNames = strcat(data.header.AssetCode(assetNamesIdx), ' -=', data.header.AssetName(assetNamesIdx));
    assetNames = regexprep(assetNames, '(.+) -=\1', '$1', 'ignorecase');
    assetNames = unique(strrep(assetNames, ' -=', ' - '));
    if ~isempty(searchText)
        assetNames = regexprep(assetNames, ['(' searchText ')'], '<b><font color=blue>$1</font></b>', 'ignorecase');
        assetNames = strcat('<html>', assetNames);
    end
 
    % Redisplay the updated combo-box popup panel
    jCombo.setModel(javax.swing.DefaultComboBoxModel(assetNames));
    jCombo.showPopup;
end  % updateSearch












