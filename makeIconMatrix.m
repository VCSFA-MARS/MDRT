

original_folder_icons = {
  'Folder_Tahoe_Empty.png'
  'Folder_Tahoe_Full.png'
  % 'OpenFolderIcon.png'
  % 'LibraryFolderIcon.png'
  'valve_white.png'
  'valve_black.png'
  'valve_blue.png'
  'valve_color.png'
  }

badge_icons = {
  'AlertStopIcon.png'
  'ToolbarInfo.png'
  'ToolbarDeleteIcon.png'
  'Badge_green.png'
  'Badge_red.png' 
  'Badge_yellow.png'
  }

grid_size = [length(original_folder_icons), length(badge_icons)] + 1;

hf = uifigure;
hg = uigridlayout(hf, grid_size);

%% Plot 'header row'
for i = 1:length(badge_icons)
  layoutTgt = matlab.ui.layout.GridLayoutOptions('Row', 1, 'Column', i+1);
  tAx = uiaxes(hg, 'Layout', layoutTgt);
  imshow(getMDRTResource(badge_icons{i}, 'ResourceType', 'icon'), 'Parent', tAx );
end

%% Plot 'header col'
for i = 1:length(original_folder_icons)
  layoutTgt = matlab.ui.layout.GridLayoutOptions('Column', 1, 'Row', i+1);
  tAx = uiaxes(hg, 'Layout', layoutTgt);
  imshow(getMDRTResource(original_folder_icons{i}, 'ResourceType', 'icon'), 'Parent', tAx);
end

row = 1;
col = 1;

for folder_ind = 1:length(original_folder_icons)
  this_folder_file = getMDRTResource(original_folder_icons{folder_ind}, 'ResourceType', 'icon');
  row = row + 1;

  for badge_ind = 1:length(badge_icons)
    this_badge_file = getMDRTResource(badge_icons{badge_ind}, 'ResourceType', 'icon');
    col = col + 1;

    combined_file_name = [tempname, '.png'];
    makeIconFileWithBadge(this_folder_file, this_badge_file, combined_file_name);
    [~,~,alpha] = imread(combined_file_name);

    layoutTgt = matlab.ui.layout.GridLayoutOptions('Column', col, 'Row', row);
    tAx = uiaxes(hg, 'Layout', layoutTgt);

    h = imshow(combined_file_name, 'Parent', tAx);
    h.AlphaData = alpha;

    disp(combined_file_name)


  end
  col = 1;
end

getMDRTResource('GenericFolderIcon.png', 'ResourceType', 'icon')
getMDRTResource('OpenFolderIcon.png', 'ResourceType', 'icon')
