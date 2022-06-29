classdef MDRTShape < handle
    %MDRTShape Class that draws and manages primitive shapes (fill objects)
    %   Detailed explanation goes here
    
    properties (SetObservable)
        scale    = 1        % Scale factor. 1 = 100%
        rotation = 0        % In degrees. 0 = "north"
        
        fillColor = MDRTColor('lightBlue') % MDRTColor object - shape fill
        edgeColor = MDRTColor('black')     % MDRTColor object - shape edges
        
        isDraggable = false
               
    end
    
    properties (SetAccess = protected)
        shape               % Handle to shape patch object
        XBaseData = []      % XData for shape before Transformation
        YBaseData = []      % YData for shape before Transformation
        
    end
    
    properties (SetAccess = protected, Hidden = true)
        XData               % XData for shape after transformation
        YData               % YData for shape after transformation
        dragCompletedCallback = []  % When populated, passed to draggable() to be called after buttonUp
    end
    
    properties (Constant)
        VALVE = [0  50  50 0 -50 -50  0;
                 0  25 -25 0 -25  25  0]';
    end
    
    
    methods
        function this = MDRTShape(varargin)
            % MDRTShape() creates an MDRTShape object for use in FGSE
            % displays. The default constructor, with no arguments, creates
            % a valve symbol at location [0,0]. Other shapes are not
            % supported through the constructor at this time, and the
            % MDRTShape XBaseData and YBaseData will need to be modified to
            % produce other shapes.
            %
            % Several key/value pairs are implemented to customize the
            % MDRTShape object at instantiation:
            %
            %   'Position'  - [x, y] sets the offset for the initial shape
            %   'FillColor' - Accepts an MDRTColor object
            %   'EdgeColor' - Accepts an MDRTColor object
            %   'Scale`     - A scalar multiplier for the vertices
            
            % Counts 2022
            
            offsetVect = [0, 0];
            
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
                    case {'position' 'center'}
                        offsetVect = val;
                    case 'fillcolor'
                        if isa(val, 'MDRTColor')
                            this.fillColor = val;
                        end
                    case 'edgecolor'
                        if isa(val, 'MDRTColor')
                            this.edgeColor = val;
                        end
                    case {'scale' 'scalefactor'}
                        if isnumeric(val)
                            this.scale = val;
                        end
                end
                
            end
            
            xOffset = offsetVect(1);
            yOffset = offsetVect(2);
            
            this.shape = fill(0 , 0, 'g');

            this.XBaseData = this.VALVE(:,1) + xOffset;
            this.YBaseData = this.VALVE(:,2) + yOffset;

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


        function this = set.isDraggable(this, canDrag)
            if ~islogical(canDrag)
                return
            end
            
            this.isDraggable = canDrag;
            
            if ~ canDrag
                draggable(this.shape, 'off')
                return
            end
            
            if isempty(this.dragCompletedCallback)
                draggable(this.shape);
            else
                draggable(this.shape, 'endfcn', this.dragCompletedCallback)
            end
        end

        
        function repositionByDragging(this, varargin)
            % initiates a one-time drag-n-drop reposition. On release, the 
            % shape base position is updated.
            
            if this.isDraggable
                % repositionByDragging is called after a click-drag
                this.dragCompletedCallback = [];
                this.isDraggable = false;
                this.rebaseShape;
                
            else
                % outside caller starts the "reposition" sequence
                this.dragCompletedCallback = @this.repositionByDragging;
                this.isDraggable = true;
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
            this.XBaseData = this.XData;
            this.YBaseData = this.YData;
        end
        
    end
    
end

