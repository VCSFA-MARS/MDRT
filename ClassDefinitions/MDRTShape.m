classdef MDRTShape < handle
    %UNTITLED4 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetObservable)
        position = [0, 0]   % Typically center (x,y)
        scale    = 1        % Scale factor. 1 = 100%
        rotation = 0        % In degrees. 0 = "north"
        
    end
    
    properties (SetAccess = protected)

        shape               % Handle to shape patch object
        
        
        
        XBaseData = []      % XData for shape before Transformation
        YBaseData = []      % YData for shape before Transformation
        
        listener_draggable
        listener_position
    end
    
    properties 
        XData               % XData for shape after transformation
        YData               % YData for shape after transformation
    end
    
    properties (Constant)
        VALVE = [0  50  50 0 -50 -50  0;
                 0  25 -25 0 -25  25  0]';
    end
    
    
    methods
        function this = MDRTShape()
            this.shape = fill(0, 0, 'g') ;

            this.XBaseData = this.VALVE(:,1);
            this.YBaseData = this.VALVE(:,2);
            
            this.listener_position  = addlistener(this, 'position', 'PostSet', @updateShape);

            updateShape(this, []);
            redrawShape(this, []);
            
        end
        
        function this = set.rotation(this, angle)
            this.rotation = angle;
            this.updateShape;
            redrawShape(this, []);
        end
        
        function this = set.scale(this, scale)
            this.scale = scale;
            this.updateShape;
            redrawShape(this, []);
        end
        
        function this = updateShape(this, varargin)
            
            % Perform Shape Transforms as needed
            
            R = [cosd(this.rotation) -sind(this.rotation); 
                 sind(this.rotation)  cosd(this.rotation)];
             
            V = this.scale .* horzcat(this.XBaseData, this.YBaseData)';
            C = repmat([0 0], length(this.XBaseData), 1)';
            V = R*(V-C) + C;
            
            this.XData = V(1,:)';
            this.YData = V(2,:)';
            
        end
        
        function redrawShape(this, varargin)
            this.shape.XData = this.XData;
            this.shape.YData = this.YData;
        end
    end
    
end

