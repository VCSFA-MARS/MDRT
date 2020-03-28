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
            
            % Update positions
            numPlots = length(self.subplots);
            for i = 1:numPlots
                self.subplots(i).setPosition( self.axesPositionForNumberOfSubplots(numPlots, i) );
            end
            
        end
        
        
    end
    
    methods (Static)
        
        function posArray = axesPositionForNumberOfSubplots(total, index)
            % axesPositionForNumberOfSubplots(total, index) returns a [total x 4] matrix of axis position values
            % 
            % Used to help position multiple subplots, which are indexed
            % column first. Position vectors are in normalized units.
            % 
            % axesPositionForNumberOfSubplots(total, index)
            %
            %   total   : the total numper of subplots to be positioned,
            %             between 1 and 9
            %
            %   index   : an optional parameter. When specified, a 1x4 row
            %             vector is returned corresponding to the position 
            %             vector of that subplot.
            %
            % Examples:
            %
            % >> MDRTFigure.axesPositionForNumberOfSubplots(4)
            %
            % ans =
            % 
            %     0.0600    0.5250    0.4150    0.4150
            %     0.0600    0.0600    0.4150    0.4150
            %     0.5250    0.5250    0.4150    0.4150
            %     0.5250    0.0600    0.4150    0.4150
            %
            %
            % >> MDRTFigure.axesPositionForNumberOfSubplots(4,2)
            %
            % ans =
            % 
            %      0.0600    0.0600    0.4150    0.4150

            % Note to devs: the position attribute specifies the bottom
            % left corner of the axes object. (0,0) is the bottom left
            % corner of the figure window

            posArray = [];
            
            %	Default page setup for landscape US Letter
                numperOfPlots = 1;
                plotGap = 0.05;
                plotMargin = 0.06;
                marginX = 0.05;
                marginY = 0.05;
  
                switch total
                    case {1, 2, 3}
                        plotsWide = 1;
                        plotsHigh = total;
                    case {4}
                        plotsHigh = 2;
                        plotsWide = 2;
                    case {5, 6}
                        plotsHigh = 2;
                        plotsWide = 3;
                    case {7, 8, 9}
                        plotsWide = 3;
                        plotsHigh = 3;
                    otherwise
                end
                
                axWide = (1 - 2*plotMargin - (plotsWide -1)*marginX)/plotsWide ;
                axHigh = (1 - 2*plotMargin - (plotsHigh -1)*marginY)/plotsHigh ;
                
                for x = 1:plotsWide
                    for y = 1:plotsHigh
                        xpos = plotMargin + (x-1) * (axWide + marginX);
                        ypos = 1 - plotMargin - (y)*axHigh - marginY*(y-1);
                        posArray = vertcat(posArray, [xpos, ypos, axWide, axHigh]);
                    end
                end
                
                posArray(total+1:end,:) = []; % cleanup extras
                
                % Return just the indexed value, if requested
                if nargin == 2
                    posArray = posArray(index, :);
                end
        end
    end
    
end

