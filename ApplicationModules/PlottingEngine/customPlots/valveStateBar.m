valveNum = {'2031', '2097', '2032', '2040'}

%% Deal with Axes if needed


hf = figure;
hax = axes;

for vn = 1:numel(valveNum)

    searchTerm = sprintf('*%s*',valveNum{vn} );

    cfg = getConfig;
    files = dir( fullfile(cfg.dataFolderPath, searchTerm) );
    filenames = {files.name}'




    %% Find all valve data

    mustHave = 'Damper|Positioner|Valve|[D|P]CVN[OC]|RV';
    mustNotHave = { 'Close|Open|Var|Percent|Pump|Fan|__' };
    excludeValves = { 'RV-000[15678]|WDS PCR|Shut-Out'} ;

    propSearch = {' Mon' };

    l_allValves = ~cellfun('isempty',regexp(filenames, mustHave));
    l_toExclude = ~cellfun('isempty',regexp(filenames, mustNotHave));
    l_notValves = ~cellfun('isempty',regexp(filenames, excludeValves));

    l_allValves = l_allValves & ~l_toExclude & ~l_notValves ;

    filenames(l_allValves, 1)

    l_proportional = ~cellfun('isempty',regexp(filenames, propSearch));
    l_proportional = l_allValves & l_proportional;
    i_proportional = find(l_proportional);

    filenames(l_proportional, 1)

    l_propCmd = ~cellfun('isempty', regexp(filenames, 'Cmd Param'));
    l_propCmd = l_allValves & l_propCmd ;
    i_propCmd = find(l_propCmd);

    filenames(l_propCmd, 1)

    l_disCmd = ~cellfun('isempty', regexp(filenames, 'Ctl Param'));
    l_disCmd = l_disCmd & ~l_toExclude & ~l_notValves;
    filenames(l_disCmd )


    l_state = ~cellfun('isempty', strfind(filenames, 'State'));


    findNumberPattern = '[A-Z]+-[0-9]+' ;

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
                col = [0.8 0.8 0.8];
    %             col = 'w';
            case 1
                col = 'g';
            case 2
                col = 'y';
            case 3
                col = 'r';
            otherwise
                col = 'm';
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
                thisCmd = rectangle('Position', [timeL, 0+vn-1, timeR-timeL, 1], 'EdgeColor', 'r', 'LineWidth', 1);
                hCmds = vertcat(hCmds, thisFill);

            otherwise
        end

        % clockwise from bottom-left

        hold on;

    end



end







dynamicDateTicks;