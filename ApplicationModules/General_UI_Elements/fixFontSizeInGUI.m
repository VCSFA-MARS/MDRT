function parent = fixFontSizeInGUI(parent,fontSizeFactor)
% Windows OS handles font sizing differently from Linux and OS X. This function
% finds all objects with a `FontSize` property and scales them by the
% `fontSizeFactor`
%
% Expected to be called from either the GUIDE-generated '_OpeningFcn' or to be
% called at the end of figure and uicontrol population in script-generated GUIs
%
% Example call:
%
%   if ispc
%       fixFontSizeInGUI(gcf, 0.8)
%   elseif isunix
%       fixFintSizeInGUI(gcf, 0.75)
%   end
%

if isprop(parent,'FontSize')
    parent.FontSize = parent.FontSize*fontSizeFactor;
end

for ii = 1:length(parent.Children)
    if ~isempty(parent.Children(ii))
        parent.Children(ii) = fixFontSizeInGUI(parent.Children(ii),fontSizeFactor);
    end
end