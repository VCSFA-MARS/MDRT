function varargout = review(varargin)
% REVIEW MATLAB code for review.fig
%      REVIEW, by itself, creates a new REVIEW or raises the existing
%      singleton*.
%
%      H = REVIEW returns the handle to a new REVIEW or the handle to
%      the existing singleton*.
%
%      REVIEW('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in REVIEW.M with the given input arguments.
%
%      REVIEW('Property','Value',...) creates a new REVIEW or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before review_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to review_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
%
%   Modified for cross-platform support
%
%   Counts, Spaceport Support Services 2014
%   Committed to git repo


% Edit the above text to modify the response to help review

% Last Modified by GUIDE v2.5 29-Mar-2022 11:10:38

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @review_OpeningFcn, ...
                   'gui_OutputFcn',  @review_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before review is made visible.
function review_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to review (see VARARGIN)

% Choose default command line output for review
handles.output = hObject;

% Handle first-run case and run startup.m if required
if ~isappdata(groot, 'hasRunStartup') || (isappdata(groot, 'hasRunStartup') && ~getappdata(groot, 'hasRunStartup'))
    % TODO: force the correct path for this startup.m file in case there
    % are other startup.m files on the path.
    startup
    debugout('Executed startup script')
end

% This is where I put my initialization code
% -------------------------------------------------------------------------
config = getConfig;
Config = MDRTConfig.getInstance;

    % Add configuration struct to the handles struct
    handles.configuration = config;

    % populate the initial GUI text fields
    set(handles.uiTextbox_outputFolderTextbox, 'String', config.outputFolderPath);
    set(handles.uiTextbox_dataFolderTextbox, 'String', config.dataFolderPath);
    set(handles.uiTextbox_delimFolderTextbox, 'String', config.delimFolderPath);
    set(handles.uiTextbox_graphConfigFolderTextbox, 'String', config.graphConfigFolderPath);
    
    
% Instantiate handles.quickPlotFDs as type cell
handles.quickPlotFDs = cell(1);


% TODO:  Check the data path for a timeline.mat file and set the plotting
% engine flags accordingly (the plotGraphFromGUI function does this
% checking now)

% Looks for the following file to populate the FD List... In the future I
% might store more information here. Possibly valid times:
%
% AvailableFDs.mat

if exist(fullfile(config.dataFolderPath, 'AvailableFDs.mat'),'file')
	try
        load(fullfile(config.dataFolderPath, 'AvailableFDs.mat'),'-mat');

        % Add the loaded list to the GUI handles structure
        handles.quickPlotFDs = FDList;

        % add the list to the GUI menu
        set(handles.uiPopup_FDList, 'String', FDList(:,1));
    catch
        wrnMsg = sprintf('%s %s\n%s', 'Unable to read FD List.', ...
            'Check file permissions.', ...
            'Select "Update FD List" as a temporary workaround.');
        warning(wrnMsg);
    end
else
    
    % TODO: Should this do something if the file isn't there... maybe do
    % the initial parsing? That might be bad for the user experience...

end

% Fix GUI Font Sizes
% Later, use this code:
%   fixFontSizeInGUI(Config.fontScaleFactor)
if ispc
    fixFontSizeInGUI(gcf, 0.8);
    debugout('Scaling fonts for Windoze...')
elseif isunix && ~ismac
    fixFontSizeInGUI(gcf, 0.75);
    debugout('Scaling fonts for Linux!')
end

% Update handles structure
guidata(hObject, handles);


% UIWAIT makes review wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = review_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function uiTextbox_delimFolderTextbox_Callback(hObject, eventdata, handles)
% hObject    handle to uiTextbox_delimFolderTextbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of uiTextbox_delimFolderTextbox as text
%        str2double(get(hObject,'String')) returns contents of uiTextbox_delimFolderTextbox as a double


% --- Executes during object creation, after setting all properties.
function uiTextbox_delimFolderTextbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uiTextbox_delimFolderTextbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in uiButton_delimFolderBrowse.
function uiButton_delimFolderBrowse_Callback(hObject, eventdata, handles)
% hObject    handle to uiButton_delimFolderBrowse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

delimFolderPath = uigetdir(fullfile(handles.configuration.delimFolderPath,'..'));

% Make sure the user selected something!
if delimFolderPath ~= 0
    % We got a path selection. Now append the trailing / for linux
    % Note, we are not implementing OS checking at this time (isunix, ispc)
    delimFolderPath = [delimFolderPath '/'];
    handles.configuration.delimFolderPath = delimFolderPath;
    set(handles.uiTextbox_delimFolderTextbox, 'String', delimFolderPath);
else
    % oh noes, there was nothing selected!
    % right now I won't do anything... maybe later I will?
end
guidata(hObject, handles);



function uiTextbox_dataFolderTextbox_Callback(hObject, eventdata, handles)
% hObject    handle to uiTextbox_dataFolderTextbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of uiTextbox_dataFolderTextbox as text
%        str2double(get(hObject,'String')) returns contents of uiTextbox_dataFolderTextbox as a double


% --- Executes during object creation, after setting all properties.
function uiTextbox_dataFolderTextbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uiTextbox_dataFolderTextbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in uiButton_dataFolderBrowse.
function uiButton_dataFolderBrowse_Callback(hObject, eventdata, handles)
% hObject    handle to uiButton_dataFolderBrowse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

dataFolderPath = uigetdir(fullfile(handles.configuration.dataFolderPath,'..'));

% Make sure the user selected something!
if dataFolderPath ~= 0
    % We got a path selection. Now append the trailing / for linux
    % Note, we are not implementing OS checking at this time (isunix, ispc)
    dataFolderPath = [dataFolderPath '/'];
    handles.configuration.dataFolderPath = dataFolderPath;
    set(handles.uiTextbox_dataFolderTextbox, 'String', dataFolderPath);
    % Use existing FD list to update GUI on folder change
    populateFDlistFromDataFolder(hObject, handles, dataFolderPath);
else
    % oh noes, there was nothing selected!
    % right now I won't do anything... maybe later I will?
end

guidata(hObject, handles);


function uiTextbox_outputFolderTextbox_Callback(hObject, eventdata, handles)
% hObject    handle to uiTextbox_outputFolderTextbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of uiTextbox_outputFolderTextbox as text
%        str2double(get(hObject,'String')) returns contents of uiTextbox_outputFolderTextbox as a double


% --- Executes during object creation, after setting all properties.
function uiTextbox_outputFolderTextbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uiTextbox_outputFolderTextbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in uiButton_outputFolderBrowse.
function uiButton_outputFolderBrowse_Callback(hObject, eventdata, handles)
% hObject    handle to uiButton_outputFolderBrowse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

outputFolderPath = uigetdir(fullfile(handles.configuration.outputFolderPath,'..'));

% Make sure the user selected something!
if outputFolderPath ~= 0
    % We got a path selection. Now append the trailing / for linux
    % Note, we are not implementing OS checking at this time (isunix, ispc)
    outputFolderPath = [outputFolderPath '/'];
    
    handles.configuration.outputFolderPath = outputFolderPath;
    
    set(handles.uiTextbox_outputFolderTextbox, 'String', outputFolderPath);
    
    
else
    % oh noes, there was nothing selected!
    % right now I won't do anything... maybe later I will?
end
guidata(hObject, handles);


% --- Executes on button press in uiButton_saveProjectConfig.
function uiButton_saveProjectConfig_Callback(hObject, eventdata, handles)
% hObject    handle to uiButton_saveProjectConfig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% This does NO ERROR CHECKING!!!!
config = handles.configuration;
% save('review.cfg','config'); ### modified for cross-platform
% compatability. 
% TODO: Implement path checking and always save in program directory.
% Current implementation could break if browsing the file hiegherarchy with
% MATLAB in the background

if isdeployed
    save('review.cfg','config');
else
    save(fullfile(pwd,'review.cfg'),'config');
    
    [filepath,name,~] = fileparts(config.dataFolderPath);
    if strcmp(name, 'data')
        [filepath,~,~] = fileparts(filepath);
        Config = MDRTConfig.getInstance;
        Config.userWorkingPath = filepath;
        Config.userSavePath = fullfile(filepath, 'plots');
    end
    
end

% TODO: add an MDRTConfig call to "updateWorkingDirFromDataFolder"


% --- Executes on button press in uiButton_processDelimFiles.
function uiButton_processDelimFiles_Callback(hObject, eventdata, handles)
% hObject    handle to uiButton_processDelimFiles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

config = handles.configuration;

if ( exist(config.dataFolderPath,'dir') && exist(config.delimFolderPath,'dir') )
    % Confirmed that these folders DO EXIST
    try
        processDelimFiles(config);
    catch ME
       % Something went wrong with the parsing engine.
       % Errors will appear on console if the engine terminates abnormally
       % This is bad practice, but for now I am soft-failing without
       % displaying any error message from this function call. The parsing
       % engine has its own error handling
    end
        
    
    % Refresh the FD list
    uiButton_updateFDList_Callback(hObject, eventdata, handles);
    
else
    % Uh-OH!!! One of those folders was bad!
    % TODO: Error handling - popup error dialog?
end
    


% --- Executes on button press in uiButton_quickPlotFD.
function uiButton_quickPlotFD_Callback(hObject, eventdata, handles)
% hObject    handle to uiButton_quickPlotFD (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



index = get(handles.uiPopup_FDList,'Value');

fdFileName = fullfile(handles.configuration.dataFolderPath, handles.quickPlotFDs{index, 2} );

% TODO: Does you even need this, brah?

% If there is an events.mat file, then pass and plot t0
if exist([handles.configuration.dataFolderPath 'timeline.mat'],'file')
    
    load([handles.configuration.dataFolderPath 'timeline.mat'],'-mat')
        
    figureNumber = reviewQuickPlot( fdFileName, timeline);

else
    
    figureNumber = reviewQuickPlot( fdFileName );

end





% --- Executes on selection change in uiPopup_FDList.
function uiPopup_FDList_Callback(hObject, eventdata, handles)
% hObject    handle to uiPopup_FDList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns uiPopup_FDList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from uiPopup_FDList


% --- Executes during object creation, after setting all properties.
function uiPopup_FDList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uiPopup_FDList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in uiButton_updateFDList.
function uiButton_updateFDList_Callback(hObject, ~, handles)
% hObject    handle to uiButton_updateFDList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Calls helper function to list the FDs
    FDList = updateFDListFromDir(handles.configuration.dataFolderPath, ...
                                    'save',         'yes', ...
                                    'prompt',       'yes');
    
    if ~isempty(FDList)

        % adds to the GUI handles and
            handles.quickPlotFDs = FDList;

        % updates the dropdown.
            set(handles.uiPopup_FDList, 'String', FDList(:,1))
            
        % Fix dropdown selected index
            v = handles.uiPopup_FDList.Value;
            
            if v < 1
                v = 1;
                debugout('FDList index was less than 1')
            elseif v > length(handles.quickPlotFDs)
                v = length(handles.quickPlotFDs);
                debugout('FDList index bigger than the list length')
            end
            
            handles.uiPopup_FDList.Value = v;

        % Write the new list to disk
            writeFDListToDisk(FDList, handles);
            
    else
        
        % updates the dropdown.
            set(handles.uiPopup_FDList, 'String', ' ');
            set(handles.uiPopup_FDList, 'Value', 1);
            
        % Save updated index IF new is different from old
        setIndexFile = fullfile(handles.configuration.dataFolderPath, 'AvailableFDs.mat');
        try
            T = load(setIndexFile );
        catch
            warndlg({'The selected folder does not contain a valid AvailableFDs.mat file.';
                     'No data will be available until you change directories or import' }, ...
                     'Warning - empty data set') ;
             return
        end
        
        if isequal(T.FDList, FDList)
            debugout('FDList is unchanged');
            % No change, no save!
        else
            debugout('Old AvailableFDs.mat does not match current directory');
            debugout(setdiff(T.FDList, FDList));
            debugout('Saving new AvailableFDs.mat');
            writeFDListToDisk(FDList, handles);
        end
            
    end
        

guidata(hObject, handles);


% - used to write FDList / FDIndex to disk. Checks for permissions and
% fails gracefully with a warning message to the user.
function writeFDListToDisk(FDList, handles)

    fullFileName = fullfile(handles.configuration.dataFolderPath, 'AvailableFDs.mat');
    try
        save(fullFileName,'FDList');
    catch
        [status,values] = fileattrib(fullFileName);
        fields={'UserRead','UserWrite','UserExecute','GroupRead','GroupWrite','GroupExecute'};
        msgTxt = '';
        for i = 1:numel(fields)
            if values.(fields{i})
                msgTxt = sprintf('%s %s', msgTxt, fields{i});
            end
        end
        
        msgTxt = sprintf('Unable to save updated FD List to disk.\nAvailableFDs.mat can not be written.\nFile has the following permissions: %s', msgTxt);
        
        warning(msgTxt);
    end


% --- Executes on button press in uiButton_refreshTimelineEvents.
function uiButton_refreshTimelineEvents_Callback(hObject, eventdata, handles)
% hObject    handle to uiButton_refreshTimelineEvents (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
reviewRescaleAllTimelineEvents;

% --- Executes on button press in uiButton_rescaleFD.
function uiButton_rescaleFD_Callback(hObject, ~, handles)
% hObject    handle to uiButton_rescaleFD (see GCBO)
% handles    structure with handles and user data (see GUIDATA)
index = get(handles.uiPopup_FDList,'Value');
fdFullFileName = fullfile(handles.configuration.dataFolderPath, handles.quickPlotFDs{index, 2} );
rescaleFDfromFile(fdFullFileName);


% --- Executes on button press in uiButton_filterData.
function uiButton_filterData_Callback(hObject, eventdata, handles)
% hObject    handle to uiButton_filterData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

index = get(handles.uiPopup_FDList,'Value');
fdFullFileName = fullfile(handles.configuration.dataFolderPath, handles.quickPlotFDs{index, 2} );



filterFdTool(fdFullFileName);

% Launch the GUI that saves stuff
% reviewSavePlot


% --- Executes on button press in uiButton_plotSetup.
function uiButton_plotSetup_Callback(hObject, eventdata, handles)
% hObject    handle to uiButton_plotSetup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

makeGraphGUI;


% --- Executes on button press in uiButton_editTimelineEvents.
function uiButton_editTimelineEvents_Callback(hObject, eventdata, handles)
% hObject    handle to uiButton_editTimelineEvents (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

eventEditor;

% --------------------------------------------------------------------
function menu_review_help_Callback(hObject, eventdata, handles)
% hObject    handle to menu_review_help (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in uiButton_helpButton.
function uiButton_helpButton_Callback(hObject, eventdata, handles)
% Open web browser window to MDRT wiki homepage
web('https://gitlab.marsspaceport.com/data-review/MDRT/-/wikis/home')

% popup an "about" dialog with version info.
% helpDialogTitle = 'About Review Tool';
% helpDialogMessage = {'MARS Review Tool beta'; ...
%                      '10-8-2014'; ...
%                      'Quickstart guide coming soon'};
% 
% helpdlg(helpDialogMessage,helpDialogTitle);



function uiTextbox_graphConfigFolderTextbox_Callback(hObject, eventdata, handles)
% hObject    handle to uiTextbox_graphConfigFolderTextbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of uiTextbox_graphConfigFolderTextbox as text
%        str2double(get(hObject,'String')) returns contents of uiTextbox_graphConfigFolderTextbox as a double


% --- Executes during object creation, after setting all properties.
function uiTextbox_graphConfigFolderTextbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uiTextbox_graphConfigFolderTextbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in uiButton_graphConfigFolderBrowse.
function uiButton_graphConfigFolderBrowse_Callback(hObject, ~, handles)
graphConfigFolder = uigetdir(fullfile(handles.configuration.graphConfigFolderPath));

% Make sure the user selected something!
if graphConfigFolder ~= 0
    % We got a path selection. Now append the trailing / for linux
    % Note, we are not implementing OS checking at this time (isunix, ispc)
    graphConfigFolder = fullfile(graphConfigFolder);
    
    % Set the local configuration structure
    handles.configuration.graphConfigFolderPath = graphConfigFolder;
    
    % Populate the textbox
    set(handles.uiTextbox_graphConfigFolderTextbox, 'String', graphConfigFolder);
    
    
else
    % oh noes, there was nothing selected!
    % right now I won't do anything... maybe later I will?
end

% Update the GUI handles object
    guidata(hObject, handles);


% --- Executes on button press in uiButton_importData.
function uiButton_importData_Callback(~, ~, ~)
    makeDataImportGUI;



function populateFDlistFromDataFolder(hObject, handles, folder)

    if exist(fullfile(folder, 'AvailableFDs.mat'),'file')

        FDList = updateFDListFromDir(folder, 'save', 'no', 'prompt', 'no');
        
        % load(fullfile(folder, 'AvailableFDs.mat'),'-mat'); % REMOVED TO
        % TEST FASTER FDLIST UPDATING

        % Add the loaded list to the GUI handles structure
        handles.quickPlotFDs = FDList;

        % add the list to the GUI menu
        set(handles.uiPopup_FDList, 'String', FDList(:,1));

    else

        % TODO: Should this do something if the file isn't there... maybe do
        % the initial parsing? That might be bad for the user experience...

    end
    
    guidata(hObject, handles);
    


% --- Executes on button press in ui_newDataButton.
function ui_newDataButton_Callback(hObject, eventdata, handles)

    rootGuess = handles.configuration.dataFolderPath;

    % Austin Thomas: TESTING
    disp(rootGuess)
    
    if exist(fullfile(rootGuess),'dir')
        
    else
        rootGuess = pwd;
    end
    
    rootFolder = uigetdir(fullfile(rootGuess,'..'));

    % Make sure the user selected something!
    if rootFolder ~= 0
        % We got a path selection. Now append the trailing / for linux
        % Note, we are not implementing OS checking at this time (isunix, ispc)
        
        % Validate Selected Folder
        [rootPath, selectedFolder, ~] = fileparts(rootFolder);
        [oneUpRoot, oneUp, ~] = fileparts(rootPath);
        
        if any(strcmp(selectedFolder, {'data' 'delim' 'plots'}))

            dialogText = { sprintf('You selected a folder named %s.', selectedFolder);
                       sprintf('MDRT automatically creates a folder named %s during data import.', selectedFolder);
                       sprintf('Did you actually want to select "%s" data?', oneUp) };

            useOneUp    = sprintf('Use "%s"', oneUp);
            useSelected = sprintf('Use "%s"', selectedFolder);
            useNeither  = 'Cancel';

            ButtonName = questdlg(dialogText, ...
                             'Are you sure you selected the right folder?', ...
                             useOneUp, useSelected, useNeither, useOneUp);

            switch ButtonName
                case useOneUp,
                    disp(sprintf('%s selected', oneUp));
                    rootFolder = fullfile(oneUpRoot, oneUp);
                case useSelected,
                    disp(sprintf('%s selected', selectedFolder));
                case useNeither,
                    return;
                otherwise
                    return;
            end % switch
        end % if any (folders)
                
        dataFolderPath = [rootFolder filesep()];
        handles.configuration.dataFolderPath = dataFolderPath;
        set(handles.uiTextbox_dataFolderTextbox, 'String', dataFolderPath);
        % Use existing FD list to update GUI on folder change
        populateFDlistFromDataFolder(hObject, handles, dataFolderPath);
    else
        % oh noes, there was nothing selected!
        return
    end
    

    
    
    newDataPath  = fullfile(rootFolder, 'data',  filesep);
    newDelimPath = fullfile(rootFolder, 'delim', filesep);
    newPlotPath  = fullfile(rootFolder, 'plots', filesep);

    % Create new directory structure
    
    warning('off', 'MATLAB:MKDIR:DirectoryExists');
    
    mkdir(newDataPath);
    mkdir(newDelimPath);
    mkdir(fullfile(newDelimPath, 'original'));
    mkdir(fullfile(newDelimPath, 'ignore'));
    mkdir(newPlotPath);
    
    warning('on', 'MATLAB:MKDIR:DirectoryExists');
    
    % Update the handles structure
    handles.configuration.dataFolderPath    = newDataPath;
    handles.configuration.delimFolderPath   = newDelimPath;
    handles.configuration.outputFolderPath  = newPlotPath;
    
    % populate the initial GUI text fields
    set(handles.uiTextbox_dataFolderTextbox, 'String', newDataPath);
    set(handles.uiTextbox_delimFolderTextbox, 'String', newDelimPath);
    set(handles.uiTextbox_outputFolderTextbox, 'String', newPlotPath);
    
    guidata(hObject, handles);

    % Refresh the FD list
    uiButton_updateFDList_Callback(hObject, eventdata, handles);
    
    % Update the configuration automatically
    uiButton_saveProjectConfig_Callback([],[],handles);
    


% --- Executes on button press in compareDataButton.
function compareDataButton_Callback(hObject, eventdata, handles)
% hObject    handle to compareDataButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

makeDataComparisonGUI


% --- Executes on button press in PIDButton.
function PIDButton_Callback(hObject, eventdata, handles)
% hObject    handle to PIDButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
PIDSimulator


% --- Executes on button press in ui_button_ArchiveManager.
function ui_button_ArchiveManager_Callback(hObject, eventdata, handles)
% hObject    handle to ui_button_ArchiveManager (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Construct a questdlg with three options

cancelButton = 'Oops, sorry, forget I asked';
proceedButton = 'Shut up, I know what I''m doing';
defaultButton = cancelButton;

choice = questdlg('You are about to open the data archive manager. Only do this if you actually know what you are doing! You can really break stuff in here', ...
	'!! WARNING !!', ...
	cancelButton, proceedButton, defaultButton);
% Handle response
switch choice
    case cancelButton
    case proceedButton
        makeArchiveManagerGUI
    otherwise
end


% --- Executes on button press in pushbutton20.
function pushbutton20_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton20 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
MDRTFamilyPlotGUI


% --- Executes on button press in button_DatePicker.
function button_DatePicker_Callback(hObject, eventdata, handles)
% hObject    handle to button_DatePicker (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
MDRTdatePicker


% --- Executes on button press in uibutton_specialPlots.
function uibutton_specialPlots_Callback(hObject, eventdata, handles)
% hObject    handle to uibutton_specialPlots (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
specialPlotLauncher
