% -------------------------------------------------------------------------
% EXCESS CODE DUMP
% -------------------------------------------------------------------------


% -------------------------------------------------------------------------
% Original computation for-loop (before frequency-based workaround).
% -------------------------------------------------------------------------
    % We look for instances of CLOSE -> OPEN commands.
    CommandOpenIndices = find(currCommandData.Data == 1);
    OpenStateOpenIndices = find(currClosedData.Data == 0);
    CommandSwitchTimes = zeros(1,3);
    StateSwitchTimes = zeros(1,3);
    AveragingVector = zeros(1,3);

    for j = 1:length(CommandOpenIndices)
        if CommandOpenIndices(j) == 1
            continue
        elseif currCommandData.Data(CommandOpenIndices(j) - 1) == 1
            for k = 1:length(CommandSwitchTimes)
                if CommandSwitchTimes(k) == 0
                    CommandSwitchTimes(k) = currCommandData.Time( ...
                        CommandOpenIndices(j) - 1);
                end
            end
        end
    end

    for j = 1:length(OpenStateOpenIndices)
        if OpenStateOpenIndices(j) == 1
            continue
        elseif currClosedData.Data(OpenStateOpenIndices(j) - 1) == 1
            for k = 1:length(StateSwitchTimes)
                if StateSwitchTimes(k) == 0
                    StateSwitchTimes(k) = currClosedData.Time( ...
                        OpenStateOpenIndices(j) - 1);
                end
            end
        end
    end

    for j = 1:length(AveragingVector)
        AveragingVector(j) = StateSwitchTimes(j) - CommandSwitchTimes(j);
    end

    ExportData{i,'Open Time [s]'} = mean(AveragingVector);
% -------------------------------------------------------------------------