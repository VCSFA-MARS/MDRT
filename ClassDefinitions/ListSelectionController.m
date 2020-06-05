classdef ListSelectionController < handle
    %ListSelectionController 
    %   Detailed explanation goes here
    
    properties        
        
    end
    
    properties (SetAccess = protected)
        masterList
        hMasterListbox
        hSelectionListbox
        hSearchBar
    end
    
    methods
        function self = ListSelectionController(masterList)
        	% Constructor for ListSelectionController
            % Miniumum reqirement is a cell array of strings for the
            % 'master list'
            %
            
            self.masterList = masterList;
        end
        
        
        
        %% Set/Attach methods - Link view objects to the controller
        
        function self = attachMasterListbox(self, objHandle)
            if isa(objHandle, 'matlab.ui.control.UIControl')
                if ~strcmpi(objHandle.Style, 'listbox')
                    error('Wrong type: must be UIControl listbox');
                end
                self.hMasterListbox = objHandle;
            end
        end
        
        function self = attachSelectionListbox(self, objHandle)
            if isa(objHandle, 'matlab.ui.control.UIControl')
                if strcmpi(objHandle.Style, 'listbox')
                    self.hSelectionListbox = objHandle;
                end
            end
        end
        
        function self = attachSearchBar(self, objHandle)
            if isa(objHandle, 'matlab.ui.control.UIControl')
                if strcmpi(objHandle.Style, 'edit')
                    self.hSearchBar = objHandle;
                end
            end
        end
        
        
    end
    
end

