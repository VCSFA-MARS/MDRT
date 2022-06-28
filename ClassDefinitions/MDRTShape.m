classdef MDRTShape < handle
    %MDRTShape Class that draws and manages primitive shapes (fill objects)
    %   Detailed explanation goes here
    
    properties (SetObservable)
        position = [0, 0]   % Typically shape's center (x,y)
        scale    = 1        % Scale factor. 1 = 100%
        rotation = 0        % In degrees. 0 = "north"
        
        fillColor = MDRTColor('lightBlue') % MDRTColor object - shape fill
        edgeColor = MDRTColor('black')     % MDRTColor object - shape edges
        
        draggable = false
               
    end
    
    properties (SetAccess = protected)
        shape               % Handle to shape patch object
        
        XBaseData = []      % XData for shape before Transformation
        YBaseData = []      % YData for shape before Transformation
        
        listener_draggable
        listener_position
    end
    
    properties (SetAccess = protected, Hidden = true)
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

            this.updateShape;
            this.redrawShape;
            
        end
        
        function this = set.rotation(this, angle)
            this.rotation = angle;
            this.updateShape;
            this.redrawShape;
        end
        
        function this = set.scale(this, scale)
            this.scale = scale;
            this.updateShape;
            this.redrawShape;
        end
        
        function this = set.fillColor(this, color)
            this.fillColor = color;
            this.redrawShape;
        end
        
        function this = set.edgeColor(this, color)
            this.edgeColor = color;
            this.redrawShape;
        end
        
        function this = set.draggable(this, canDrag)
            if ~islogical(canDrag)
                return
            end
            
            this.draggable = canDrag;
            if canDrag
                draggable(this.shape);
            else
                draggable(this.shape, 'off')
            end
        end
            
        
        function updateShape(this, varargin)
            % updateShape() applies the transformation properties to the
            % base coordinates, updating the XData and YData properties.
            % This function DOES NOT update the underlying patch object or
            % trigger a redraw.
            
            % Perform Shape Transforms as needed
            
            R = [ cosd(this.rotation)   -sind(this.rotation); 
                  sind(this.rotation)    cosd(this.rotation); ];
             
            V = this.scale .* horzcat(this.XBaseData, this.YBaseData)';
            C = repmat([0 0], length(this.XBaseData), 1)';
            V = R*(V-C) + C;
            
            this.XData = V(1,:)';
            this.YData = V(2,:)';
            
        end
        
        function redrawShape(this, varargin)
            % redrawShape() updates the XData and YData (vertices) of the
            % underlying patch object from the MDRTShape XData and YData 
            % properties and triggers a redraw.
            
            this.shape.XData = this.XData;
            this.shape.YData = this.YData;
            
            this.shape.EdgeColor = this.edgeColor.colorVect;
            this.shape.EdgeAlpha = this.edgeColor.Alpha;
            this.shape.FaceColor = this.fillColor.colorVect;
            this.shape.FaceAlpha = this.fillColor.Alpha;
            
        end
        
        
        function rebaseShape(this, varargin)
            % rebaseShape() sets the base coordinates of the shape to the
            % current transformed coordinates. Use this to make a rotation
            % or translation "permanenet" so you can base future
            % modifications on the current position.
            
            this.updateShape
                        
        end
        
    end
    
end

