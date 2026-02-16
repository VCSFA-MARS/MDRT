function [ hAaxes ] = MDRTSubplot( plotsHigh, plotsWide, gap, marginWidth, marginHeight )
%MDRTSubplot creates subplot axes for MDRT plotting tools
%   
%   MDRTSubplot( parentFigure )
%   MDRTSubplot( plotsHigh, plotsWide )
%   MDRTSubplot( plotsHigh, plotsWide, gap )
%   MDRTSubplot( plotsHigh, plotsWide, gap, marginWidth )
%   MDRTSubplot( plotsHigh, plotsWide, gap, marginHeight )
%   MDRTSubplot( plotsHigh, plotsWide, gap, marginWidth, marginHeight )
%
%   gap, marginWidth, and marginHeight are in normalized units.
%
%   returns an array of axes handles
%
%   calling MDRTSubplot without gap, marginW

ENABLE_NEW_UI = false;

%	Default page setup for landscape US Letter
        defaultNumperOfPlots = 1;
        defaultPlotGap = 0.05;
        defaultPlotMargin = 0.06;
        parent_figure = [];
              
% Handle input arguments
    if (nargin == 1 && isa(plotsHigh, 'matlab.ui.Figure'))
      parent_figure = plotsHigh; 
      plotsHigh = defaultNumperOfPlots;
      plotsWide = 1;
        
    end
        
    if nargin < 3; gap = defaultPlotGap; end
    if nargin < 4 || isempty(marginWidth); marginWidth = defaultPlotMargin; end
    if nargin < 5; marginHeight = .05; end

% Handle vectorized gap and margin inputs
    
    if numel(gap)==1; 
        gap = [gap gap];
    end

    if numel(marginHeight)==1; 
        marginHeight = [marginHeight marginHeight];
    end

    if numel(marginWidth)==1; 
        marginWidth = [marginWidth marginWidth];
    end

axheight = (1-sum(marginWidth)  - (plotsHigh-1) * gap(1)) / plotsHigh; 
axwidth  = (1-sum(marginHeight) - (plotsWide-1) * gap(2)) / plotsWide;

yPos = 1 - marginWidth(2) - axheight; 

% Default Axes Properties
axes_properties = {
  'Units','normalized',     ...
  'XTickLabel','',          ...
  'YTickLabel','',          ...
  'NextPlot', 'add',        ...
  'XGrid','on',             ...
  'XMinorGrid','on',        ...
  'XMinorTick','on',        ...
  'YGrid','on',             ...
  'YMinorGrid','on',        ...
  'YMinorTick','on',        ...
  'YTickLabelMode', 'auto', ...
  'Box', 'on',              ...
  'Tag', 'MDRTAxes' 
  }

if ~isempty(parent_figure)
  axes_properties = horzcat({'Parent', parent_figure}, axes_properties);
end

% Init empty cell array of axes handles
hAaxes = {};
ii = 0;
for ih = 1:plotsHigh
    xPos = marginHeight(1);
    
    for ix = 1:plotsWide
        ii = ii+1;
        if matlab_newer_than('2017a') && ENABLE_NEW_UI
          hAaxes = vertcat(hAaxes, ...
            uiaxes( 'Position',[xPos yPos axwidth axheight], ...
            axes_properties{:} )) ;
        else
          hAaxes = vertcat(hAaxes, ...
            axes( 'Position',[xPos yPos axwidth axheight], ...
            axes_properties{:} )) ;
        end 
            
        xPos = xPos+axwidth+gap(2);
    
    debugout('Created MDRT Subplot axes')
    
    end
    yPos = yPos-axheight-gap(1);
end
        
        
        
end

