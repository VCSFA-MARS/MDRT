classdef MDRTValve < handle
    %MDRTValve annotation object for displaying valve states
    %   Detailed explanation goes here
    
    properties
        
        isOpen = true;
        isEnergized = false;
        energizedState = 'closed'
        findNumber = 'DCVNC-1234'
        color = 'g';
        iconPoint = [0, 0];
        iconPosition = [0 0 10 10];
        
        valveState;         % Open or closed state. Updated from data
        
        parentAx;           % Handle of the parent axes
        scaleFactor = 1;
        colorOpen;          % Icon fill color when open [r, g, b]
        colorClosed;        % Icon fill color when closed [r, g, b]
        colorBorder;        % Icon border color [r, g, b]        
        centerPoint;        % [x,y] coordinates of the center of the valve icon
        
        hFill;              % handle to the patch object. For internal use
        
    end
    
    methods
        
        function self = MDRTValve(parentAxes, centerPoint, isHorizontal, varargin)
        % MDRTValve is the constructor for the MDRTValve() class
        %
        %
        %   parentAxes      hAxes - The axes on which the valve will be
        %   displayed
        %   centerPoint     [x,y] - the center point of the valve icon
        %   isHorizontal    true/false - assumed true. False if vertical
        
        
            optionStrings = {
                'centerPoint',  [0,0];
                'orientation',  {'horiz', true;
                                 'vert', false;
                                 'horizontal', true;
                                 'vertical', false};
                'colorOpen',    [0, 1, 0];
                'colorClosed',  [1, 0, 0];
                'colorBorder',  [1, 1, 1];
                'scaleFactor',  1;
                'cornerPoint',  [20, 15]
            };
            
            if ~isequal('matlab.graphics.axis.Axes', class(parentAxes))
                error('MDRTValve requires a parent axes argument')
            end
            
            self.parentAx = parentAxes;
            self.centerPoint = centerPoint;
            
            
        end
        
        
        
        function drawValve(self)
        % drawValve plots the valve object on the parent axes.
        % Relying on honest users to only call this once!
        
            valveX = [0 50  50 0 -50 -50 0];
            valveY = [0 25 -25 0 -25  25 0];

            axes(self.parentAx);
            hold on;

            x = valveX * self.scaleFactor + self.centerPoint(1);
            y = valveY * self.scaleFactor + self.centerPoint(2);

            self.hFill = fill(x, y, 'g');

        end
        
        
        function updateFromData(self, data)
            
            
        end
        
    
    end
    
end

