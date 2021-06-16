function valveStateBar(valveNumArray, targetAxes, varargin)
% Adds valve bar plot to an existing axes. If targetAxes is invalid, figure
% and axes are created;
%
%   Example: 
%   valveStateBar({'2031' '2097' '2032' '2027' '2035' '2099' '2040'}, gca)


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

fprintf('%d valve numbers passed\n', numel(valveNum) )

try 
    if targetAxes.isvalid
        hax = targetAxes;
    else
        hFig = figure;
        hax = axes;
    end
catch
    hFig = figure;
    hax = axes;
end

% 

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


numValves = numel(valveNum);
YTickLabels = {};
YTicks = [1:numValves] - 0.5 ;

for vn = 1:numValves

    justNumberPattern = '[0-9]{4,}' ;

    searchStr = regexp(valveNum{vn}, justNumberPattern, 'match');
    switch class(searchStr)
        case 'cell'
            searchStr = searchStr{1,1};
    end
    
    searchTerm = sprintf('*%s*',searchStr );
    debugout(sprintf('Finding all data matching: %s', searchTerm))

    cfg = getConfig;
    files = dir( fullfile(cfg.dataFolderPath, searchTerm) );
    filenames = {files.name}';




    %% Find all valve data
    
    % This may be excessive - future work can refactor this down. Does a
    % lot of searching with regex to look for discrete and proportional
    % data via Pad-0A naming conventions.

    mustHave = 'Damper|Positioner|Valve|[D|P]CVN[OC]|RV';
    mustNotHave = { 'Close|Open|Var|Percent|Pump|Fan|__' };
    excludeValves = { 'RV-000[15678]|WDS PCR|Shut-Out'} ;

    propSearch = {' Mon' };

    l_allValves = ~cellfun('isempty',regexp(filenames, mustHave));
    l_toExclude = ~cellfun('isempty',regexp(filenames, mustNotHave));
    l_notValves = ~cellfun('isempty',regexp(filenames, excludeValves));

    l_allValves = l_allValves & ~l_toExclude & ~l_notValves ;

    try
        filenames(l_allValves, 1);
    catch
        searchTerm
        continue
    end

    l_proportional = ~cellfun('isempty',regexp(filenames, propSearch));
    l_proportional = l_allValves & l_proportional;
    i_proportional = find(l_proportional);

    filenames(l_proportional, 1);

    l_propCmd = ~cellfun('isempty', regexp(filenames, 'Cmd Param'));
    l_propCmd = l_allValves & l_propCmd ;
    i_propCmd = find(l_propCmd);

    filenames(l_propCmd, 1);

    l_disCmd = ~cellfun('isempty', regexp(filenames, 'Ctl Param'));
    l_disCmd = l_disCmd & ~l_toExclude & ~l_notValves;
    filenames(l_disCmd );

    l_state = ~cellfun('isempty', strfind(filenames, 'State'));


    findNumberPattern = '[A-Z]+-[0-9]+' ;
    findNum = regexp(filenames{1}, findNumberPattern, 'match');
    
    YTickLabels = vertcat(YTickLabels, findNum);


    %% Handle Discrete vs Proportional

    if any(l_disCmd)
        % Valve is discrete - good

        % Load State
        s = load(fullfile(cfg.dataFolderPath,filenames{l_state}));
        states = s.fd.ts.Data;
        times = s.fd.ts.Time;

        % Load Command
        s = load(fullfile(cfg.dataFolderPath,filenames{l_disCmd}));
        cmdParms = s.fd.ts.Data;
        cmdTimes = s.fd.ts.Time;
        
        plotDiscrete;

    elseif any(l_propCmd)
        % Valve is proportional - not implemented :(
        % sad. Sad, sad, sad
        
        s = load(fullfile(cfg.dataFolderPath, filenames{l_propCmd}));
        cmdParms = s.fd.ts.Data;
        cmdTimes = s.fd.ts.Time;
        
        s = load(fullfile(cfg.dataFolderPath, filenames{l_proportional}));
        position = s.fd.ts.Data;
        posTimes = s.fd.ts.Time;
        
        plotProportional;
                
    else
        % No one knows what happened
        return
    end

end    
%% Update Y-Axis Labels with Valve IDs

hax.YTick = YTicks;
hax.YTickLabel = YTickLabels;
hax.YLim = [0 numValves];

dynamicDateTicks;







%% Plotting Functions


function plotProportional
    % plotProportional scales percent position and command data to a unit
    % height for plotting/stacking in the valveStateBar display. "closed"
    % position is plotted above the "open" position area for consistency
    % with the discrete valve display. 
    
    changeInds = [  1; 
                    find([0;diff(cmdParms)]) ; 
                    length(cmdParms) ];
       
    plotOffset = vn - 1;
            
    X = [posTimes(1); posTimes; posTimes(end)];
    Y = [0; position; 0]./100 + plotOffset;
    
    YClosed = [100; position; 100]./100 + plotOffset;
    
    clsPlot = fill(X, YClosed, COL_CLOSED, ...
                'FaceAlpha',            0.5, ...
                'EdgeColor',            COL_CLOSED * 0.85);
            
    hold on;
            
    posPlot = fill(X, Y, COL_OPEN, ...
                'FaceAlpha',            0.5, ...
                'EdgeColor',            COL_OPEN * 0.85);
           
    
    [cmdX cmdY] = stairs(cmdTimes, (cmdParms./100) + plotOffset);
    cmdZ = ones(size(cmdX)).*COM_FLOAT_HEIGHT;
    
    cmdPlot = plot3(cmdX, cmdY, cmdZ, '-r');

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

        hold on;

    end


    % Plot Commands

    changeInds = [  1; 
                    find([0;diff(cmdParms)]) ; 
                    length(cmdParms) ];

    hCmds = [];
    for n = 2:length(changeInds)

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

        hold on;

    end
end

end