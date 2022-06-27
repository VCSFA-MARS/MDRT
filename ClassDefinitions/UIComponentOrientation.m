classdef UIComponentOrientation
    %UIComponentOrientation manages the orientation of FGSE UI Components
    %   Playback tools and other GUIs that display valves and other FGSE
    %   components will use this class to manage the default orientation of
    %   the component on the schematic.
    
    
    properties
        openOrientation
        upDirection
        mirrorHorizontally
        mirrorVertically
    end
    
    methods
        function this = UIComponentOrientation(openOrientation, upDirection, ...
                                               mirrorHorizontally, mirrorVertically)
           this.openOrientation     = openOrientation;
           this.upDirection         = upDirection;
           this.mirrorHorizontally  = mirrorHorizontally;
           this.mirrorVertically    = mirrorVertically;
        end
    end
    
    enumeration
        default             (0, 12, false, false)   % Horizontal, up at 12 o'clock
        Horizontal          (0, 12, false, false)   % Horizontal, up at 12 o'clock
        Vertical            (0,  3, false, false)   % Vertical,   up at  3 o'clock
        HorizontalFlipped   (0,  6, true,  false)   % Horizontal, up at  6 o'clock
        VerticalFlipped     (0,  9, false, true)    % Vertical,   up at  9 o'clock
    end
    
end

