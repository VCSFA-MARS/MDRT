classdef EventTaggerView
    %eventTaggerView the GUI object for the eventTagger tool
    %   
    
    properties
        controller              % controller class object handle
    end
    
    
    methods
        function obj = EventTaggerView()
%             this.controller = controller;
            
            fig = figure;
            handles = struct;
            
            handles.editName    = uicontrol('style',          'edit', ...
                    'units',             	'normalized', ...
                    'position',             [ 0.4 0.9 0.4 0.09] );
                  
            handles.editFD      = uicontrol('style',          'edit', ...
                    'units',             	'normalized', ...
                    'position',             [ 0.4 0.8 0.4 0.09] );
                
            uicontrol('style', 'text', 'units', 'normalized', ...
                    'String',               'Event Name', ...
                    'position',             [ 0.1 0.9 0.3 0.09] );
                
            uicontrol('style', 'text', 'units', 'normalized', ...
                    'String',               'Event FD', ...
                    'position',             [ 0.1 0.8 0.3 0.09] );
                
            handles.table       = uitable( ...
                    'units',                'normalized', ...
                    'position',             [ 0.1 0.1 0.8 0.5]);
                      
        end % EventTaggerView - constructor
        
        
    end
    
       
    methods (Static)

    end
    
end

