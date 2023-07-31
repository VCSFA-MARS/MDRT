classdef MDRTValveBarLabel < handle
    %MDRTValveBarLabel is a graphics object that displays a "floating"
    %valve label, auto-updating with axes limit changes
    %
    % MDRTValveBarLabel(hax, label_texts, y_values)
    % 
    %      hax         - axes handle
    %      label_texts - cell array of strings
    %      y_values    - matrix of y-values (vertical position)
     
    
    properties
        hax
        label_text
        y_value
        x_value
        
        x_margin = 0.025
        
        textobj
        listener
    end
    
    methods
        function self = MDRTValveBarLabel(hax, label_text, y_value)
            self.hax = hax;
            self.label_text = label_text;
            self.y_value = y_value;
            
            num_ticks = numel(y_value);
            
            x_pos = self.x_margin * diff(hax.XLim) + min(hax.XLim);
            
            self.textobj = text(x_pos * ones(num_ticks,1), ...
                                y_value, ...
                                label_text);
                            
            self.setXPos(x_pos);
            self.listener = addlistener(hax.XRuler,'MarkedClean',@(~,~) self.cleanListen);
            
        end
    
        function self = setXPos(self, newPosition)
            for n = 1:numel(self.textobj)
                self.textobj(n).Position(1) = newPosition;
            end
        end
        
        
        function cleanListen(self)
            x_pos = self.x_margin * diff(self.hax.XLim) + min(self.hax.XLim);
            self.setXPos(x_pos);
            
        end
        
    end
        
        
    
end

