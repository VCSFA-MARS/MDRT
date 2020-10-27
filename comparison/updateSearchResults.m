function updateSearchResults(hObj, event, varargin)

%updateSearchResults 
%
%   Accepts a handle to any uicontrol.
%
%   Expects one uieditbox with a tag 'searchBox'
%   Expects one uilistbox with a tag 'listSearchResults'
%   Expects appdata from the calling app/gui called 'fdMasterList'
%
%   If using more than one searchBox/list in a GUI, set the UserData
%   property in the searchBox object to the handle of the listbox. 
%
%   NOTE: Tag-based object cooperation is deprecated. Use the UserData
%   property from now on.
%
%   Controls the uilist box as a "pop-up" when results are found if called
%   with the parameter 'popup'
%
%   Example:
%         hs.searchbar = uicontrol(       hs.fig,...
%                 'Style',                'edit',...
%                 'String',               '',...
%                 'HorizontalAlignment',  'left',...
%                 'KeyReleaseFcn',        {@updateSearchResults, 'popup'},...
%                 'Units',                'normalized', ...
%                 'Position',             [ 0.05 0.8 0.9 0.1 ],...
%                 'tag',                  'searchBox');
%
%       hs.searchbar.UserData = 'hs.handleToListBox';
%         
%   Counts, VCSFA 2016
    
    % Turn on "popup" behavior ?
    shouldHideEmptyListbox = false;
    if ~ isempty(varargin)
        switch lower(varargin{1})
            case {'popup'}
                shouldHideEmptyListbox = true;
            otherwise
        end
    end
    
    hDataHolder = hObj;
    
    while ~isappdata(hDataHolder, 'fdMasterList')
        hDataHolder = hDataHolder.Parent;
    end
    
    masterList = getappdata(hDataHolder, 'fdMasterList');
    masterList = masterList(:,1);

    
% get handle to the list of search results
    if isempty(hObj.UserData)
        lsr = findobj(hDataHolder,'tag', 'listSearchResults');
    else
        lsr = hObj.UserData;
    end
    
    % get handle to the search box (for sure!)
%     hebox = findobj(hDataHolder, 'tag', 'searchBox'); % Why did I search
%     instead of using the hObj handle?
    
    
    % Access the Java object to get the stupid text. Why, Matlab? Why?
%     ebh = findjobj(hebox);
    ebh = findjobj(hObj);
    searchString =  char(ebh.getText);
    
    % TODO: Modify search to allow multiple search tokens in any order.
    % Break abart using whitespace and assemble indeces for each token?
   
        searchToks = strsplit(searchString);

        % searchToks = {'RP1';'Tur'};

        % remove stray whitespace
        searchToks = strtrim(searchToks);
        searchToks(strcmp('',searchToks)) = [];

        % start with empty match index variable
        ind = [];

        % create an index of matches for each token
        for i = 1:numel(searchToks)

            ind = [ind, cellfun(@(x)( ~isempty(x) ), regexpi(masterList, searchToks{i}))];

        end 
        % combine matches (and searching, not or)
        ind = logical(prod(ind,2));

  
   
   if ~isempty(searchString)
       % Make sure lsr is visible whenever there is a match
       lsr.Visible = 'on';
       uistack(lsr, 'top');
       
       % A non-empty search string means search!
       if length(masterList(ind)) >= lsr.Value
           % selected an item in the new list
           % lsr.Value = length(masterList(ind));
           % lsr.String = masterList(ind);
       elseif ~length(masterList(ind))
           % New results are empty!
           lsr.Value = 1;
       else
           % Selection is outside new (nonzero)result list
           lsr.Value = length(masterList(ind));
       end
       
           lsr.String = masterList(ind);
   else
       if shouldHideEmptyListbox
           % No search string means return nothing and hide!
           lsr.String = '';
           lsr.Visible = 'off';
       else
           % No search string means return everything
           lsr.String = masterList;
       end
   end
   
   % Handle arrow keys to navigate hits if using "popup" option
   
   if shouldHideEmptyListbox && numel(lsr.String)
       % Using popup behavio and there are search hits displayed
        switch lower(event.Key)
            case 'downarrow'
                % Set focus on popup list if results are present!
                if ~isempty(lsr.String)
                    uicontrol(lsr);
                end
            case 'uparrow'
            case 'return'
            otherwise
                % disp(event.Key)
        end
   end
   
   
   
end