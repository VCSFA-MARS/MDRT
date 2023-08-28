function valveStateBar(valveNumArray, targetAxes, varargin)
% Adds valve bar plot to an existing axes. If targetAxes is invalid, figure
% and axes are created. Plotted top-to-bottom in order of valveNumArray
%
% Takes a number as a valve identifier for convenience. Note: if using an
% overloaded find number (0003 - 0008, for example) the tool will select
% the first FD in lexicographical order. To avoid confusion, a find number
% char array will fully define the intended valve.
%
%   Supported Key/Val Pairs
%
%       DataFolder      a full path to the folder containing .mat files
%                       Overrides default behavior to use MDRTConfig
%
%       LabelOffset     numeric value: positive shifts to the left,
%                       negative to the right. Adjusts the position of the
%                       Y-Axis labels
%
%   Example: 
%   valveStateBar({'2031' '2097' '2032' '2027' '2035' '2099' '2040'}, gca)
%
%   Example: 
%   valveStateBar({'2031' '2097'}, gca, 'DataFolder', '/MDRT/DataSet1/data')
%
%   Example:
%   valveStateBar({'RV-0003' 'RV-0004' 'RV-0008'}, gca)
%

%% Process Key/Value Pairs

userPassedDataFolder = '';
TICK_LABEL_GAP_OFFSET = -20;
AX_LIMS = [today + 1,1];

if any(size(varargin))
    if numel(varargin) == 1 && iscell(varargin(1))
        varargin = varargin{1};
    end
    for n = 1:2:numel(varargin)
        key = lower(varargin{n});
        val = varargin{n+1};
        
        switch key
            case {'datafolder', 'datasetfolder'}
                if ischar(val) || iscellstr(val)
                    if iscellstr(val)
                        val = val{1};
                    end
                    userPassedDataFolder = val;
                    debugout(sprintf('User passed a data folder: %s\n', val));
                end
                
            case {'labeloffset', 'labelposition'}
                if isnumeric(val) || iscell(val)
                    if iscellstr(val)
                        val = val{1};
                    end
                    TICK_LABEL_GAP_OFFSET = val;
                    debugout(sprintf('User passed a y-tick label offset: %d\n', val));
                end
                
            otherwise
                debugout('Unrecognized key/val pair')
                debugout(key)
                debugout(val)
        end
    end
end




%% Process Standard Named Arguments

switch class(valveNumArray)
    case 'cell'
        valveNum = valveNumArray;
    case 'char'
        valveNum = {valveNumArray};
    otherwise
        valveNum = {'2031', '2097', '2032', '2040'};
        warn('Bad valveArray passed - using default LO2 valves');
        % error('valveArray must be a cell array or single char');
end

debugout(sprintf('%d valve numbers passed\n', numel(valveNum) ))

useNewAxes = false;

try 
    if targetAxes.isvalid
        hax = targetAxes;
        debugout('Passed valid axes handle')
    else
        hFig = figure;
        hax = axes;
        debugout('Passed invalid axes handle')
    end
catch
    hFig = figure;
    hax = axes;
    useNewAxes = true;
    warning('No valid axes handle passed: created new figure and axes')
end

axes(hax);
debugout(hax)


%% Plot Styles

COM_LINE_WIDTH = 1;
COM_LINE_COLOR = 'r';
COM_FLOAT_HEIGHT = 0.1;

COL_OPEN    = [0 1 0]; % 'g'
COL_CLOSED  = [0.8 0.8 0.8];
COL_CAUT    = [1 1 0]; % 'y';
COL_CRIT    = [1 0 0]; % 'r';
COL_OTHER   = 'm';

%% Deal with Axes if needed

valveNum = flip(valveNum); % flip order since we plot bottom-up

justNumberPattern = '[0-9]{4,}' ;
searchStr = regexp(valveNum, justNumberPattern, 'match'); 
searchStr = unique(vertcat(searchStr{:}));


numValves = numel(searchStr);

debugout(sprintf('Processing %d unique valves', numValves))

YTickLabels = {};
YTicks = [1:numValves] - 0.5 ;
for vn = 1:numValves
    
    searchTerm = sprintf('*%s*',searchStr{vn} );
    debugout(sprintf('Finding all data matching: %s', searchTerm))

    
    if isempty(userPassedDataFolder)
        cfg = getConfig;
        DATA_FOLDER = cfg.dataFolderPath;
    else
        DATA_FOLDER = userPassedDataFolder;
    end
        
    files = dir( fullfile(DATA_FOLDER, searchTerm) );
    filenames = {files.name}';


    %% Find all valve data
    
    % This may be excessive - future work can refactor this down. Does a
    % lot of searching with regex to look for discrete and proportional
    % data via Pad-0A naming conventions.
    
    findNumberPattern = '[A-Z]+-[0-9]+' ;

    mustHave = {'Damper|Positioner|Valve|[D|P]CVN[OC]|RV'};
    mustNotHave = { 'Close|Open|Var|Percent|Pump|Fan|__' };
    excludeValves = { 'WDS PCR|Shut-Out'} ;

    propSearch = {' Mon' };
    
    l_allValves = ~cellfun('isempty',regexp(filenames, mustHave));
    l_toExclude = ~cellfun('isempty',regexp(filenames, mustNotHave));
    l_notValves = ~cellfun('isempty',regexp(filenames, excludeValves));

    l_allValves = l_allValves & ~l_toExclude & ~l_notValves ;
    
    filenames = filenames(l_allValves);
    
    findNum = regexp(filenames{1}, findNumberPattern, 'match');
    l_thisFind  = ~cellfun('isempty',regexp(filenames, findNum));
    filenames = filenames(l_thisFind);
    
    

    try
%         filenames(l_allValves, 1)
    catch
        searchTerm
        continue
    end
    
    l_proportional = ~cellfun('isempty',regexp(filenames, propSearch));
%     l_proportional = l_allValves & l_proportional;
    i_proportional = find(l_proportional);

    filenames(l_proportional, 1);

    l_propCmd = ~cellfun('isempty', regexp(filenames, 'Cmd Param'));
%     l_propCmd = l_allValves & l_propCmd ;
    i_propCmd = find(l_propCmd);

    filenames(l_propCmd, 1);

    l_disCmd = ~cellfun('isempty', regexp(filenames, 'Ctl Param'));
%     l_disCmd = l_disCmd & ~l_toExclude & ~l_notValves;
    filenames(l_disCmd );

    l_state = ~cellfun('isempty', strfind(filenames, 'State'));


    
    
    YTickLabels = vertcat(YTickLabels, findNum);


    %% Handle Discrete vs Proportional

    if any(l_propCmd + l_proportional)
        % Valve is proportional - not implemented :(
        % sad. Sad, sad, sad
        
        try
            % 
            s = load(fullfile(DATA_FOLDER, filenames{l_propCmd}));
            cmdParms = s.fd.ts.Data;
            cmdTimes = s.fd.ts.Time;
        catch
            cmdParms = [];
            cmdTimes = [];
            disp('Proportional valve command data not found');
        end
        
        s = load(fullfile(DATA_FOLDER, filenames{l_proportional}));
        position = s.fd.ts.Data;
        posTimes = s.fd.ts.Time;
        
        plotProportional;
    
    elseif any(l_disCmd + l_state)
        % Valve is assumed discrete - good.
        
        % Load State
        s = load(fullfile(DATA_FOLDER,filenames{l_state}));
        states = s.fd.ts.Data;
        times = s.fd.ts.Time;

        % Load Command
        try
            s = load(fullfile(DATA_FOLDER,filenames{l_disCmd}));
            cmdParms = s.fd.ts.Data;
            cmdTimes = s.fd.ts.Time;
        catch
            cmdParms = [];
            cmdTimes = [];
            disp('Discrete valve command data not found');
        end
                
        plotDiscrete;

    else
        % No one knows what happened
        continue
    end

end
%% Update Y-Axis Labels with Valve IDs

hax.YTick = YTicks;
hax.YTickLabel = YTickLabels;
hax.YLim = [0 numValves];

% if useNewAxes
    plotStyle;
    dynamicDateTicks
% end

shiftYLabels
% hax.YRuler.TickLabelGapOffset = TICK_LABEL_GAP_OFFSET;

setDateAxes(hax, 'XLim', AX_LIMS);


%% Plotting Functions

function shiftYLabels
    
    % Save relevant info
    old_tick_labels = hax.YTickLabels;
    old_tick_vals = hax.YTick;
    num_ticks = numel(old_tick_labels);
    
    old_y_label = hax.YLabel.String;
    
    % Clear the bad labels
    hax.YTickLabels = {''};
    hax.YLabel.String = {''};
    
    MDRTValveBarLabel(hax, old_tick_labels, old_tick_vals);

end



function plotProportional
    % plotProportional scales percent position and command data to a unit
    % height for plotting/stacking in the valveStateBar display. "closed"
    % position is plotted above the "open" position area for consistency
    % with the discrete valve display. 
    
    changeInds = [  1; 
                    find([0;diff(cmdParms)]) ; 
                    length(cmdParms) ];
       
    plotOffset = vn - 1;
            
%     X = [posTimes(1); posTimes; posTimes(end)];
%     Y = [0;           position; 0] ./100 + plotOffset;
    
    tt = doubleElems(posTimes);
    yy = doubleElems(position);

    X = [ tt; posTimes(end)  ];
    Y = [ 0;  yy(1:end-1);  0] ./100 + plotOffset;
    
    YClosed = [100; yy(1:end-1); 100] ./100 + plotOffset;
    
    hax.NextPlot = 'add';
    
    clsPlot = fill(X, YClosed, COL_CLOSED, ...
                'FaceAlpha',            0.5, ...
                'EdgeColor',            COL_CLOSED * 0.85);
            
    hax.NextPlot = 'add';
            
    posPlot = fill(X, Y, COL_OPEN, ...
                'FaceAlpha',            0.5, ...
                'EdgeColor',            COL_OPEN * 0.85);
           
    
    [cmdX cmdY] = stairs(cmdTimes, (cmdParms./100) + plotOffset);
    cmdZ = ones(size(cmdX)).*COM_FLOAT_HEIGHT;
    
    cmdPlot = plot3(cmdX, cmdY, cmdZ, '-r');
    
    AX_LIMS(2) = max([X; cmdX; AX_LIMS(2)]);
    AX_LIMS(1) = min([X; cmdX; AX_LIMS(1)]);

end



function plotDiscrete
    % plotDiscrete takes valve state and command data and plots rectangles
    % representing the open, closed, cautionary, and critical states.
    % Energize commands are represented by a "command rectangle." All items
    % can have data tips applied as necesary.
    
    changeInds = [  1; 
                    find([0;diff(states)]) ; 
                    length(states) ];

    hFills = [];
    hold on;
    for n = 2:length(changeInds)

        indL = changeInds(n-1);
        indR = changeInds(n);

        timeL = times(indL);
        timeR = times(indR);

        val = states(indL);
        edgeCol = 'none';

        switch val
            case 0 % Closed
                col = COL_CLOSED;
                edgeCol = COL_CLOSED * 0.85;
            case 1 % Open
                col = COL_OPEN;
                edgeCol = COL_OPEN * 0.85;
            case 2 % Cautionary
                col = COL_CAUT;
            case 3 % Critical
                col = COL_CRIT;
            otherwise
                col = COL_OTHER;
        end

        % clockwise from bottom-left

        X = [timeL timeL timeR timeR];
        Y = [0+vn-1 1+vn-1 1+vn-1 0+vn-1];

        thisFill = fill(X, Y, col, 'FaceAlpha', 0.5, 'EdgeColor', edgeCol);
        hFills = vertcat(hFills, thisFill);

    end
    hold off;


    % Plot Commands

    changeInds = [  1; 
                    find([0;diff(cmdParms)]) ; 
                    length(cmdParms) ];

    hCmds = [];
    
    hold on;
    for n = 2:length(changeInds)
        
        if ~ any(cmdTimes)
            disp('Skipping discrete command plot');
            continue
        end

        indL = changeInds(n-1);
        indR = changeInds(n);

        timeL = cmdTimes(indL);
        timeR = cmdTimes(indR);



        val = cmdParms(indL);

        switch val

            case 1
                thisCmd = fill3([timeL, timeL, timeR, timeR], [vn-1, vn, vn, vn-1], COM_FLOAT_HEIGHT.*[1 1 1 1],...
                    [0 0 0], ...
                    'FaceAlpha',    0.0, ...
                    'EdgeColor',    COM_LINE_COLOR, ...
                    'LineWidth',    COM_LINE_WIDTH);

                hCmds = vertcat(hCmds, thisFill);

            otherwise
        end

        % clockwise from bottom-left

    end
    hold off;
    AX_LIMS(2) = max([times(end); AX_LIMS(2)]);
    AX_LIMS(1) = min([times(1); AX_LIMS(1)]);
end


function doubled = doubleElems(vect)
    doubled = reshape(repmat(vect', 2, 1), numel(vect)*2,1);
end

end

