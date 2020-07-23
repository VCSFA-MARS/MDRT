function linkTimeAxes( varargin )
% linkTimeAxes() links x axis (time) on multiple axes in a given figure
%
%   This function is called from MDRTFigures with the "Advanced" menu. When
%   called from the menu, two arguments are passed:
%   
%       varargin{1} : matlab.ui.container.Menu
%       varargin{2} : matlab.ui.eventdata.ActionData
%
%   This function will filter out any suptitle handles, which are axes
%   objects at root. 
%
%     linkTimeAxes(menuHandle)
%     linkTimeAxes(figureHandle)
%     linkTimeAxes(axesArray)

% Counts - updated 2020

if nargin
    switch class(varargin{1})
        case 'matlab.ui.container.Menu'           
            figureHandle = varargin{1}.Parent.Parent;
            rawAxesArray = findobj( figureHandle, 'Type', 'Axes');
                
        case 'matlab.ui.Figure'
            figureHandle = varargin{1};
            rawAxesArray = findobj( figureHandle, 'Type', 'Axes');
            
        case 'matlab.graphics.axis.Axes'
            rawAxesArray = varargin{1};
            
        otherwise
            warning('unsupported argument data type');
            return
    end
end
    

% remove 'suptitle' from the array of axes

axesArray = rawAxesArray(arrayfun(@(e) ...
                            ~isequal(e.Tag,'suptitle'), ...
                            rawAxesArray));

linkaxes(axesArray, 'x');