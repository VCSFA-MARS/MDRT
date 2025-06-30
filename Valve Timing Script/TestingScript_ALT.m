% -------------------------------------------------------------------------
% TestingScript_ALT.m
% 
% Testing Script for Valve Timing Script Project [MP-00434]
%
% Author: Austin Leo Thomas
%
% NOTE...
%   -> not intended for merging to Master
%   -> not intended for review
%   -> no revision log needed; version history managed by GitHub
% -------------------------------------------------------------------------


% -------------------------------------------------------------------------
% We clear the command window and workspace.
% -------------------------------------------------------------------------
clear;clc;
% -------------------------------------------------------------------------


% -------------------------------------------------------------------------
% We define the location of the processe data (.mat files returned by
% review.m from an input of .csv files). In final iteration, this ought to
% refer to whatever variable name review.m assigns these .mat files.
% -------------------------------------------------------------------------
DataPath = 'C:\Users\AustinThomas\Desktop\data\import\Test Folder\data';
% -------------------------------------------------------------------------


% -------------------------------------------------------------------------
% We import the I/O Code Directory and Valve Grouping List (importing
% .xslx files, storing as tables).
% -------------------------------------------------------------------------
Directory = readtable('Pad0C_ValveDirectory.xlsx', ...
    'PreserveVariableNames',true,'Sheet','Channel List');
GroupList = readtable('Pad0C_ValveGrouping.xlsx', ...
    'PreserveVariableNames',true);

QuickSearch = Directory{:,'I/O Code'};
% -------------------------------------------------------------------------


% -------------------------------------------------------------------------
% We following code will attempt to read all struct files generated from
% the review.m script.
% -------------------------------------------------------------------------
% We generate a progress bar for the import process.
ImportProgressBar = waitbar(0,'Importing and Organizing Data', ...
    'WindowStyle','modal');

% We list the folder contents from the specified folder location.
files = dir(DataPath);

% We generate an empty structure for the extracted time series.
MasterStructure = struct('Code',[],'TimeSeries',[]);

% We create an error table to store information regarding which files
% could not be processed.
ErrorTable = table('Size',[length(files) 2],'VariableTypes', ...
    {'string' 'string'},'VariableNames',{'Tag' 'Error'});

for i = 1:length(files)

    % We pull the name of the current .mat file.
    currName = erase(files(i).name,".mat");

    % We pull the structure data from the current .mat file.
    if files(i).isdir == 0
        currStruct = load(strcat(DataPath,'\',files(i).name));
    else
        continue
    end

    % We filter against the Pad 0C I/O Code Directory.
    if max(strcmp(currName,QuickSearch)) == 0
        ErrorTable.Tag(i) = currName;
        ErrorTable.Error(i) = ['Tag is not found in the I/O Code ' ...
            'Directory.'];
        continue
    else
    end
    
    % We pull the fd structure.
    if isfield(currStruct,'fd') == 1
        currTag = currStruct.fd;
    else
        ErrorTable.Tag(i) = currName;
        ErrorTable.Error(i) = 'Tag does not contain an fd structure.';
        continue
    end

    % Here: either save the data (currName, currTag, and currTime) in a 
    % separate structure, for manipulation outside of the for-loop, OR run
    % valve timing computations within the for-loop and save data within 
    % the for-loop as well.
    MasterStructure(end+1).Code = find(strcmp(currName,QuickSearch) == 1);
    MasterStructure(end).TimeSeries = currTag.ts;

    % We update the progress bar.
    waitbar(i/length(files))

end

% We remove empty rows from the error table.
ErrorTable = rmmissing(ErrorTable);

% We organize the master structure.
MasterStructure(1) = [];
[~,orderMasterStructure] = sort([MasterStructure(:).Code],'ascend');
MasterStructure = MasterStructure(orderMasterStructure);

% We close the progress bar.
close(ImportProgressBar)
% -------------------------------------------------------------------------


% -------------------------------------------------------------------------
% ABOVE: ValveTimingImportFunc.m
% -------------------------------------------------------------------------


% -------------------------------------------------------------------------
% BELOW: ValveTimingProcessFunc.m
% -------------------------------------------------------------------------


% -------------------------------------------------------------------------
% We create the export file.
% -------------------------------------------------------------------------
% We define the name of the output file (will be user input in GUI in final
% version).
ExportFileName = 'ValveTimingTestResults';

% We add a .xlsx designator to the export file name.
ExportName = strcat(ExportFileName,'.xlsx');

%We define the folder path of the results template Excel sheet.
TemplateName = 'Pad0C_ValveTimingExportTemplate.xltx';

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