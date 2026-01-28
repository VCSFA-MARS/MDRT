classdef MDRTEventCollection < handle
    %MDRTEventCollection class manages a collection of MDRTEvent objects and
    %   the way they are displayed on a plot.
    
    properties
        hFig                % handle to parent figure
        hAxArray            % array of subplots


        useT0 = false       % is t0 used
        time0               % datenum of T0 if used
        time0str            % label for t0 event marker
        isT0utc = true      % until otherwise implemented
        
        showtminus = false  % flag for displaying T- time hacks on events

        allEvents = []      % array of all event objects
        eventGroupNames     % array of all event group names (str)
        eventGroups         % array of event groupings (this obj?)

        uniqueEvents=[]     % array of event labels that link to event objects
        
        AxXLims=[]          % array of XLim tuples for each array under management
        AxYLims=[]          % array of YLim tuples for each array under management
        
        eventsOnScreen      % boolean array/mask of events that can be visible on the axes
        
        milestones = []

    end
    
    properties
        
       eventTable           %  
        
    end
    
    methods
        function self = MDRTEventCollection(parentFigure)
            switch class(parentFigure)
            case 'matlab.ui.Figure'
                self.hFig = parentFigure;
                self.hAxArray = findall(parentFigure,'type','axes', 'tag', 'MDRTAxes');
            case 'MDRTFigure'
            case 'MDRTAxes'
            otherwise

            end
            numAxes = numel(self.hAxArray);
            self.AxXLims = zeros(numAxes,2);
            self.AxYLims = zeros(numAxes,2);
            for i = 1:numAxes
                % Add Axes Listeners
                addlistener(self.hAxArray(i),'XLim','PostSet',@self.AxisChanged);
                addlistener(self.hAxArray(i),'YLim','PostSet',@self.AxisChanged);
%                 linkprop([self.hAxArray(i). self.AxXLim], {'XLim', 'XLim'});
                self.AxXLims(i,:) = self.hAxArray(i).XLim;
                self.AxYLims(i,:) = self.hAxArray(i).YLim;
            end
        end

        
        function self = addEventsFromTimeline(self, timelineStruct)
            
            hasT0 = + timelineStruct.uset0;

            numAxes = numel(self.hAxArray);
            numEvents = numel(timelineStruct.milestone);
            
            existingEvents = self.allEvents; % For joining later
            newEvents(numEvents+ hasT0, numAxes) = MDRTEvent(); % Preallocated
            
            if timelineStruct.uset0
                self.useT0 = true;
                
                self.time0 = timelineStruct.t0.time;
                self.time0str = timelineStruct.t0.name;
                self.isT0utc = true; % can't process otherwise at this time
                
                % Does this trigger update? Might need to do later
                [newEvents.t0] = deal(self.time0);
                [newEvents.showtminus] = deal(true);
            end
            
            % Temporarily disable legends to avoid updating speed issues
            hAxCellVect{1,numAxes} = [];
            for i = 1:numAxes
                % oldLegProp{i} = self.hAxArray(i).Legend.AutoUpdate;
                % self.hAxArray(i).Legend.AutoUpdate = 'off';
                % legend(self.hAxArray(i), 'off');
            end
            
            times = {timelineStruct.milestone.Time}';
            names = {timelineStruct.milestone.String}';
            FDstr = {timelineStruct.milestone.FD}';
            for ai = 1:numAxes
               [newEvents(1:end-1,ai).Time] = deal(times{:});
               [newEvents(1:end-1,ai).EventName] = deal(names{:});
               [newEvents(1:end-1,ai).FD_String] = deal(FDstr{:});
            end
                        
            for ei = 1:numEvents
                % Loop through each milestone definition
                
                for ai = 1:numAxes
                    %  newEvents(ei, ai).Time = timelineStruct.milestone(ei).Time;
%                     newEvents(ei, ai).FD_String = timelineStruct.milestone(ei).FD;
%                     newEvents(ei, ai).EventName = timelineStruct.milestone(ei).String;
                    newEvents(ei, ai).setParentAxes(self.hAxArray(ai), self.AxXLims(ai,:), self.AxYLims(ai,:));
                    newEvents(ei, ai).refreshAnnotations();
                    % newEvents(ei, ai).SetAxesLimits(self.AxXLims(ai), self.AxYLims(ai));
                end
            end
            
            % special case: make T0 marker
            for ai = 1:numAxes
                if ~ hasT0
                    continue
                end
                newEvents(end, ai).Time = self.time0;
                newEvents(end, ai).EventName = self.time0str;
                newEvents(end, ai).FD_String = self.time0str;
                newEvents(end, ai).showtminus = false;
                newEvents(end, ai).LineColor = 'red';
                newEvents(end, ai).LineStyle = '-';
                newEvents(end, ai).FontColor = 'red';
                newEvents(end, ai).setParentAxes(self.hAxArray(ai), self.AxXLims(ai,:), self.AxYLims(ai,:));
                newEvents(end, ai).refreshAnnotations();
            end
                
            self.allEvents = vertcat(self.allEvents, newEvents);


            for i = 1:numAxes
                % self.hAxArray(i).Legend.AutoUpdate = oldLegProp{i};
                % legend(self.hAxArray(i), 'on')
            end
            
            % Do I want to manage what's on and off axes for faster
            % updates?
%             self.eventsOnScreen = self.eventsOnAxes()

        end
        
        
        
        function AxisChanged(self, ~, event)
            % AxisChanged is called whenever the listeners detect that an axis object has panned or zoomed.
            XLim = event.AffectedObject.XLim;
            YLim = event.AffectedObject.YLim;
            axInd = arrayfun(@(x)find(self.hAxArray==x,1),event.AffectedObject);
            
            self.UpdateEventsFromNewLimits(XLim, YLim, axInd)
        end
        
        function UpdateEventsFromNewLimits(self, XLim, YLim, axInd)
            for i = 1:length(self.allEvents)
                self.allEvents(i, axInd).SetAxesLimits(XLim, YLim);
            end
        end
        
        
        function makePrintSize(self, isPrint)
            for i = 1:numel(self.allEvents)
                self.allEvents(i).setPrintMode(isPrint);
            end
        end
        
        
        
        
        
        
        function logicalIndex = eventsOnAxes(self, XLim)
            logicalIndex = [self.allEvents.Time] < max(XLim) & [self.allEvents.Time] > min(XLim);
        end
        
        

    end
    
end
