function [ dataPath, setPath ] = selectDataSet
%selectDataSet propmts the user to confirm the current data set or pick a
%new one with a folder selection menu.
%
% Returns the full path to the folder containg the actual .mat data files 
% (dataPath) and the full path to its parent folder (setPath). This
% function uses MDRTConfig.
%
% The user can select either the root data set folder or the actual `data`
% folder and this function will determine the appropriate paths. Note: this
% function will be fooled by a folder named `data` that does not contain
% actual MDRT Data
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
        
        defaultpath = config.dataArchivePath;
        pth = uigetdir(defaultpath); % No checking implemented yet!;
        
        if ~ pth
            disp('Quitting Valve Analysis tool');
            return
        end
                
        [pth, fldr, ~] = fileparts(pth);
        
        % Try to fix selection if the root folder was selected
        if ~strcmp(fldr, 'data')
            d = dir(fullfile(pth,fldr));
            nameMask = strcmp({d.name},'data');
            dirMask = [d.isdir];
            dataFolderMask = all([nameMask', dirMask'],2);
            if any(dataFolderMask)
                pth = fullfile(pth, fldr);
                fldr = 'data';
            else
                disp('Unknown folder selection')
                return
            end
        end
        
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

