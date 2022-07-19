classdef MDRTColor
    %MDRTColor is a class that manages colors for MDRT Graphics objects
    %   This class allows setting colors by either numeric values or by
    %   selecting by color name.
    
    properties
        R
        G
        B
        Alpha
    end
    
    properties (Dependent = true)
        colorVect
    end
    
    methods
        function this = MDRTColor(r, g, b, a)
            this.R = r;
            this.G = g;
            this.B = b;
            this.Alpha = a;
        end
        
%         function setCustom(red, green, blue)
%             % setCustom(r, g, b) allows the user to specify a color vector
%             % that is not covered by a pre-defined named color.
%             this.R = red;
%             this.G = green;
%             this.B = blue;
%         end
        
        function value = get.colorVect(this)
            value = [this.R, this.G, this.B];
        end
    end
    
    enumeration
        Red         (       1,       0,       0,       1 )
        Orange      (       1,     0.5,       0,       1 )
        Yellow      (       1,       1,       0,       1 )
        Green       (       0,       1,       0,       1 )
        Blue        (       0,       0,       1,       1 )
        Indigo      (  75/255,       0, 130/255,       1 )
        Purple      (     0.5,       0,     0.5,       1 )
        Violet      (     0.5,       0,     0.5,       1 )
        Magenta     (       1,       0,       1,       1 )
        Cyan        (       0,       1,       1,       1 )
        White       (       1,       1,       1,       1 )
        Black       (       0,       0,       0,       1 )
        
        Gray        (     0.5,     0.5,     0.5,       1 )
        DarkGray    ( 169/255, 169/255, 169/255,       1 )
        Silver      ( 192/255, 192/255, 192/255,       1 )
        LightGray   ( 211/255, 211/255, 211/255,       1 )
        
        LightBlue   (    0.67,    0.84,     0.9,       1 )
        SkyBlue     ( 135/255, 206/255, 250/255,       1 )
        
        LimeGreen   (  50/255, 205/255,  50/255,       1 )
        SpringGreen (   0/255, 255/255, 127/255,       1 )
        DarkGreen   (    0.42,    0.59,    0.24,       1 )
        
        Blueish     (  18/255, 104/255, 179/255,       1 )
        Reddish     ( 237/255,  36/255,  38/255,       1 )
        Greenish    ( 155/255, 190/255,  61/255,       1 )
        Purplish    ( 123/255,  45/255, 116/255,       1 )
        Yellowish   (       1, 199/255,       0,       1 )
        
        Gold        (       1, 215/255,       0,       1 )
    end
    
end

