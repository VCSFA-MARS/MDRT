classdef MDRTEvent
    %MDRTEvent class manages display of individual event markers on MDRT Axes and Figures.
    %   MDRTEvent manages the graphical objects that represent events on
    %   MDRT plots. This class handles scaling, updating label positions,
    %   and visibility of labels.
    %
    
    % Counts 2020
    
    properties
        String                  % Human-readable description of event
        FD_String               % The FD string used to generate the event from a retrieval
        Time                    % A Matlab datenum representing the time (start) of the event
        
        Category                % Used to group events for visibility management tool
        UserHidden = false      % User tool has hidden this event. Default is false
        
        hLine                   % handle to the line element
        hText                   % handle to the text label element
        
        FontSize = 10           % The font size of the event label as displayed in the plot
        FontSizePrint = 6       % The font size of the event label when exported to pdf
        FontColor = 'black'     % The font color of the event label. Default is black
        LineColor = 0.6*[1,1,1] % The color of the event marker line. Default is black
        LineStyle = '--'        % The style of the event marker line. Default is solid
        
    end
    
    methods
        
        function self = MDRTEvent(EventStruct, MFig)
           
            self.String = EventStruct.String;
            self.FD_String = EventStruct.FD;
            self.Time = EventStruct.Time;
            
            % Default event values
                self.UserHidden = false;
                self.Category = '';
                
            
            switch class(MFig)
                case 'MDRTAxes'
                    ylim = MFig.hAx.YLim;
                    thisParent = MFig.hAx;
                case 'MDRTFigure'
                    ylim = MFig.subplots.hAx.YLim;
                    thisParent = MFig.subplots.hAx;
                otherwise
            end
            
                
            self.hLine = line(  EventStruct.Time*[1,1], ylim , ...
                            'Parent',           thisParent , ...
                            'Tag',              'MDRTEvent_line', ...
                            'Color',            self.LineColor, ...
                            'LineStyle',        self.LineStyle );                            
                            
            self.hText = text(self.Time, self.labelYCoordFromLimits(ylim), ...
                            self.String, ...
                            'Parent',           thisParent , ...
                            'Tag',              'MDRTEvent_label', ...
                            'Rotation',         -90, ...
                            'FontSize',         [self.FontSize], ...
                            'Color',            self.FontColor );
                            % 'BackgroundColor', 	[1 1 1]);
                
            addlistener(thisParent,'XLim','PostSet',@self.AxisChanged);
            addlistener(thisParent,'YLim','PostSet',@self.AxisChanged);
            
        end
        
        
        
        function self = set.FontColor(self, value)
            % set.FontColor allows numerical or 'black' style colors, just
            % like Matlab's built-in color schemes for plot lines
            self.hText.Color = value;
            self.FontColor = lower(value);
        end
        
        function self = set.FontSize(self, value)
            self.hText.FontSize = value;
            self.FontSize = value;
        end
        
        function self = set.FontSizePrint(self, value)
            self.hText.FontSize = value;
            self.FontSizePrint = value;
        end
                
        function self = set.LineColor(self, value)
            self.hLine.Color = value;
            self.LineColor = lower(value);
        end
        
        function self = set.LineStyle(self, value)
            self.hLine.LineStyle = value;
            self.LineStyle = value;
        end
        
            
        function AxisChanged(self, hobj, event)
            % AxisChanged is called whenever the listeners detect that an axis object has panned or zoomed.
            
            XLim = event.AffectedObject.XLim;
            YLim = event.AffectedObject.YLim;
            
            % X-Axis Updates
            if self.isVarOutsideInterval(self.Time, XLim)
                self.hLine.Visible = 'off';
                self.hText.Visible = 'off';
            elseif self.UserHidden
                self.hLine.Visible = 'off';
                self.hText.Visible = 'off';
            else
                self.hLine.Visible = 'on';
                self.hText.Visible = 'on';
            end
        
            % Y-Axis Updates
            self.hLine.YData = YLim;
            self.hText.Position(2) = self.labelYCoordFromLimits(YLim);
            
        end
    end
    
    methods(Static)
        function isOutsideRange = isVarOutsideInterval(variable, interval)
            % isVarOutsideInterval returns true if var is outside the open interval
            %
            %     isVarOutsideInterval(1, [0,2])
            %           Returns false
            % 
            %     isVarOutsideInterval(3, [0,2])
            %           Returns true
            % 
            %     isVarOutsideInterval(2, [0,2])
            %           Returns false
            
            % TODO: hText.Extent for text-box checking
            
            if ((variable < interval(1)) || variable > interval(2))
                isOutsideRange = true;
            else
                isOutsideRange = false;
            end
        end
        
        
        function Ycoord = labelYCoordFromLimits(limits, percentOffset)
            % labelYCoordFromLimits(limits, percentOffset) returns the Y coordinate for placing an
            % event marker label when passed a YLim tuple ( 2-element row
            % vector ).
            %
            % The percentOffset is an optional parameter. 0.5 would offset
            % the text 50% from the top of the axis.
            %
            % Note: function expects the limits parameter sorted in
            % ascending order (XLim and YLim are always sorted). No
            % checking or sorting is performed to keep the speed up. Be
            % wise if using this on data that comes from another sourse and
            % sort if required.
            %            
            %     labelYCoordFromLimits([0, 100])
            %         Returns 95
            %
            %     labelYCoordFromLimits([0, 100], 0.25)
            %         Returns 75
            %
            
            if nargin == 1
                percentOffset = 0.05;
            end
            
            Ycoord = limits(2) - (limits(2)-limits(1)) * percentOffset;
             
        end
        
    end
    
end

