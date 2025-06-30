function ValveTimingProcessFunc(MasterStructure,ExportFileName)

% This function comprises the computational processes involved in valve
% timing calculations on Pad 0C.
%
% Input...
%   -> MasterStructure
%       -> structure containing I/O Code Numbers and their associated time 
%          series data sets
%       -> formatting is significant...
%           -> 1st Column: titled 'Code', contains I/O Code numbers
%           -> 2nd Column: titled 'TimeSeries', contains time series data 
%                          sets associated with each I/O Code
%       -> attained as output of ValveTimingInputFunc.m
%   -> Export
%
% Output...
%   -> writes valve timing results and any discovered errors to a
%      pre-formatted Excel worksheet; this worksheet is then saved to the
%      folder
% -------------------------------------------------------------------------


% ------------------------------------------------------------------------- 
% We import the template Excel sheet used for formatting the export data
% and the Excel workbook containing I/O code pairings.
% ------------------------------------------------------------------------- 
TemplateName = 'Pad0C_ValveTimingExportTemplate.xltx';
GroupList = readtable('Pad0C_ValveGrouping.xlsx', ...
    'PreserveVariableNames',true);
% -------------------------------------------------------------------------


% -------------------------------------------------------------------------
% We create the export file.
% -------------------------------------------------------------------------
% We remove the file extension from ExportFileName, if one exists.
[~,ExportFileName,~] = fileparts(ExportFileName);

% We add a .xlsx designator to the export file name.
ExportName = strcat(ExportFileName,'.xlsx');

% We create a copy of the template with the desired name.
copyfile(TemplateName,ExportName)

% We create a table representing the blank export Excel sheet.
ExportData = readtable(TemplateName,'PreserveVariableNames',true);

% We specify that the Errors variable required string data.
ExportData = convertvars(ExportData,'Errors','string');
% -------------------------------------------------------------------------


% ------------------------------------------------------------------------- 
% We introduce a wait bar to track calculations being done on each valve.
% ------------------------------------------------------------------------- 
ProcessProgressBar = waitbar(0,'Beginning Computational Process', ...
    'WindowStyle','modal');
% ------------------------------------------------------------------------- 


% -------------------------------------------------------------------------
% For each valve defined by the Valve Grouping List, we: (a) verify that
% data exists for all three required valves in the Master Structure,
% writing an error message to the export file if not; (b) if required data
% does exist, perform necessary calculations via the function...
%   -> ValveTimingComputations.m
% -------------------------------------------------------------------------
for i = 1:height(GroupList)

    % We define currValve and currCode for the
    currType = string(GroupList{i,'Valve Type'});
    currValve = string(GroupList{i,'Valve FN'});
    currOpenCode = GroupList{i,'Open I/O'};
    currClosedCode = GroupList{i,'Closed I/O'};
    currCommandCode = GroupList{i,'Command I/O'};

    % We update the progress bar.
    waitbar(i/height(GroupList),ProcessProgressBar, ...
        strcat('Computing For:',{' '},currType,'-',currValve));

    % We confirm that all three codes are present in MasterStructure.
    CodeCheck = transpose([MasterStructure.Code]);
    OpenCheck = ismember(currOpenCode,CodeCheck);
    ClosedCheck = ismember(currClosedCode,CodeCheck);
    CommandCheck = ismember(currCommandCode,CodeCheck);
    ExportError = 'The following I/O Codes are missing data:';

    % We list in the export file which I/O codes are missing.
    if OpenCheck == 0 || ClosedCheck == 0 || CommandCheck == 0
        if OpenCheck == 0
            ExportError = strcat(ExportError,currOpenCode);
        end
        if ClosedCheck == 0 && OpenCheck == 0
            ExportError = strcat(ExportError,',',num2str(currClosedCode));
        elseif ClosedCheck == 0 && OpenCheck == 1
            ExportError = strcat(ExportError,currClosedCode);
        end
        if CommandCheck == 0 && (OpenCheck == 0 || ClosedCheck == 0)
            ExportError = strcat(ExportError,',',num2str(currCommandCode));
        elseif CommandCheck == 0 && (OpenCheck == 1 && ClosedCheck == 1)
            ExportError = strcat(ExportError,num2str(currCommandCode));
        end
        ExportData.Errors(i) = convertCharsToStrings(ExportError);
        continue
    end

    % We pull the time series for the three codes.
    currOpenData = MasterStructure(currOpenCode == CodeCheck).TimeSeries;
    currClosedData = MasterStructure(currClosedCode == ...
        CodeCheck).TimeSeries;
    currCommandData = MasterStructure(currCommandCode == ...
        CodeCheck).TimeSeries;

    % We normalize open state data, as necessary.
    if max(currOpenData.Data) > 1
        currOpenData.Data = currOpenData.Data ./ max(currOpenData.Data);
    end

    % We normalize closed state data, as necessary.
    if max(currClosedData.Data) > 1
        currClosedData.Data = currClosedData.Data ./ max( ...
            currClosedData.Data);
    end

    % We normalize command data, as necessary.
    if max(currCommandData.Data) > 1
        currCommandData.Data = currCommandData.Data ./ max( ...
            currCommandData.Data);
    end
    
    % We verify that all three time series begin at the same time stamp.
    if currOpenData.Time(1) ~= currCommandData.Time(1) || ...
            currClosedData.Time(1) ~= currCommandData.Time(1)
        ExportError = ['Datum times are inconsistent across data. ' ...
            'Cannot compute timing.'];
        ExportData.Errors(i) = convertCharsToStrings(ExportError);
        continue
    end

    % We look for instances of OPEN -> CLOSE commands.
    CommandCloseIndices = find(currCommandData.Data == 0);
    ClosedStateOpenIndices = find(currClosedData.Data == 0);
    CommandSwitchIndices = zeros(1,3);
    StateSwitchIndices = zeros(1,3);
    AveragingVector = zeros(1,3);

    for j = 1:length(CommandCloseIndices)
        if CommandCloseIndices(j) == 1
            continue
        elseif currCommandData.Data(CommandCloseIndices(j) - 1) == 1
            for k = 1:length(CommandSwitchIndices)
                if CommandSwitchIndices(k) == 0
                    CommandSwitchIndices(k) = CommandCloseIndices(j) - 1;
                    break
                end
            end
        end
    end

    for j = 1:length(ClosedStateOpenIndices)
        if ClosedStateOpenIndices(j) == 1
            continue
        elseif currClosedData.Data(ClosedStateOpenIndices(j) - 1) == 1
            for k = 1:length(StateSwitchIndices)
                if StateSwitchIndices(k) == 0
                    StateSwitchIndices(k) = ClosedStateOpenIndices(j);
                    break
                end
            end
        end
    end

    for j = 1:length(AveragingVector)
        AveragingVector(j) = 0.1*(StateSwitchIndices(j) - ...
            CommandSwitchIndices(j));
    end

    ExportData{i,'Close Time [s]'} = mean(AveragingVector);

    % We look for instances of CLOSE -> OPEN commands.
    CommandOpenIndices = find(currCommandData.Data == 1);
    OpenStateOpenIndices = find(currOpenData.Data == 0);
    CommandSwitchIndices = zeros(1,3);
    StateSwitchIndices = zeros(1,3);
    AveragingVector = zeros(1,3);

    for j = 1:length(CommandOpenIndices)
        if CommandOpenIndices(j) == 1
            continue
        elseif currCommandData.Data(CommandOpenIndices(j) - 1) == 0
            for k = 1:length(CommandSwitchIndices)
                if CommandSwitchIndices(k) == 0
                    CommandSwitchIndices(k) = CommandOpenIndices(j) - 1;
                    break
                end
            end
        end
    end

    for j = 1:length(OpenStateOpenIndices)
        if OpenStateOpenIndices(j) == 1
            continue
        elseif currOpenData.Data(OpenStateOpenIndices(j) - 1) == 1
            for k = 1:length(StateSwitchIndices)
                if StateSwitchIndices(k) == 0
                    StateSwitchIndices(k) = OpenStateOpenIndices(j);
                    break
                end
            end
        end
    end

    for j = 1:length(AveragingVector)
        AveragingVector(j) = 0.1*(StateSwitchIndices(j) - ...
            CommandSwitchIndices(j));
    end

    ExportData{i,'Open Time [s]'} = mean(AveragingVector);

end
% -------------------------------------------------------------------------


% -------------------------------------------------------------------------
% We close the progress bar.
% -------------------------------------------------------------------------
close(ProcessProgressBar)
% -------------------------------------------------------------------------


% -------------------------------------------------------------------------
% We export the results.
% -------------------------------------------------------------------------
writetable(ExportData,ExportName,'PreserveFormat',true)
% -------------------------------------------------------------------------




% -------------------------------------------------------------------------
% We close the function.
% -------------------------------------------------------------------------
end
% -------------------------------------------------------------------------