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
% We define file paths specifying the location of the I/O Code Directory
% (DirectoryPath), Valve Grouping List (GroupingPath), and the folder
% containing the FCS data (DataPath).
% -------------------------------------------------------------------------
DirectoryPath = ['C:\Users\AustinThomas\Desktop\Pad 0C\Projects\' ...
    'Valve Timing Script [MP-00434]\Pad0C_ValveDirectory'];
GroupingPath = ['C:\Users\AustinThomas\Desktop\Pad 0C\Projects\' ...
    'Valve Timing Script [MP-00434]\Pad0C_ValveGrouping'];
DataPath = 'C:\Users\AustinThomas\Desktop\data\import\Test Folder\data';
% -------------------------------------------------------------------------


% -------------------------------------------------------------------------
% We import the I/O Code Directory and Valve Grouping List (importing
% .xslx files, storing as tables).
% -------------------------------------------------------------------------
Directory = readtable(DirectoryPath,'PreserveVariableNames',true, ...
    'Sheet','Channel List');
QuickSearch = Directory{:,'I/O Code'};

GroupList = readtable(GroupingPath,'PreserveVariableNames',true);
% -------------------------------------------------------------------------


% -------------------------------------------------------------------------
% We following code will attempt to read all struct files generated from
% the review.m script.
% -------------------------------------------------------------------------
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

    % Need to additionally sort for whether data is from a valve or
    % something else (currTag contains an isValve field)
end

% We remove empty rows from the error table.
ErrorTable = rmmissing(ErrorTable);

% We organize the master structure.
MasterStructure(1) = [];
[~,orderMasterStructure] = sort([MasterStructure(:).Code],'ascend');
MasterStructure = MasterStructure(orderMasterStructure);
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
% For each valve defined by the Valve Grouping List, we: (a) verify that
% data exists for all three required valves in the Master Structure,
% writing an error message to the export file if not; (b) if required data
% does exist, perform necessary calculations via the function...
%   -> ValveTimingComputations.m
% -------------------------------------------------------------------------
for i = 1:height(GroupList)

    % We define currValve and currCode for the
    currValve = string(GroupList{i,'Valve FN'});
    currOpenCode = GroupList{i,'Open I/O'};
    currClosedCode = GroupList{i,'Closed I/O'};
    currCommandCode = GroupList{i,'Command I/O'};

    % We confirm that all three codes are present in MasterStructure.
    CodeCheck = transpose([MasterStructure.Code]);
    OpenCheck = ismember(currOpenCode,CodeCheck);
    ClosedCheck = ismember(currClosedCode,CodeCheck);
    CommandCheck = ismember(currCommandCode,CodeCheck);
    CheckVector = [OpenCheck ClosedCheck CommandCheck];
    ExportError = 'The following I/O Codes are missing data:';

    % We implement a makeshift progress bar.
    fprintf('Currently Calculating for %s-%s: [%d/%d]\n\n', ...
        string(GroupList{i,'Valve Type'}),currValve,i,height(GroupList))

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

    % We plot for reference (TESTING ONLY)
    figure(1)
    plot(currOpenData)
    title('Open State')
    figure(2)
    plot(currClosedData)
    title('Closed State')
    figure(3)
    plot(currCommandData)
    title('Command')


    % We look for instances of OPEN -> CLOSE commands.
    CommandCloseIndices = find(currCommandData.Data == 0);
    ClosedStateOpenIndices = find(currClosedData.Data == 0);
    CommandSwitchTimes = zeros(1,3);
    StateSwitchTimes = zeros(1,3);
    AveragingVector = zeros(1,3);

    for j = 1:length(CommandCloseIndices)
        if CommandCloseIndices(j) == 1
            continue
        elseif currCommandData.Data(CommandCloseIndices(j) - 1) == 1
            for k = 1:length(CommandSwitchTimes)
                if CommandSwitchTimes(k) == 0
                    CommandSwitchTimes(k) = currCommandData.Time( ...
                        CommandCloseIndices(j) - 1);
                end
            end
        end
    end

    for j = 1:length(ClosedStateOpenIndices)
        if ClosedStateOpenIndices(j) == 1
            continue
        elseif currClosedData.Data(ClosedStateOpenIndices(j) - 1) == 1
            for k = 1:length(StateSwitchTimes)
                if StateSwitchTimes(k) == 0
                    StateSwitchTimes(k) = currClosedData.Time( ...
                        ClosedStateOpenIndices(j) - 1);
                end
            end
        end
    end

    for j = 1:length(AveragingVector)
        AveragingVector(j) = StateSwitchTimes(j) - CommandSwitchTimes(j);
    end

    ExportData{i,'Close Time [s]'} = mean(AveragingVector);

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

end
% -------------------------------------------------------------------------


% -------------------------------------------------------------------------
% We export the results.
% -------------------------------------------------------------------------
writetable(ExportData,ExportName,'PreserveFormat',true)
% -------------------------------------------------------------------------