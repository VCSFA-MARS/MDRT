config = MDRTConfig.getInstance;
load(fullfile(config.dataArchivePath, 'dataIndex.mat'))
FDList = dataIndex(1).FDList;

hs.fig = figure

    setappdata(hs.fig, 'fdMasterList', FDList);
    setappdata(hs.fig, 'dataIndex', dataIndex);

hs.searchbar = uicontrol(       hs.fig,                             ...
        'Tag',                  'searchBox',                        ...
        'Style',                'edit',                             ...
        'String',               '',                                 ...
        'HorizontalAlignment',  'left',                             ...
        'KeyReleaseFcn',        {@updateSearchResults, 'popup'},    ...
        'Units',                'normalized',                       ...
        'Position',             [ 0.05 0.8 0.9 0.1 ]                ...
        );


hs.hitsbox = uicontrol(hs.fig,                                      ...
        'Visible',              'off',                              ...
        'Style',                'listbox',                          ...
        'Tag',                  'listSearchResults',                ...
        'KeyPressFcn',          {@navigateSearchHits, hs.searchbar},...
        'units',                'normalized',                       ...
        'position',             [0.05 0.2 0.9 0.6]);

return

%%

position = [10,100,90,20];  % pixels
hContainer = gcf;  % can be any uipanel or figure handle
options = {'a','b','c'};
options = FDList(:,1);
model = javax.swing.DefaultComboBoxModel(options);
jCombo = javacomponent('javax.swing.JComboBox', position, hContainer);
jCombo.setModel(model);
jCombo.setEditable(true);
