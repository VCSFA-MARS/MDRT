%% makeTestListbox - creates a searchable listbox with an FDCollection 
%   1) instantiats figure, listbox, and editbox
%   2) loads a dataIndex array from real data (currently uses config to find
%      actual data, not using pre-canned test data)
%   3) instantiates an FDCollection object, populates with the dataIndex
%      array, associates the contents with the listbox, and sets the searchUI
%      property as the editbox.
%   4) calls populateListbox method on FDCollection to display the initial
%      search results

hs.fig = figure;
hs.listbox = uicontrol(hs.fig, 'style','listbox','Units','normalized','Position',[0.1,0.1,0.8,0.8]);
hs.editbox = uicontrol(hs.fig, 'style','edit','Units','normalized','Position',[0.1,0.95,0.8,0.05],'HorizontalAlignment','left');

% hs.listbox.Units = 'normalized'
% hs.listbox.Position = [0.1,0.1,0.8,0.8]

cfg = MDRTConfig.getInstance;
load(fullfile(cfg.dataArchivePath, 'dataIndex.mat'));

fdc = FDCollection(dataIndex(1:2), hs.listbox);
fdc.searchUI = hs.editbox;
fdc.populateListbox;

