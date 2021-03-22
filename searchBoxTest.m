function searchBoxTest()

handles.fig = figure;
handles.hPanel = uipanel('title', 'Search:', 'Position', [0.1 0.7 0.8 0.1]);


% Create a panel that fills the container - it will hold the two components
hContainer = handle(uipanel('BorderType','none', 'Parent',handles.hPanel))

% Create a standard editable combo-box (drop-down) control
callback = []; %{@searchComboUpdated,hContainer};  % set to [] to disable asset combo selection callback

% createComboSelector( hParent, strings, callback, isEditable ) ----------
    strings = { 'All' };
    hParent = hContainer;
    isEditable = true;
% Note: MJComboBox is better than JComboBox: the popup panel has more width than the base control if needed
   jComboBox = com.mathworks.mwswing.MJComboBox(strings);  % =javax.swing.JComboBox(strings);
   jComboBox.setEditable(isEditable);
   jComboBox.setBackground(java.awt.Color.white); % unfortunately, this only affects editable combos
   [jhComboBox, hContainer1] = javacomponent(jComboBox, [], hParent);
   set(jhComboBox, 'ActionPerformedCallback', callback);
   hContainer1 = handle(hContainer1);
   set(hContainer1, 'tag','hAssetContainer', 'UserData',jComboBox);

   
   % ---------------------------------------------------------------------

  
% shrink the popup selector (combo) that was just made!
set(hContainer1, 'Units','pixels', 'Position',[1,1,2,2])
   
% Create a SearchTextField control on top of the combo-box
    jAssetChooser = com.mathworks.widgets.SearchTextField('Enter search:');
    jAssetComponent = jAssetChooser.getComponent;
    [jhAssetComponent, hContainer2] = javacomponent(jAssetComponent,[],hContainer);
    hContainer2 = handle(hContainer2);
    set(hContainer2, 'tag','hAssetContainer', 'UserData',jAssetChooser, 'Units','norm', 'Position',[0,0,1,1]);
    setappdata(hContainer,'jAssetChooser',jAssetChooser);

% Expand the SearchTextField component to max available width
    jSize = java.awt.Dimension(9999, 20);
    jAssetComponent.getComponent(0).setMaximumSize(jSize);
    jAssetComponent.getComponent(0).setPreferredSize(jSize);

% Add callback handlers
    hjSearchButton = handle(jAssetComponent.getComponent(1), 'CallbackProperties');
    hjSearchField  = handle(jAssetComponent.getComponent(0), 'CallbackProperties');
    jCombo         = handle(hContainer1.UserData, 'CallbackProperties');
    jComboField    = handle(jCombo.getComponent(2), 'CallbackProperties');
    
    set(hjSearchButton, 'MouseClickedCallback', {@updateSearch,jCombo,jAssetChooser}); 
    set(hjSearchField, 'KeyPressedCallback', {@updateSearch,jCombo,jAssetChooser});
	set(jComboField, 'KeyPressedCallback', {@updateSearch,jCombo,[]});
    set(jCombo, 'FocusLostCallback', @(h,e)jCombo.hidePopup);  % hide the popup when another component is selected
    
    hContainer.UserData = [jCombo, jhAssetComponent, handle(jAssetChooser)];
    
    
    
    
    
    
    
    
    
keyboard



function searchComboUpdated(jCombo, eventData, hPanel)
    selectedItem = regexprep(char(jCombo.getSelectedItem), '<[^>]*>', ''); %strip HTML
    jSearchTextField = hPanel.UserData(2).getComponent(0);
    jSearchTextField.setText(selectedItem);
    jSearchTextField.repaint; drawnow; pause(0.01);
    jAssetChooser = getappdata(hPanel, 'jAssetChooser');
    updateSearch([], [], jCombo, jAssetChooser);
    keyboard
end

function updateSearch(hObject, eventData, jCombo, jAssetChooser)
    persistent lastSearchText

    s = load('UnitTests/TestData/AvailableFDs.mat')
    
    
    
    
    
    
    
    
    
    keyboard


end


end