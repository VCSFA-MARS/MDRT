function [ figureHandle ] = makeMDRTPlotFigure( graph, graphNumber )
%makeMDRTPlotFigure creates a new figure window with the MDRT toolbars and
%menus and returns the figure handle.
%
%   figHandle = makeMDTRPlotFigure
%   figHandle = makeMDRTPlotFigure ( graph )
%
%   If passed a graph structure, it will be added to the figure's appdata
%   structure. If passed a graph number, it will also be added

% TODO:
% Allowable commands for the future?
%
% MDRTToolbar, on, off
% MDRTAdvanceMenu, on, off
% FigureOptions, cellArrayOfValidKeyValuePairs

passGraph = true;
if ~nargin
    passGraph = false; 
end


% -------------------------------------------------------------------------
% Generate new figure and handle. Set up for priting
% -------------------------------------------------------------------------
    
    figureHandle = figure();
    debugout(sprintf('Created MDRtFigure: %d', figureHandle.Number))
    
    % Add graph structure to appdata
    if  passGraph
        setappdata(figureHandle, 'graph', graph);
        setappdata(figureHandle, 'graphNumber', graphNumber);
    end
    
    saveButtonHandle = findall(figureHandle,'ToolTipString','Save Figure');
    
    set(saveButtonHandle, 'ClickedCallback', 'MARSsaveFigure');
    
    % Add label size toggle and timeline refresh buttons
    addToolButtonsToPlot(figureHandle);
    
    addAdvancedMenuToPlot(figureHandle);
    
    % Set plot/paper size and orientation if needed
    orient('landscape');
    
    % Hide File/Save as
    hMenuSaveAs = findall(gcf,'tag','figMenuFileSaveAs');
    hMenuSaveAs.Visible = 'off';
    
    % Override File/Save(as)
    hMenuSave   = findall(gcf,'tag','figMenuFileSave');
    set(hMenuSave, 'Callback', 'MARSsaveFigure');
    
    debugout('Overridden default Save and added Advanced menu')
    

end

