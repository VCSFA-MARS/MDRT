function ValveTimingFunc(DataPath,ExportFileName)
% -------------------------------------------------------------------------


% -------------------------------------------------------------------------
%   This function automatically performs valve timing calculations for
% discrete valves on Pad 0C. The function is intended for integration with
% the 'review.m' data review tool, but may operate independently. The
% function takes as an input the file location of .mat files intended for
% processing; these .mat files are attained through the Data Review GUI
% tool in 'review.m'.
%   The function processes and organizes the fd structures associated with
% these .mat files. The function compares the data provided against a
% directory of I/O Codes and then again to a list of MARS FN's and their
% associated I/O Codes. This allows for the funamental .mat data to be
% associated with the appropriate signals (command, open, closed) for the
% appropriate valves. If data for a specific valve is not provided, the
% function will note that in its output.
%   Once the provided data is organized, computation of valve timing is
% done for each valve. 'Open Time [s]' returns the time difference between
% the command signal turning FALSE and the open state signal turning TRUE.
% 'Close Time [s]' returns the tiem difference between the command signal
% turning TRUE and the close state signal turning TRUE. These times are
% written to a .xlsx file with a name provided by the user.
%
% Important Notes for User...
%   -> Be wary of changes made to the .xlsx or .xltx files listed below in
%       'Supporting Files' -- this function is sensitive to the formatting
%       of those files, and changes to the files may necessitate changes to
%       the code. Additional rows may be added to Valve Directory or Valve
%       Grouping so long as all columns are populated correctly.
%   -> If a 'The following I/O Codes afre missing data:' error is returned
%       unexpectedly, you may look at the Error Table for a more detailed
%       explanation of the issue (i.e. if a certain .mat file provided bad
%       data). This table must be accessed in MATLAB, from the Workspace.
%
% Inputs...
%   DataPath: the location (folder or single files) of the .mat files
%             processed by review.m; should be formatted as a string
%   ExportFileName: the desired name of the .xlsx files returned by the
%                   function; should be formatted as a string
%
% Outputs...
%   ExportData: a table (exported as a .xlsx file) of the formatting of the
%               .xltx file listed below in 'Supporting Files'; contains
%               valve timing computational results and any relevant errors
%   ErrorTable: a table (not exported) containing any errors found during
%               the data importation and organization process; this
%               identifies errors with specific .mat files provided to the
%               function, and may only be accessed through the Workspace
%
% Supporting Files...
%   Pad0C_ValveDirectory.xlsx
%       -> associates the .mat file names to Rocket Lab I/O Code Numbers
%   Pad0C_ValveGrouping.xlsx
%       -> associates specific valve FN's with the I/O Code Numbers of the
%          valve's command, open state, and closed state signals
%   Pad0C_ValveTimingExportTemplate.xltx
%       -> provided a clean template for the data to be written to, rather
%          than the default Excel worksheet
%
% -------------------------------------------------------------------------


% -------------------------------------------------------------------------
% REVISION LOG
% -------------------------------------------------------------------------
% Rev0: Austin Leo Thomas - July 7, 2025
%   -> placeholder
%   -> adjust date when finally published
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
files = dir(fullfile(DataPath,'*.mat'));

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
    currStruct = load(fullfile(DataPath,files(i).name));
  else
    continue
  end
  
  % We filter against the Pad 0C I/O Code Directory.
  if max(strcmp(currName,QuickSearch)) == 0
    ErrorTable.Tag(i) = currName;
    ErrorTable.Error(i) = ['Tag is not found in the I/O Code ' ...
      'Directory.'];
    continue
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
% We create the export file.
% -------------------------------------------------------------------------
% We remove any file extension included in the provided export file name.
[ExportPath,ExportFileName,~] = fileparts(ExportFileName);

% We add a .xlsx designator to the export file name.
ExportName = strcat(ExportFileName,'.xlsx');
ExportName = fullfile(ExportPath, ExportName);

% We define the folder path of the results template Excel sheet.
TemplateFolder = 'Valve Timing Script';
TemplateName = 'Pad0C_ValveTimingExportTemplate.xltx';
TemplateName = fullfile(TemplateFolder,TemplateName);

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
  MissingFDs = '';
  
  if ~all([OpenCheck ClosedCheck CommandCheck])
    ErrorMessage = ExportError;

    if ~OpenCheck
        MissingFDs = sprintf('%s %d,',MissingFDs,currOpenCode);
    end
    if ~ClosedCheck
        MissingFDs = sprintf('%s %d,',MissingFDs,currClosedCode);
    end
    if ~CommandCheck
        MissingFDs = sprintf('%s %d',MissingFDs,currCommandCode);
    end
    if MissingFDs(end) == ','
        MissingFDs(end) = [];
    end
    
    ErrorMessage = sprintf('%s %s',ErrorMessage,MissingFDs);
    ExportData.Errors(i) =  convertCharsToStrings(ErrorMessage);
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
  
  % We assign logical values to TRUE and FALSE states depending on the
  % state signal structure, which may vary from valve-to-valve.
  TRUE = GroupList{i,'TRUE State Signal'};
  FALSE = TRUE == 0;
  
  % We look for instances of OPEN -> CLOSE commands.
  CommandCloseIndices = find(currCommandData.Data == 0);
  ClosedStateOpenIndices = find(currClosedData.Data == TRUE);
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
    elseif currClosedData.Data(ClosedStateOpenIndices(j) - 1) == FALSE
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
  OpenStateOpenIndices = find(currOpenData.Data == TRUE);
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
    elseif currOpenData.Data(OpenStateOpenIndices(j) - 1) == FALSE
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
  debugout(sprintf('%s %s', currValve, AveragingVector))
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
% We terminate the function.
% -------------------------------------------------------------------------
end
% -------------------------------------------------------------------------
