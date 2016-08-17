function addAdvancedMenuToPlot( figureHandle )
%addAdvancedMenuToPlot adds a menu to plot windows
%


m = uimenu(figureHandle, 'Label', 'Advanced');


uimenu(m,   'Label',        'Link Axes', ...
            'Callback',     @linkTimeAxes )
        
uimenu(m,   'Label',        'Unlink Axes', ...
            'Callback',     @unlinkTimeAxes )
        
        
end

