classdef MDRTListBox < matlab.ui.componentcontainer.ComponentContainer
  %% MDRTListBox implements a listbox with a search field.
  % Instantiate the MDRTListBox with a parent UIContainer
  % Set the display and return item lists
  % Set the ValueChangedCallbackFcn if needed
  % Access the currently selected item via .Value
  
  properties
    edit_field        matlab.ui.control.EditField
    list_box          matlab.ui.control.ListBox
    
    master_list     = {}
    display_items   = {}
    return_items    = {}
    ind_match       logical
    
    grid              matlab.ui.container.GridLayout
  end
  
  properties (Access = private)
    last_ind        = []
    this_ind        = []
  end
  
  events (HasCallbackProperty, NotifyAccess = protected)
    SelectionChanged    % Callback for user selecting an item from the listbox
  end
  
  methods
    %% Constructor is taken care of by super class!
    %  My constructor was generating an extra UIFigure
    function self = set_items(self, display_items, return_items)
      if size(display_items) ~= size(return_items)
        error('display_items and return_items must be the same size')
      end
      
      self.display_items = display_items;
      self.return_items = return_items;
      
      self.list_box.Items = self.display_items;
      self.list_box.ItemsData = find(true(size(self.display_items)));
      self.do_search([],[]  );
    end
    
    
    
  end
  
  methods (Access = protected)
    
    function self = do_search(self, ~, event)
      if isempty(event)
        search_str = self.edit_field.Value;
      else
        search_str = event.Value;
      end
      
      search_toks = strsplit(search_str);
      search_toks = strtrim(search_toks);
      search_toks(strcmp('', search_toks)) = []; % remove empty
      
      ind = true(size(self.display_items));
      
      for i = 1:numel(search_toks)
        ind = logical(prod( ...
          [ind, cellfun(@(x)(~isempty(x)), ...
          regexpi(self.display_items, search_toks(i) ))], 2 ...
          ));
      end
      
      self.ind_match = ind;
      
      % Set the listbox contents here?
      self.list_box.Items = self.display_items(self.ind_match);
      self.list_box.ItemsData = find(self.ind_match);
    end
    
    
    function self = update(self)
      % self.do_search([], []);
      self.Units = 'normalized';
      self.Position = [0 0 1 1];
      
      self.grid.ColumnWidth = {'1x'};
      self.grid.RowHeight = {'fit', '1x'};
    end
    
    function self = setup(self)
      
      self.grid = uigridlayout(self, [2,1], ...
        'RowHeight',          {'fit', '1x'}, ...
        'ColumnWidth',        {'1x'} );
      
      self.edit_field = uieditfield(self.grid);
      self.edit_field.ValueChangingFcn = @self.do_search;
      self.list_box = uilistbox(self.grid, 'Items', {}, 'ValueChangedFcn', @self.ListBoxSelectionChanged);
    end
    
    function self = ListBoxSelectionChanged(self, ~, event)
      % Callback function triggered by user clicking/selecting a list item
      % from the listbox. Sets the this/last selection properties and triggers
      % the callback notification.
      
      self.last_ind = event.PreviousValueIndex;
      self.this_ind = event.ValueIndex;
      
      notify(self, 'SelectionChanged');
    end
  end
  
  
  methods
    function val = Value(self)
      %% Value - returns the user-selected item's corresponding 'return_items' entry
      if isempty(self.list_box.Value)
        val = {};
        return
      end
      ind = self.list_box.Value;

      switch class(self.return_items)
        case 'table'
          val = self.return_items(ind,:);
        otherwise
          val = self.return_items{ind};
      end
      
      return
    end
    
    
    function val = PreviousValueIndex(self)
      val = self.last_ind;
      return
    end
    
    function val = PreviousValue(self)
      if isempty(self.last_ind) || self.last_ind > length(self.return_items)
        val = {};
        return
      end
      
      val = self.return_items{self.last_ind};
      return
    end
    
    
  end
  
end

