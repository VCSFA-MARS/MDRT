function result = makeIconFileWithBadge(base_image, badge_image, new_file)
  % New png file is written with badge_image overlaid on base_image.
  % No alpha-blending is implemented on the color data. A simple alpha-mask 
  % addition is performed on the alpha layer.

  ALPHA_THRESHOLD = 128;

% hf = uifigure;
% hg = uigridlayout(hf, [1 1]);
% hx = uiaxes(hg);

% [Base, ~, Base_alpha] = imread(getMDRTResource('GenericFolderIcon.png', 'ResourceType', 'icon'));
% [Over, ~, Over_alpha] = imread(getMDRTResource('ToolbarDeleteIcon.png', 'ResourceType', 'icon'));

[Base, ~, Base_alpha] = imread(base_image);
[Over, ~, Over_alpha] = imread(badge_image);

%% Do a direct overlay of badge data
%  No alpha-blending calculation is done right now. There is a default
%  alpha threshold and base_image pixels are simply replaced by the badge
%  pixels if the alpha threshold is above the threshold.

badge_width =  size(Over,2);
badge_height = size(Over,1);

% f_width =  size(Base,2);
% f_height = size(Base,1);

Combined = Base; % Make copy of base layer RGB data to modify
roi_x1 = size(Combined,1) - badge_height + 1;
roi_x2 = size(Combined,1);
roi_y1 = size(Combined,2) - badge_width  + 1;
roi_y2 = size(Combined,2);

% Make a copy of the "region of interest" where overlay is occuring
Combined_ROI = Combined(roi_x1:roi_x2, roi_y1:roi_y2, :);

%% Do Replacement

a_pixels_to_replace = Over_alpha > ALPHA_THRESHOLD;
c_pixels_to_replace = repmat(a_pixels_to_replace, 1, 1, 3);

Combined_ROI(c_pixels_to_replace) = Over(c_pixels_to_replace);
Combined(roi_x1:roi_x2, roi_y1:roi_y2, :) = Combined_ROI; 


Combined_ROI_alpha = Base_alpha(roi_x1:roi_x2, roi_y1:roi_y2);
Combined_ROI_alpha(a_pixels_to_replace) = Over_alpha(a_pixels_to_replace);
Combined_alpha = Combined_ROI_alpha;

% Combined(roi_x1:roi_x2, roi_y1:roi_y2, :) = ... 
%   Over .* Over_alpha + Combined_ROI .* (255-Over_alpha);

h = imshow(Combined, 'Parent', hx);
h.AlphaData = Combined_alpha;

%% Write File
 
result = imwrite(Combined, 'testFile.png', 'png', 'Alpha', Combined_alpha);

