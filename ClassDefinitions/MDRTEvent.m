classdef MDRTEvent < handle
    %MDRTEvent class manages display of individual event markers on MDRT Axes and Figures.
    %   MDRTEvent manages the graphical objects that represent events on
    %   MDRT plots. This class handles scaling, updating label positions,
    %   and visibility of labels.
    %
    
    % Counts 2020
    
    properties
        EventName ='An Event'   % Human-readable description of event
        FD_String ='EventFD'    % The FD string used to generate the event from a retrieval
        Time =[]                % A Matlab datenum representing the time (start) of the event
        
        % Category =''            % Used to group events for visibility management tool
        Visible    = true
        UserHidden = false      % User tool has hidden this event. Default is false
        
        hLine =[]               % handle to the line element
        hText =[]               % handle to the text label element
        hAxes =[]               % The Parent Axes object for this Event Marker
        
        FontSize = 10           % The font size of the event label as displayed in the plot
        FontSizePrint = 5.5       % The font size of the event label when exported to pdf
        FontColor = 'black'     % The font color of the event label. Default is black
        LineColor = 0.6*[1,1,1] % The color of the event marker line. Default is black
        LineStyle = '--'        % The style of the event marker line. Default is solid

        t0 = [];
        showtminus = false;
        
        ListenToAxes = true;    % Default behavior is to respond to parent axes (otherwise, manager manually triggers)
        yListener = [];
        xListener = [];
        vListener = [];
        xLink = [];
        yLink = [];

        MarkerLabel = '';
    end
    
    properties (SetObservable=true, GetAccess=public, SetAccess=private)
        XLim = [];
        YLim = [];
    end
    
    methods
        
        function self = MDRTEvent(varargin)
            % YLim        : starting y-limits of target axes [lower, upper]
            % UseListener : True sets internal listener to parent axes,
            %               False lets EventCollection object manage
            % time        : datenum timestamp for event
            % FD          : FD string associated with event marker
            % Name/Label  : label string associated with event marker
            % Color       : text/label color (default to black)
            % linecolor   : color of vertical line (default to gray)
            % linestyle   : style of vertical line (- - -)
            % t0          : datenum of T0 reference time (for calculation later)
            % showtminus  : bool, true causes "T-" time to be displayed in label
            %               defaults to true if t0 is provided, false otherwise
            % parentaxes  : the axes object in which the eventlabel will be displayed
            % userhidden  : the user has asked to hide this event marker  
     
            
            hAxes = [];
            Visible         = self.Visible;
            UserHidden      = self.UserHidden;
            MarkerLabel     = self.MarkerLabel;
            EventName       = self.EventName;
            FD_String       = self.FD_String;
            Time            = self.Time;
            % Category        = self.Category;
            UserHidden      = self.UserHidden;
            hLine           = self.hLine;
            hText           = self.hText;
            hAxes           = self.hAxes;
            FontSize        = self.FontSize;
            FontSizePrint   = self.FontSizePrint;
            FontColor       = self.FontColor;
            LineColor       = self.LineColor;
            LineStyle       = self.LineStyle;
            t0              = self.t0;
            showtminus      = self.showtminus;
            yListener       = self.yListener;
            xListener       = self.xListener;

            ylim = [];
            
            XLim = [0,0];
            YLim = [0,0];

            ListenToAxes   = self.ListenToAxes;

            make_empty_event = false;

            for vi = 1:numel(varargin)
                arg = varargin{vi};
                if iscellstr(arg)
                    arg = arg{1};
                elseif isnumeric(arg)
                    continue
                end
                
                if vi+1 <= numel(varargin)
                    val = varargin{vi + 1};
                else
                    continue
                end
                
                switch lower(arg)
                    case {'ylim'}
                        ylim = val;
                    case 'use_listener'
                        ListenToAxes = val;
                    case {'t0', 't0time'}
                        t0 = val;
                    case 'showtminus'
                        showtminus = val;
                    case 'linestyle'
                        LineStyle = val;
                    case 'linecolor'
                        LineColor = val;
                    case {'color', 'fontcolor', 'textcolor'}
                        FontColor = val;
                    case {'fontsize', 'textsize'}
                        FontSize = val;
                    case {'printfontsize', 'printtextsize'}
                        FontSizePrint = val;
                    case {'name', 'label', 'eventname'}
                        EventName = val;
                    case {'fd_string', 'fd', 'fdname'}
                        FD_String = val;
                    case {'time', 'eventtime', 'event_time'}
                        Time = val;
                    case {'axes', 'parentaxes'}
                        hAxes = val;
                    case {'userhidden', 'disable', 'hidden', 'disabled'}
                        UserHidden = val;
                    case {'markerlabel'}
                        MarkerLabel = val;
                    case {'make empty for zeros'}
                        make_empty_event = val;
                end
                
            end
           

            self.EventName    =  EventName;
            self.FD_String    =  FD_String;
            self.Time         =  Time;
            % self.Category     =  Category;
            self.UserHidden   =  UserHidden;

            self.FontSize     =  FontSize;
            self.FontSizePrint=  FontSizePrint;
            self.FontColor    =  FontColor;
            self.LineColor    =  LineColor;
            self.LineStyle    =  LineStyle;

            self.t0           =  t0;
            self.showtminus   =  showtminus;
            
            if make_empty_event
                return
            end
            
            if isempty(MarkerLabel)
                MarkerLabel  = self.makeEventLabel();
                self.MarkerLabel = MarkerLabel;
            end
            
            if isempty(Time)
                return
            end

            self.hLine = self.makeLine(Time, ylim, hAxes, LineColor, LineStyle);    
            self.hText = self.makeText(Time, ylim, MarkerLabel, hAxes, FontSize, FontColor);
            
            self.ListenToAxes = ListenToAxes;
            self.setParentAxes(hAxes); % sets and updates listeners if ListenToAxes

        end
        
        function self = set.EventName(self, value)              %#ok<MCHV2>
            self.EventName = value;
            self.refreshMarkerLabel();
        end
       
        function self = set.FontColor(self, value)
            % set.FontColor allows numerical or 'black' style colors, just
            % like Matlab's built-in color schemes for plot lines
            self.hText.Color = value; %#ok<MCSUP>
            self.FontColor = lower(value);
        end
        
        function self = set.FontSize(self, value)
            self.setLabelFontSize(value)
            self.FontSize = value;
        end
        
        function self = set.FontSizePrint(self, value)
            self.setLabelFontSize(value)
            self.FontSizePrint = value;
        end
                
        function self = set.LineColor(self, value)
            self.hLine.Color = value;                           %#ok<MCSUP>
            self.LineColor = lower(value);
        end
        
        function self = set.LineStyle(self, value)
            self.LineStyle = value;
            self.hLine.LineStyle = self.LineStyle;              %#ok<MCSUP>
        end
        
        function self = set.UserHidden(self, value)
            self.UserHidden = value;
            self.UpdateEventFromNewLimits;
        end
                
        function self = setPrintMode(self, isPrintMode)
            if isPrintMode
                self.setLabelFontSize(self.FontSizePrint);
            else
                self.setLabelFontSize(self.FontSize);
            end
        end
        
        function self = setValuesFromMilestone(self, milestone)
            % Call this on an MDRTEvent object preallocated with
            % zeros(n,1,'MDRTEvent') to populate?
            
            self.EventName = milestone.String;
            self.FD_String = milestone.FD;
            self.Time = milestone.Time;
            
            newLabel = self.makeEventLabel();
            
            if isempty(self.MarkerLabel) || ~strcmp(self.MarkerLabel, newLabel)
                self.MarkerLabel  = newLabel;
            end
            
            self.hLine = self.makeLine(self.Time, self.YLim, self.hAxes, self.LineColor, self.LineStyle);    
            self.hText = self.makeText(self.Time, self.YLim, self.MarkerLabel, self.hAxes, self.FontSize, self.FontColor);
           
            self.setParentAxes(self.hAxes); % sets and updates
            
        end
        
        
        function self = refreshMarkerLabel(self)
            newLabel = self.makeEventLabel();
            if isempty(self.MarkerLabel) || ~strcmp(self.MarkerLabel, newLabel)
                self.MarkerLabel  = newLabel;
            end
        end
        

        function self = refreshAnnotations(self)
            % Redraws annotation objects, deleting abandoned objects if
            % required. Maintains MDRTEvent's handle to annotation objects
            self.hLine = self.makeLine(self.Time, self.YLim, self.hAxes, self.LineColor, self.LineStyle);    
            self.hText = self.makeText(self.Time, self.YLim, self.MarkerLabel, self.hAxes, self.FontSize, self.FontColor);
        end
        
        
        function self = setParentAxes(self, hAxes, varargin)
            % Updates axes listeners if use_listener = true
            % NOT IMPLEMENTED !!!
            % optional arguments: XLim, YLim - use when actually assigning
            % a new parent axes
            if self.hAxes == hAxes
                return
            end
                        
            self.hAxes = hAxes;
            if nargin > 2
                self.SetAxesLimits(varargin{1},varargin{2});
            end
            self.refreshAnnotations();
        end

        
        function AxisLimitsChanged(self, ~, event)
            % AxisLimitsChanged is called whenever the listeners detect that an axis object has panned or zoomed.
            
%             XLim = event.AffectedObject.XLim;
%             YLim = event.AffectedObject.YLim;

            self.hLine.YData = self.hLine.YLim;
            self.hText.Position(2) = self.labelYCoordFromLimits(self.hLine.YLim);
            
            self.Visible = ~self.isVarOutsideInterval(self.Time, self.XLim);
            
%             self.UpdateEventFromNewLimits(XLim, [])
            
        end
        
        
        function self = SetAxesLimits(self, XLim, YLim)
            % Allows external function to directly modify limits,
            % triggering a refresh/redraw
            self.XLim = XLim;
            self.YLim = YLim;
            self.UpdateEventFromNewLimits();
        end
        
        function self = UpdateEventFromNewLimits(self)
            % Internal method, updates display state of Event object from
            % XLim and YLim. Either called by AxisLimitsChanged() function as a
            % result of property listener, or called by SetAxesLimits() as
            % called by the EventCollection object.
            
            if isempty(self.hLine) || isempty(self.hText)
                return
            end
            
            % X-Axis Updates
            if self.isVarOutsideInterval(self.Time, self.XLim)
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
            if isempty(self.YLim)
                self.hLine.YData = [0,1];
                self.hText.Position(2) = self.labelYCoordFromLimits([0,1]);
            else
                self.hLine.YData = self.YLim;
                self.hText.Position(2) = self.labelYCoordFromLimits(self.YLim);
            end
            
        end


        function label = makeEventLabel(self)
            % Returns a properly formatted Event Label based on class
            % properties. Relies on showtminus to toggle display style.
            suffix = '';
            if ~self.showtminus || isempty(self.t0)
                timeString = datestr(self.Time, 'HH:MM:SS');
                if isempty(timeString)
                    timeString = '';
                end
                prefix = '';
                suffix = 'UTC';
            else
                dt = self.Time - self.t0;
                timeString = datestr(abs(dt), 'HH:MM:SS');
                if dt < 0
                    prefix = 'T-';
                else
                    prefix = 'T+';
                end
            end

            label = [prefix, timeString, ' ' self.EventName, '',suffix];
        end
        
        
        function hLine = makeLine(self, time, ylim, hax, color, style)
            % Returns a new hLine object. Handles old object deletion if
            % required.
            if ~isempty(self.hLine)
                if isa(self.hLine, 'matlab.graphics.primitive.Line')
                    self.hLine.delete % Cleanup old object if needed
                else
                    self.hLine = [];
                end
            end
            

            hLine = line(   time*[1,1],               ylim , ...
                            'Parent',           hax , ...
                            'Tag',              'MDRTEvent_line', ...
                            'Color',            color, ...
                            'LineStyle',        style, ...
                            'DisplayName',      '', ...
                            'HitTest',          'off', ...
                            'HandleVisibility', 'off' );
%             hLine.Annotation.LegendInformation.IconDisplayStyle = 'off';
        end


        function hText = makeText(self, time, ylim, labelStr, hax, fontsize, fontcolor)
            
            if ~isempty(self.hText)
                if isa(self.hText, 'matlab.graphics.primitive.Text')
                    self.hText.delete
                else
                    self.hText = [];
                end
            end
            
            labelYCoord = MDRTEvent.labelYCoordFromLimits(ylim);
            hText = text(   time,               labelYCoord, ...
                            labelStr, ...
                            'Parent',           hax , ...
                            'Tag',              'MDRTEvent_label', ...
                            'Rotation',         -90, ...
                            'HitTest',          'off', ...
                            'FontSize',         fontsize, ...
                            'Color',            fontcolor );
                            % 'BackgroundColor', 	[1 1 1]);
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


        function result = eventFromMilestone(milestone, thisAxes, ylim, useT0label, t0time)

            if isempty(ylim)
                [thisAxes, ylim] = MDRTEvent.getAxesAndYLim(thisAxes);
            end

            result  = MDRTEvent('Time',         milestone.Time, ...
                                'EventName',    milestone.String, ...
                                'EventFD',      milestone.FD, ...
                                'ShowTMinus',   useT0label, ...
                                'T0Time',       t0time, ...
                                'ParentAxes',   thisAxes, ...
                                'YLim',         ylim );

        end


        function results = eventsFromTimeline(timeline, hAxes)
            % The equivalent of reviewPlotAllTimelineEvents(), this constructor
            % will create MDRTEvent marker objects from the timeline structure 
            % on the axes object and return the handles the MDRTEvent objects.
            % Will use T- time labels if possible

            results = [];
            t0val = [];
            useT0labels = false;
            [thisAxes, ylim] = MDRTEvent.getAxesAndYLim(hAxes);

            if timeline.uset0
                t0label = timeline.t0.name;
                t0val = timeline.t0.time;
                if timeline.t0.utc
                    timezone = 'UTC';
                else
                    timezone = 'Local';
                end
                
                datestring = datestr(timeline.t0.time,'HH:MM.SS');
                markerLabel = [timeline.t0.name, ': ', datestring, ' ', timezone];
                useT0labels = true;

                results = MDRTEvent('MarkerLabel',   markerLabel,...
                                    'EventName',    'T0', ...
                                    'Time',         timeline.t0.time, ...
                                    'parentaxes',   thisAxes, ...
                                    'ylim',         ylim, ...
                                    'color',        'red', ...
                                    'linecolor',    'red' );
            end

            for i = 1:length(timeline.milestone)
                result = MDRTEvent.eventFromMilestone(timeline.milestone(i), ...
                                   thisAxes, ylim, useT0labels, t0val);

                % result  = MDRTEvent('Time',         timeline.milestone(i).Time, ...
                %                     'EventName',    timeline.milestone(i).String, ...
                %                     'EventFD',      timeline.milestone(i).FD, ...
                %                     'ShowTMinus',   useT0labels, ...
                %                     'T0Time',       t0val, ...
                %                     'ParentAxes',   thisAxes, ...
                %                     'YLim',         ylim );
                
                results = vertcat(results, result);
            end


        end
        

        function result = quickEvent(label, time, haxes)
            % quickEvent() takes a few simple inputs and generates an EventMarker 
            % object with default parameters, having queried the parent axes
            % for the YLim for proper display. 
            % NOTE: This is very slow in a loop or any other batch creation

            [thisParent, ylim] = MDRTEvent.getAxesAndYLim(haxes);

            result = MDRTEvent('MarkerLabel',   label, ...
                                'Time',         time', ... 
                                'parentaxes',   thisParent, ...
                                'ylim',         ylim);
        end


        function [hAx, YLim] = getAxesAndYLim(parent)
            % Returns a handle to the parent axes object and the YLim of that
            % axes as queried. NOTE: This is very slow in a loop
            switch class(parent)
                case 'MDRTAxes'
                    YLim = parent.hAx.YLim;
                    hAx = parent.hAx;
                case 'MDRTFigure'
                    YLim = parent.subplots.hAx.YLim;
                    hAx = MFig.subplots.hAx;
                case 'matlab.graphics.axis.Axes'
                    YLim = parent.YLim;
                    hAx = parent;
                otherwise
                    xAx = [];
                    YLim = [];
            end
        end
        
        
        function z = zeros(varargin)
            % allows creation of 'blank' array of MDRTEvents for preallocation?
            % zeros(5,1,'MDRTEvent')
            if nargin == 0
                z = MDRTEvent('make empty for zeros', true);
            elseif any([varargin{:}] <= 0)
                % For zeros with any dimension <= 0   
                z = MDRTEvent('make empty for zeros', true, varargin{:});
            else
                % For zeros(m,n,...,'Color')
                % Use property default values
%                 z = repmat(Color,varargin{:});
                z = repmat(MDRTEvent('make empty for zeros', true), varargin{:});
            end
            
        end


    end
    
    methods (Hidden)
        function z = zerosLike(varargin)
            % This is probably broken...
            
            if nargin == 0
                z = MDRTEvent('make empty for zeros', true);
            elseif any([varargin{:}] <= 0)
                % For zeros with any dimension <= 0   
                z = MDRTEvent('make empty for zeros', true, varargin{:});
            else
                % For zeros(m,n,...,'Color')
                % Use property default values
%                 z = repmat(Color,varargin{:});
                z = repmat(MDRTEvent('make empty for zeros', true), varargin{:});
            end
            
        end
    end
    
    
    
    
    methods (Access=private)
        
        function self = setLabelFontSize(self, value)
            self.hText.FontSize = value;
        end
        

    end
    
end

