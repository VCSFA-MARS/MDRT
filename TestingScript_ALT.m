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
% The following code will attempt to read a struct file generated from the
% review.m script.
% -------------------------------------------------------------------------
%filename = 'C:\Users\AustinThomas\Desktop\data\import\Test Folder\data\01C301-PROX';
%
%currStruct = load(filename);
%
%if isfield(currStruct,'fd') == 1
%    fd = currStruct.fd;
%    disp(fd)
%else
%    fprintf('ERROR: %s does not contain an fd field',filename)
%end
% -------------------------------------------------------------------------


% -------------------------------------------------------------------------
% We following code will attempt to read all struct files generated from
% the review.m script.
% -------------------------------------------------------------------------
folder_path = 'C:\Users\AustinThomas\Desktop\data\import\Test Folder\data';
files = dir(folder_path);

for i = 1:length(files)

    % We pull the file name and data from relevant .mat files in the
    % specified folder.
    if files(i).isdir == 1
        continue
    else
        currName = erase(files(i).name,".mat");
        currStruct = load(strcat(folder_path,'\',files(i).name));
    end
    
    % We pull fd structures from those files which contain them.
    if isfield(currStruct,'fd') == 1
        currTag = currStruct.fd;
        currTime = files(i).datenum;
    else
        continue
    end

    % Here: either save the data (currName, currTag, and currTime) in a 
    % separate structure, for manipulation outside of the for-loop, OR run
    % valve timing computations within the for-loop and save data within 
    % the for-loop as well.
    figure(i)
    plot(currTag.ts)
    hold off
    %title('')

    % Need to additionally sort for whether data is from a valve or
    % something else (currTag contains an isValve field)
end