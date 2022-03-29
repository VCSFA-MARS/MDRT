function rescaleFDfromFile(fdFullFile)
%% Rescale STE PT and Save 
%  Expects a fullfile path to a data file containing an FD struct.

%% Instantiate Model

HAS_PERFORMED_CONVERSION = false;

model = struct('ID',                    '', ...
               'Type',                  '', ...
               'System',                '', ...
               'FullString',            '', ...
               'OriginalFullString',    '', ...
               'oldMax',                100, ...
               'newMax',                200, ...
               'Units',                 '', ...
               'originalFolder',        '') ;


% originalFullFile = '/Volumes/ops1/data/imported/2022-03-28 - VN01Test HLS-14/data/5070 GN2 PT-5070 Press Sensor Mon.mat';
[originalFolder, ~, ~] = fileparts(fdFullFile);

model.originalFolder = originalFolder;

%% Load Data File

if ~ exist(fdFullFile, 'file')
    warning('%s is not a valid file', fdFullFile);
    return
end
    
temp = load(fdFullFile);
if ~ isfield(temp, 'fd')
    warning('%s does not contain an FD', fdFullFile)
    return
end

fd = temp.fd;


%% Populate Model from FD

model.ID = fd.ID;
model.Type = fd.Type;
model.System = fd.System;
model.FullString = fd.FullString;
model.OriginalFullString = fd.FullString;
model.Units = fd.ts.DataInfo.Units;


%% Window Creation

hs.fig = figure;
    guiSize = [672 387];
    hs.fig.Position = [hs.fig.Position(1:2) guiSize];
    hs.fig.Name = model.OriginalFullString;
    hs.fig.NumberTitle = 'off';
    hs.fig.MenuBar = 'none';
    hs.fig.ToolBar = 'none';
    hs.fig.Tag = 'Sensor Rescale Tool';

%% Text Controls

hs.oldMax = uicomponent('style', 'edit', ...
    'HorizontalAlignment', 'left', ...
    'Callback', @updateModel, ...
    'position', [50 315 101 22]);

hs.newMax = uicomponent('style', 'edit', ...
    'HorizontalAlignment', 'left', ...
    'Callback', @updateModel, ...
    'position', [50 265 101 22]);

hs.oldMaxLabel = uicomponent('style', 'text', ...
    'String', 'Old Range', ...    
    'HorizontalAlignment', 'left', ...
    'position', [50 337 101 13] );

hs.newMaxLabel = uicomponent('style', 'text', ...
    'String', 'New Range', ...
    'HorizontalAlignment', 'left', ...
    'position', [50 287 101 13] );

hs.fullString = uicomponent('style', 'edit', ...
    'HorizontalAlignment', 'left', ...
    'Callback', @updateModel, ...
    'position', [200 315 351 22]);

hs.fullStringLabel = uicomponent('style', 'text', ...
    'String', 'FD Full String', ...    
    'HorizontalAlignment', 'left', ...
    'position', [200 337 351 13] );

hs.idString = uicomponent('style', 'edit', ...
    'HorizontalAlignment', 'left', ...
    'Callback', @updateModel, ...
    'position', [200 265 101 22]);

hs.idStringLabel = uicomponent('style', 'text', ...
    'String', 'ID String (number)', ...    
    'HorizontalAlignment', 'left', ...
    'position', [200 287 101 13] );

hs.typeString = uicomponent('style', 'edit', ...
    'HorizontalAlignment', 'left', ...
    'Callback', @updateModel, ...
    'position', [200 215 101 22]);

hs.typeStringLabel = uicomponent('style', 'text', ...
    'String', 'Type String', ...    
    'HorizontalAlignment', 'left', ...
    'position', [200 237 101 13] );

hs.systemString = uicomponent('style', 'edit', ...
    'HorizontalAlignment', 'left', ...
    'Callback', @updateModel, ...
    'position', [200 165 101 22]);

hs.systemStringLabel = uicomponent('style', 'text', ...
    'String', 'System String', ...    
    'HorizontalAlignment', 'left', ...
    'position', [200 187 101 13] );
%% Buttons

hs.saveButton = uicomponent('style', 'pushbutton', ...
    'String', 'Save Rescaled Data', ...
    'position', [200 86 151 51], ...
    'callback', @rescaleAndSave);

updateGUI;




    function updateGUI(~, ~)
    %% Update GUI from Model
        hs.idString.String = model.ID;
        hs.typeString.String = model.Type;
        hs.systemString.String = model.System;
        hs.fullString.String = model.FullString;
        hs.oldMax.String = model.oldMax;
        hs.newMax.String = model.newMax;
    end

    function updateModel(~, ~)
        model.oldMax     = str2num(hs.oldMax.String);
        model.newMax     = str2num(hs.newMax.String);
        model.FullString = hs.fullString.String;
        model.ID         = hs.idString.String;
        model.Type       = hs.typeString.String;
        model.System     = hs.systemString.String;
    end

    function rescaleAndSave(~, ~)
    %% Build new FD and Scale

        % newFullName = 'GHe STE PT-0001 VNO1 Test Press Mon';
        fd.ID = model.ID;
        fd.Type = model.Type;
        fd.System = model.System;
        fd.FullString = model.FullString;

        fd.ts.Name = model.FullString;

        if ~ HAS_PERFORMED_CONVERSION
            fd.ts.Data = fd.ts.Data ./ model.oldMax .* model.newMax;
            % HAS_PERFORMED_CONVERSION = true;
        else
            warning('Conversion has already been perfomed on these data. Re-scaling is being skipped')
        end

        newFileName = makeFileNameForFD(fd);
        
        [savePath, fileName] = userSaveDialog(model.originalFolder, newFileName);

        if fileName
            save(fullfile(savePath, newFileName), 'fd');
            hs.saveButton.Enable = 'off';
            updateFDListFromDir(model.originalFolder, ...
                                'save',         'yes', ...
                                'prompt',       'yes');
        end
        
        
    end

    function [savePath, saveFile] = userSaveDialog(dataPath, fileName)
        savePath = '';
        saveFile = '';
        
        % UI Save File Dialog
        % -----------------------------------------------------------------
        [fileName, dataPath, ~] = uiputfile( ...
            {'*.mat', 'MDRT Data Files (*.mat)';
             '*.*',  'All Files (*.*)'},...
             'Save as', fullfile(dataPath, fileName) );
          
        % Handle user cancel case
        % -----------------------------------------------------------------
        if isequal(fileName,0) || isequal(dataPath,0)
            disp('User selected Cancel')
            return
        else
           disp(['User selected ',fullfile(dataPath,fileName)])
           savePath = dataPath;
           saveFile = fileName;
        end
    end


end
