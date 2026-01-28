function [figX, figY] = figCoordFromAxes(X, Y, hAx)
%% [fX, fY] = figCoordFromAxes(X, Y, hAx)
% figCoordFromAxes() converts axes coordinates to normalized parent figure
% coordinates. This is useful for adding an axes or other UI element on top
% of a plot or axes.


reverseX = false;
reverseY = false;

if isempty(hAx)
    hAx = gca;
end

if strcmpi(hAx.YDir, 'reverse')
    reverseY = true;
end

if strcmpi(hAx.XDir, 'reverse')
    reverseX = true;
end




gx0 = hAx.XLim(1);
gx1 = hAx.XLim(2);
gx = gx1 - gx0;

if reverseX
    pgx = 1-  ((X - gx0) / gx);
else
    pgx = (X - gx0) / gx;
end

ax0 = hAx.Position(1);
axh = hAx.Position(3);

figX = axh * pgx + ax0;




% Inverted becasue image plots are stupid

gy0 = hAx.YLim(1);
gy1 = hAx.YLim(2);
gy = gy1 - gy0;

if reverseY
    pgy = 1 - ((Y - gy0) / gy);
else
    pgy = (Y - gy0) / gy;
end

ay0 = hAx.Position(2);
ayh = hAx.Position(4);

figY = ayh * pgy + ay0;

