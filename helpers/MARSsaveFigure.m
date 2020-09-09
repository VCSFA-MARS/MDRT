function MARSsaveFigure(varargin)
% MARSsaveFigure is a script for overriding the default save button
%
%   Gets the current graphics context, looks for a suptitle object and
%   generates an automatic name for saving MARS Data Plots.
%
%   Current version uses getConfig
%
%   Counts, Spaceport Support Services, 2014

%   Counts, VCSFA, 2017 - updated to be more fault tolerant. Fixed
%   documentation

%   Counts, VCSFA, 2020 - convert to function for improved fault tolerance.

config = getConfig;

if nargin == 3
    switch class(varargin{3})
        case 'matlab.ui.Figure'
            fh = varargin{3};
        otherwise
            msg = sprintf('Argument of type %s is unsupported. Defaulting to gcf()', class(varargin{3} ) );
            warning(msg);
            fh = gcf;
    end
else
    fh = gcf;
end


%% Intelligent filename guess based on plot super title

% Find handle to supertitle object and extract string
sth = findobj(fh,'Tag','suptitle');

if size(sth) == 0
    graphTitle = 'MDRT_Plot';
else
    graphTitle = sth.Children.String;
end

% clean up unhappy reserved filename characters
%     defaultName = regexprep(UserData.graph.name,'^[!@$^&*~?.|/[]<>\`";#()]','');
    defaultName = regexprep(graphTitle,'^[!@$^&*~?.|/[]<>\`";#()]','');
    defaultName = regexprep(defaultName, '[:]','-');
    
    if iscell(defaultName)
        defaultName = defaultName{1};
    end
    
    

% Open UI for save name and path
    [file,path] = uiputfile('*.pdf','Save Plot to PDF as:',fullfile(config.outputFolderPath, defaultName));

% Check the user didn't "cancel"
if file ~= 0
    
    progressbar('Generating PDF'); totalSteps = 13;
    
    % Data Cursors / Tooltips
    cursors = findall(fh, 'type', 'hggroup');	progressbar(1/totalSteps);
    oldCursorFontSize = { cursors.FontSize }';	progressbar(2/totalSteps);
    
    % Plot Legends
    legends = findall(fh, 'Type', 'Legend');    progressbar(3/totalSteps);
    oldLegendFontSize = { legends.FontSize }';  progressbar(4/totalSteps);
    
    %% Automatically select best font size for printing
    set(cursors, 'FontSize', 6);                progressbar(5/totalSteps);
    set(legends, 'FontSize', 7);                progressbar(6/totalSteps);
    
    % Timeline Events - fix stacking order
    reviewEventLabelsToTop(fh);                 progressbar(7/totalSteps);
    
    % Timeline Label Sizes
    labels = findall(fh,'Tag','vlinetext');  	progressbar(8/totalSteps);
    oldLabelFontSize = { labels.FontSize }';    progressbar(9/totalSteps);
    
    % Save
    saveas(fh, [path file],'pdf');              progressbar(10/totalSteps);
    
    %% Restore font sizes
    set(cursors, {'FontSize'}, oldCursorFontSize);  progressbar(11/totalSteps);
    set(legends, {'FontSize'}, oldLegendFontSize);  progressbar(12/totalSteps);
    set(labels,  {'FontSize'}, oldLabelFontSize);   progressbar(13/totalSteps);
    
else
    % Cancelled... not sure what the best behavior is... return to GUI
end


% Garbage collection
clear config fh file path defaultName sth