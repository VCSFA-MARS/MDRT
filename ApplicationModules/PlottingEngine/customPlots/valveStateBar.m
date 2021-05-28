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

if targetAxes.isvalid
    hax = targetAxes;
else
    hf = figure;
    hax = targetAxes;
end


% 

%% Plot Styles

COM_LINE_WIDTH = 1;
COM_LINE_COLOR = 'r';

COL_OPEN    = 'g';
COL_CLOSED  = [0.8 0.8 0.8];
COL_CAUT    = 'y';
COL_CRIT    = 'r';
COL_OTHER   = 'm';

%% Deal with Axes if needed


YTickLabels = {};
YTicks = [1:numel(valveNum)] - 0.5 ;

for vn = 1:numel(valveNum)

    searchTerm = sprintf('*%s*',valveNum{vn} );

    cfg = getConfig;
    files = dir( fullfile(cfg.dataFolderPath, searchTerm) );
    filenames = {files.name}';




    %% Find all valve data

    mustHave = 'Damper|Positioner|Valve|[D|P]CVN[OC]|RV';
    mustNotHave = { 'Close|Open|Var|Percent|Pump|Fan|__' };
    excludeValves = { 'RV-000[15678]|WDS PCR|Shut-Out'} ;

    propSearch = {' Mon' };

    l_allValves = ~cellfun('isempty',regexp(filenames, mustHave));
    l_toExclude = ~cellfun('isempty',regexp(filenames, mustNotHave));
    l_notValves = ~cellfun('isempty',regexp(filenames, excludeValves));

    l_allValves = l_allValves & ~l_toExclude & ~l_notValves ;

    filenames(l_allValves, 1);

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
        load(fullfile(cfg.dataFolderPath,filenames{l_state}));
        states = fd.ts.Data;
        times = fd.ts.Time;

        % Load Command
        load(fullfile(cfg.dataFolderPath,filenames{l_disCmd}));
        cmdParms = fd.ts.Data;
        cmdTimes = fd.ts.Time;

    elseif any(l_propCmd)
        % Valve is proportional - not implemented :(
        % sad. Sad, sad, sad

    else
        % No one knows what happened
        return
    end





    %% Plot States
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

        switch val
            case 0
                col = COL_CLOSED;
            case 1
                col = COL_OPEN;
            case 2
                col = COL_CAUT;
            case 3
                col = COL_CRIT;
            otherwise
                col = COL_OTHER;
        end

        % clockwise from bottom-left

        X = [timeL timeL timeR timeR];
        Y = [0+vn-1 1+vn-1 1+vn-1 0+vn-1];

        thisFill = fill(X, Y, col, 'FaceAlpha', 0.5, 'EdgeColor', 'none');
        hFills = vertcat(hFills, thisFill);

        hold on;

    %     from = datestr(timeL, 'HH:MM:SS');
    %     to = datestr(timeR, 'HH:MM:SS');
    %     fprintf('Patch %3d : state: %d : color: %s %s to %s \t L=%3d R=%3d\n', n, val, col, from, to, indL, indR)

    end


    %% Plot Commands

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
                thisCmd = rectangle('Position', [timeL, 0.01+vn-1, timeR-timeL, 0.98], ...
                    'EdgeColor',    COM_LINE_COLOR, ...
                    'LineWidth',    COM_LINE_WIDTH);
                
                hCmds = vertcat(hCmds, thisFill);

            otherwise
        end

        % clockwise from bottom-left

        hold on;

    end

    
    %% Add Label
    
%     ht = text(hax.XLim(1) + (hax.XLim(2)-hax.XLim(1))*0.05, ... 
%                 0.5 + vn - 1, ...
%                 findNum)

    hax.YTick = YTicks;
    hax.YTickLabel = YTickLabels;


end







dynamicDateTicks;