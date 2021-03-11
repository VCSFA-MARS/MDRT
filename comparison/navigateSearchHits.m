function navigateSearchHits( hobj, event, searchBarHandle, varargin )

%navigateSearchHits allows arrow key browsing and selection of searchbox
%popup results
%
%   Expects to be set as a callback on a uicontrol of type 'listbox' with 
%   the tag 'listSearchResults'
%
%   Will be called with a handle to the associated searchbar, which will
%   become the target for the function. If a result is selected
%   (user highlighted and pressed enter) then the result string will be
%   placed in the searchbar.
%
%   Example:
%         hs.hitsbox = uicontrol(hs.fig,                                      ...
%                 'Style',                'listbox',                          ...
%                 'Tag',                  'listSearchResults',                ...
%                 'KeyPressFcn',          {@navigateSearchHits, hs.searchBar},...
%                 'units',                'normalized',                       ...
%                 'position',             [0.05 0.2 0.9 0.55]);
%

ONE_SEC = 1/(60*60*24);
SINGLE_PRESS_TIMESPAN = 0.05 * ONE_SEC ;

thisTime = now;

persistent lastTime    
    if isempty(lastTime) || thisTime-lastTime > SINGLE_PRESS_TIMESPAN
        lastTime = thisTime;
        % process a "single-click"
        
    else
        % process a "double-click"
        % ignore doubles (debounce)
        return
    end
        

    
if strcmpi(event.Key, 'uparrow') && (hobj.Value == 1)
    % User is navigating back to the search bar!
    uicontrol(searchBarHandle);
    
    % Set cursor to the end of the search bar
    lengthOfSearchTerm = length(searchBarHandle.String{1}); % Returned as a cell for some reason?
    jobj = findjobj(searchBarHandle);
    jobj.select(lengthOfSearchTerm, lengthOfSearchTerm);
    
    return
end

if strcmpi(event.Key, 'return')
    
    searchBarHandle.String = hobj.String(hobj.Value);
    hobj.Visible = 'off';
    
    uicontrol(hobj);
    % Set cursor to the end of the search bar
    lengthOfSearchTerm = length(searchBarHandle.String{1}); % Returned as a cell for some reason?
    jobj = findjobj(searchBarHandle);
    jobj.select(lengthOfSearchTerm, lengthOfSearchTerm);
    
end


