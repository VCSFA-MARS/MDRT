% -------------------------------------------------------------------------
% TestingScript_ALT.m
% 
% Testing Script for Valve Timing Script Project [MP-00434]
%
% Author: Austin Leo Thomas
%
% NOTE...
%   -> script is locally-saved and not added to GitHub repository
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
% (DirectoryPath) and the folder containing the FCS data (DataPath).
% -------------------------------------------------------------------------
DirectoryPath = ['C:\Users\AustinThomas\Desktop\Pad 0C\Projects\' ...
    'Valve Timing Script [MP-00434]\Pad 0C Component List'];
DataPath = 'C:\Users\AustinThomas\Desktop\data\import\Test Folder\data';
% -------------------------------------------------------------------------


% -------------------------------------------------------------------------
% We import the I/O Code Directory (importing .xslx, storing as table).
% -------------------------------------------------------------------------
Directory = readtable(DirectoryPath,'PreserveVariableNames',true, ...
    'Sheet','Channel List');
QuickSearch = Directory{:,'I/O Code'};
% -------------------------------------------------------------------------


% -------------------------------------------------------------------------
% We following code will attempt to read all struct files generated from
% the review.m script.
% -------------------------------------------------------------------------
files = dir(DataPath);

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
        ErrorTable.Error(i) = 'Tag is not found in the I/O Code Directory.';
        continue
    end
    
    % We pull the fd structure.
    if isfield(currStruct,'fd') == 1
        currTag = currStruct.fd;
        currTime = files(i).datenum;
    else
        ErrorTable.Tag(i) = currName;
        ErrorTable.Error(i) = 'Tag does not contain an fd structure.';
        continue
    end

    % Here: either save the data (currName, currTag, and currTime) in a 
    % separate structure, for manipulation outside of the for-loop, OR run
    % valve timing computations within the for-loop and save data within 
    % the for-loop as well.

    % Need to additionally sort for whether data is from a valve or
    % something else (currTag contains an isValve field)
end
% -------------------------------------------------------------------------


% -------------------------------------------------------------------------
% We delete unused rows in the error tracking table.
% -------------------------------------------------------------------------
ErrorTable = rmmissing(ErrorTable);
% -------------------------------------------------------------------------