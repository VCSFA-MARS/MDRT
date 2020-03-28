classdef MDRTFigure < handle
    %MDRTFigure MDRT Plot-containing figure
    %   MDRTFigure() creates a blank figure with one MDRTAxes
    
    properties
        hfig            = [];
        subWindows      = [];
        subplots        = [];
        graphTitle      = 'MDRT Plot';
        
        eventmanager    % The MDRT Event collection manager for this MDRT Figure
        
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
            self.addSubplot(MDRTAxes);
            self.hGraphTitle = suptitle('MDRT Plot');
            
            orient(self.hfig, 'landscape');
        end
        
        
        
        
        function self = addSubplot(self, hax)
            %addSubplot adds a new MDRTSubplot object to the MDRTFigure object
            %
            % Using addSubplot registers the MDRTAxis object to the parent
            % and allows MDRTFigure properties to control axis positioning
            % and provide access for the built-in tools

            if ~isempty(self.subplots)
            % Check to make sure we aren't duplicating axes
                if max(self.subplots == hax)
                    % Duplicate 
                    return
                else
                    % Safe to add
                end
            end
            
            % Safe to add
            self.subplots = vertcat(self.subplots, hax);
            hax.setParent(self.hfig);            
            
        end
        
        
    end
    
end

