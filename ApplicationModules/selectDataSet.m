function [ dataPath, setPath ] = selectDataSet
%selectDataSet propmts the user to confirm the current data set or pick a
%new one with a folder selection menu.
%
% Returns the full path to the folder containg the actual .mat data files 
% (dataPath) and the full path to its parent folder (setPath). This
% function uses MDRTConfig.
%
%   dataPath - path to folder containing .mat files
%   setPath  - path to "data set" master folder, containing data, delim,
%              and plot folders. Usually named by date and operation

% Counts, VCSFA - 2022

dataPath = [];
setPath  = [];

config = MDRTConfig.getInstance;
[pth, fldr, ~] = fileparts(config.workingDataPath);
questStr = ['Generate plot from data set in ', pth];

result = questdlg(questStr, 'Continue with data set', ...
            'Yes', 'Select New', 'Quit', 'Yes');

switch result
    case 'Yes'     

    case 'Select New'
        hbox = msgbox('Select the ''data'' folder that contains the .mat files.', 'Directions');
        
        % auto-close popup after 5 seconds
        uiwait(hbox, 5);
        if exist('hbox', 'var') && isgraphics(hbox); close(hbox); end
        
        defaultpath = config.dataArchivePath;
        pth = uigetdir(defaultpath); % No checking implemented yet!;
        
        if ~ pth
            disp('Quitting Valve Analysis tool');
            return
        end
        
        [pth, fldr, ~] = fileparts(pth);
        
    case 'Quit'    
        disp('Quitting plot tool');
        return
        
    otherwise
        disp('Unknown selection');
        return
end

        dataPath = fullfile(pth, fldr);
        setPath = pth;


end

