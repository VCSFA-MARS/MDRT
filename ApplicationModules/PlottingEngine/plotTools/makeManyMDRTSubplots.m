function [subPlotAxes,  varargout] = makeManyMDRTSubplots(InputTitleArray, FigureTitleString, varargin )
%% This function generates multiple figures and subplots, automatically
%   dividing and spacing subplots based on user configuration.
%
%   The default is 3 subplots wide, and 2 high per figure. Returns an array
%   of axes handles in the following order
% 
%      ________ figure 1 _________
%     |    _______     _______    |
%     |   |   1   |   |   2   |   |
%     |   |_______|   |_______|   |
%     |    _______     _______    |
%     |   |   3   |   |   4   |   |
%     |   |_______|   |_______|   |
%     |___________________________|
% 
%      ________ figure 2 _________
%     |    _______     _______    |
%     |   |   5   |   |   6   |   |
%     |   |_______|   |_______|   |
%     |    _______     _______    |
%     |   |   7   |   |   8   |   |
%     |   |_______|   |_______|   |
%     |___________________________|
% 
% 
%   axHandles = makeManyMDRTSubplots( numberOfPlots );
%   axHandles = makeManyMDRTSubplots( subplotTitleArray );
%   [axHandles, figHandles] = makeManyMDRTSubplots( ...)
%   [axHandles, figHandles, axPairArray] = makeManyMDRTSubplots( ...)
%
%   Supported Name/Value parameters
%
%       newStyle        true or false - true to use MDRTAxes. Default is false
%       plotsWide       numeric - how many subplots across the figure. Default is 3
%       plotsHigh       numeric - how many subplots down the figure. Default is 2
%       legendFontSize  numeric - set the legend font size
%       gap             numeric - set the gap between subplots (normalized units)
%       margin          numeric - set the margin between subplots and figure (normalized units)
%       groupAxesBy     numeric - the grouping for the 'axPairs' array. Default is 2
%       mdrtpairs       true or fales - use true to return MDRTAxes pairs. Default is false
%       graphStruct     graph structure - pass the MDRT graph struct to be added as appdata for other tools
%       graphNumber     graph number - the index/number of the graph config structure
%
%
%   EXAMPLE:
%
%       makeManyMDRTSubplots({'valve 1', 'valve 2', 'valve 3', 'valve 4'}, ...
%                            'figure title', 'plotsWide', 2)
%
%       [hax, ~, hap] = makeManyMDRTSubplots(8, 'Demo Plots', 'plotsWide', 4)


%% Input Parameters

% InputTitleArray = {'valve 1', 'valve 2', 'valve 3', 'valve 4', 'valve 5', 'valve 6', 'valve 7', 'valve 8'};
% FigureTitleString = '';
if nargin == 1;
    FigureTitleString = [];
end

if exist('InputTitleArray', 'var') && iscellstr(InputTitleArray)
    expectedSubplots = numel(InputTitleArray);
elseif exist('InputTitleArray', 'var') && isnumeric(InputTitleArray)
    expectedSubplots = InputTitleArray;
end
    


AxesTitles = cell(expectedSubplots, 1);

    % Handle Figure Titles
        if isempty(FigureTitleString)
            FigureTitleFormatString = '%sPage %d';
        else
            FigureTitleFormatString = '%s - Page %d';
        end

        if iscellstr(FigureTitleString)
            FigureTitleString = FigureTitleString{1};
        end

if mod(numel(varargin),2)
    % Name/value pairs not passed in pairs! Expect even number of arguments
    error('Expected even number of arguments. Parameters must be passed in Name/Value pairs');
end









%% Plot Setup

USE_MDRTAxes = false;
RETURN_MDRTAxes_Pairs = false;
APPEND_GRAPH_STRUCT = false;
graphStruct = [];
graphNum = [];
graphsPlotGap = 0.05;
GraphsPlotMargin = 0.06;
numberOfSubplots = 1; % Change this to define the groupings! (Shouldn't be larger than spHigh)

legendFontSize = 8;
spWide = 3;
spHigh = 2;

reshapeParam = 2;

for K = 1:2:numel(varargin)

    Key = lower(varargin{K});
    Val = varargin{K+1};
    
    switch Key
        case 'newstyle'
            USE_MDRTAxes = Val;
        case 'plotswide'
            spWide = Val;
        case 'plotshigh'
            spHigh = Val;
        case 'legendfontsize'
            legendFontSize = Val;
        case 'gap'
            graphsPlotGap = Val;
        case 'margin'
            GraphsPlotMargin = Val;
        case 'groupaxesby'
            reshapeParam = Val;
        case 'mdrtpairs'
            RETURN_MDRTAxes_Pairs = true;
        case {'graphstruct' 'graph'}
            APPEND_GRAPH_STRUCT = true;
            graphStruct = Val;
        case {'graphnumber' 'graphnum'}
            graphNum = Val;

    end
end




%% Instantiate plot array variables

fig = [];
subPlotAxes = [];
subOffset = [];
axPairs = [];
axPair = [];
figCount = 1;



%% Calculate Figures and Subplots

totalFigures = ceil(expectedSubplots / (spWide * spHigh) );


%% Create Figures and Subplots

if expectedSubplots > spWide
    remainder = expectedSubplots;
    while remainder > 0
        f = makeMDRTPlotFigure;
        debugout(sprintf('Creating figure %d', f.Number))
        
        fig = vertcat(fig, f);
        
        if remainder >= spWide
            plotCols = spWide;
        else
            plotCols = remainder;
        end
        
        if USE_MDRTAxes
            [spa, MDRA] = CMDRTSubplot( spHigh, plotCols,	graphsPlotGap, ... 
                                GraphsPlotMargin,   GraphsPlotMargin);
        else
            spa = MDRTSubplot(  spHigh, plotCols,	graphsPlotGap, ... 
                                GraphsPlotMargin,   GraphsPlotMargin);
        end
                            
        FigTitleString = sprintf(FigureTitleFormatString, FigureTitleString, figCount);
        debugout(sprintf('Generating %s', FigTitleString))
        suptitle(FigTitleString);
        figCount = figCount + 1;
        
        debugout(sprintf('Adding %d subplot axes', length(spa)))
        subPlotAxes = vertcat(subPlotAxes, spa);   
        
        if spHigh > reshapeParam
            numOfGroups = numel(spa) / reshapeParam;
            axPair = reshape(reshape(spa,numOfGroups,reshapeParam)', numOfGroups,reshapeParam);
            if USE_MDRTAxes && RETURN_MDRTAxes_Pairs
                
                axPair = reshape(reshape(MDRA,numOfGroups,reshapeParam)', numOfGroups,reshapeParam);
            end
        else
            axPair = reshape(spa, plotCols*spHigh/reshapeParam, reshapeParam);
            
            if USE_MDRTAxes && RETURN_MDRTAxes_Pairs
                axPair = reshape(MDRA, plotCols*spHigh/reshapeParam, reshapeParam);
            end
        end
        
        axPairs = vertcat(axPairs, axPair);
        
        % remainder = remainder - spWide; % Modify this to make vertical pairs
        remainder = remainder - (spWide * spHigh);
        debugout(sprintf('Remainder = %d', remainder))
        
        subOffset = length(expectedSubplots);
    end
    
else
    % NOTE: This code DOES NOT WORK for 2 stop flow events! Must correctly
    % implement the generation of the axPairs array
    fig = makeMDRTPlotFigure;
    
    subPlotAxes = MDRTSubplot(spHigh,       length(expectedSubplots), ... 
                        graphsPlotGap,      GraphsPlotMargin, ...
                        GraphsPlotMargin);
                    
    axPairs = reshape(subPlotAxes, length(expectedSubplots)*spHigh/reshapeParam, reshapeParam);
	suptitle(FigureTitleString);
end



if APPEND_GRAPH_STRUCT
    for nfig = 1:length(fig) 
        if USE_MDRTAxes
            adTarget = fig(nfig).hfig;
        else
            adTarget = fig(nfig);
        end
        setappdata(adTarget, 'graph',          graphStruct);
        setappdata(adTarget, 'graphNumber',    graphNum);
    end
end



switch nargout
    case 2
        varargout{1} = fig;
    case 3
        varargout{1} = fig;
        varargout{2} = axPairs;
    otherwise
end











