classdef EventTagger
    %eventTagger the control class for the eventTagger tool
    %   create a new eventTagger object to launch the tool
    
    properties
        view        % view handle
        model       % model handle
        dcm         % DataCursorManager
        origTipFcn  % original data tip update function
    end
    
    properties (SetAccess = immutable)
        fig        % figure handle - where is the plot we're tagging?
    end
    
    
    methods
        function this = EventTagger(fig, model)
            if ~exist('fig', 'var')
                fig = gcf;
            end
            this.fig = fig;
            
            if ~exist('model', 'var')
                model = EventTaggerModel;
            end
            this.model = model;
            
            this.view = EventTaggerView();
            this.dcm = datacursormode(fig);
            this.origTipFcn = this.dcm.UpdateFcn;                                                       % Store existing datetip update function
            this.dcm.UpdateFcn = @(hObj, event, this)this.dateTipInterceptCallback(hObj, event, this);  % Redirect date tip function to class method
            
            
        end
        
        
        function output_txt = dateTipInterceptCallback(obj,event_obj, this)
            keyboard
            output_txt = '';
            
            % update the model with all the data tip values
            this.model.setCursorInfo(this.dcm.getCursorInfo);
            
            % run the "real" dataTipCallback
            output_txt = this.origTipFcn(obj, event_obj);
            
        end
        
    end
    
end

