classdef EventTaggerModel < handle
    %EventTaggerModel event tag model
    %   Data class for event tagger tool
    
    properties
        eventTagName        % Human readable string used in event export
        eventFDName         % "FD" name used in event export
        markerPairs         % Numerical array 2xn of "position" matrices
        positions           % all timestamps as a column vector
    end
    
    properties (Access = private, SetObservable = true)
        timestamps          % all timestamps as an r x 2 array
        cursorInfo          % raw struct data from getCursorInfo
    end
    
    properties (SetAccess = immutable)
        updateListener      % listener for raw 
    end
    
    properties (Constant)
        defaultTagName = 'Event Name';
        defaultFDName  = 'Event FD';
    end
    
    
    methods
        function this = EventTaggerModel
            this.eventTagName = this.defaultTagName;
            this.eventFDName  = this.defaultFDName;
            this.updateListener = addlistener(this, 'cursorInfo', 'PostSet', @this.refreshCursorArray);
            
        end
        
        
        function this = setCursorInfo(cursorInfo)
            this.cursorInfo = cursorInfo;
        end
          
        function this = refreshCursorArray(this)
            this.positions  = cell2mat( {dc.Position}' );
            this.timestamps = unique(this.positions(:,1));
            debugout(this.timestamps);
        end
                
    end
    
end

