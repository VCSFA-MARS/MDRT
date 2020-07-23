function linkTimeAxes( varargin )

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


linkaxes(axesArray,'x');