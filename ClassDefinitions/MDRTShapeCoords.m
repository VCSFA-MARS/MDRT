classdef MDRTShapeCoords
    %Enumeration of standard shapes, used to generate MDRTShape objects
    %   Used to define common HMI shapes for MDRT Playback tools. Use the
    %   XData, YData, and Vertices properties to get the coordinates.
    
    properties
        XData
        YData
        Vertices
    end

    methods
        function this = MDRTShapeCoords(vector)
            this.Vertices = vector;
            this.XData = vector(:,1);
            this.YData = vector(:,2);
        end
    end
    
    enumeration
        CenteredValve   ([0 0; 50 25; 50 -25; 0 0; -50 -25; -50 25; 0 0])
        CenteredSquare  ([0.5 0.5; -0.5 0.5; -0.5 -0.5; 0.5 -0.5])
        
    end
    
end

