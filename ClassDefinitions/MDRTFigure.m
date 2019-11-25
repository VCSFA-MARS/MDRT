classdef MDRTFigure < handle
    %MDRTFigure MDRT Plot-containing figure
    %   Detailed explanation goes here
    
    properties
        hfig            = [];
        subWindows      = [];
        subplots        = [];
        graphTitle      = 'MDRT Plot';
        
    end
    
    properties (SetAccess = private)
        hGraphTitle
    end
    
    methods
        
        % Register - add spawned windows to the list of subWindows
        
        % addData - pass an FD and add it to a plot
        % removeData - remove an existing FD from the plot

        % Constructor
        function self = MDRTFigure()
            self.hfig = figure;
            self.subplots = MDRTAxes;
            self.hGraphTitle = suptitle('MDRT Plot');
            
            orient(self.hfig, 'landscape');
        end
        
        
    end
    
end

