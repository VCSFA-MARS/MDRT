function marker (fig, varargin)

% deltat is a helper routine designed to operate data-tip pairs in a plot
% finds two data tips and displays the elapsed time between them
%
%   USE:
%   
%   On a plot, add two data-cursors.
%
%   run deltat(figureNumber)
%




dcm_obj = datacursormode(fig);
q = getCursorInfo(dcm_obj);

deltaT = abs(q(2).Position(1)-q(1).Position(1));

switch nargin
    case 1
        datestr(deltaT,'HH:MM:SS.FFF')
    case 2
        days = floor(deltaT);
        timeText = datestr(deltaT,'HH:MM:SS.FFF');
        disp(sprintf('%d days, %s', days, timeText))
end



end