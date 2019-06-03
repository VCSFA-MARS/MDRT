function dataChangeTool(hobj, event, varargin)

    hfig = hobj.Parent.Parent;
    apdata = getappdata(hfig);
    
    numplots = numel(apdata.graph.subplots);
    
    
    %% Prompt user to place time markers
    
    start = datenum('04-17-2019 20:44:25');
    stop = datenum('04-17-2019 20:46:07');
    
    dcm_obj = datacursormode(hfig);
    q = getCursorInfo(dcm_obj);
    
    if numel(q) ~= 2
        % Display dilog - otherwise, they already placed 2 markers!
        uiwait(msgbox('Place two Data Cursors on the plot, marking the start and stop time for the data search'));
    end
    
    q = getCursorInfo(dcm_obj);
    
    % Protect against wrong number of data cursors
    if numel(q) ~= 2
        % Display dilog - otherwise, they already placed 2 markers!
        debugout('User did not place 2 data cursors');
        return
    end
    
    t = sortrows(reshape([q.Position],2,2)', 1);
    
    
    %% Prompt user to select axis to "modify"
    
    hax = findobj(hfig, 'Type', 'axes', '-not', 'Tag', 'suptitle');
    haxt = [hax.Title];
    titles = [haxt.String];
    
    [indx,tf] = listdlg('PromptString', 'Select axis', 'SelectionMode', 'Single', 'listString', titles)
    
    if isempty(indx)
        return
    end
    
    ax = hax(indx);
    
    %% Prompt user to select data stream to change
    
    hlins = findobj(ax, 'Type', 'line', ...
                        '-or',  'Type', 'stair', ...
                        '-not', 'Tag',  'vline', ...
                        '-not', 'Type', 'Axes');
    
    lines = [hlins.DisplayName];
    [indx,tf] = listdlg('PromptString', 'Select FD to vary', 'SelectionMode', 'Single', 'listString', lines)
    
    if isempty(indx)
        return
    end
    
    hlin = hlins(indx);
    
    tsarray = getDataInTimeInterval(t(1,1), t(2,1));
    dataNames = {tsarray.Name}';
    
    hmf = figure;
    hlb = uicontrol('Style', 'listbox', ...
                    'String', dataNames, ...
                    'Units', 'normalized', ...
                    'Position', [0.1 0.1 0.8 0.8],...
                    'Callback', @clickedList);
    
	
    %% Listbox callback - update the selected plot object!
    function clickedList(hobj, event)
        
        xl = xlim(ax);
        yl = ylim(ax);
        
%         tsarray(hobj.Value).Name
%         tsarray(hobj.Value).Time
%         tsarray(hobj.Value).Data
        
        set(hlin, 'XData', tsarray(hobj.Value).Time, 'YData', double(tsarray(hobj.Value).Data))        
        hlin.DisplayName = tsarray(hobj.Value).Name;
        
        xlim(ax, xl);
        
    end




end