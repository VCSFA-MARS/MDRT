classdef GUIapp_converted < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                  matlab.ui.Figure
        TabGroup                  matlab.ui.container.TabGroup
        DataLoadTab               matlab.ui.container.Tab
        DataReviewProjectConfigurationPanel  matlab.ui.container.Panel
        ChoosepathTextArea        matlab.ui.control.TextArea
        ChoosepathTextAreaLabel   matlab.ui.control.Label
        BrowseButton              matlab.ui.control.Button
        GraphButton               matlab.ui.control.Button
        GraphingTab               matlab.ui.container.Tab
        SaveConfigurationPanel    matlab.ui.container.Panel
        TextArea                  matlab.ui.control.TextArea
        SaveFileLocationButton    matlab.ui.control.Button
        LabelsPanel               matlab.ui.container.Panel
        YAxisLabelEditField       matlab.ui.control.EditField
        YAxisLabelEditFieldLabel  matlab.ui.control.Label
        XAxisLabelEditField       matlab.ui.control.EditField
        XAxisLabelEditFieldLabel  matlab.ui.control.Label
        TitleEditField            matlab.ui.control.EditField
        TitleEditFieldLabel       matlab.ui.control.Label
        UIAxes                    matlab.ui.control.UIAxes
    end

    
    properties (Access = private)
         % .app object names for use, need to define them here to use
         % throughout the app
         date
         title
         filename
         dataFolderPath
         saveFilePath
         vert_axis_label
         horz_axis_label
    
    end
    




    % Callbacks that handle component events
    methods (Access = private)

        % Button pushed function: GraphButton
        function GraphButtonPushed(app, event)
            app.GraphButton.BackgroundColor=[0.4,0.4,0.3];
            app.GraphButton.Text = "Graphing...";
            pause(0.3)
            app.GraphButton.Text="Complete";
            app.GraphButton.BackgroundColor=[0.4660 0.6740 0.1880];
            
            
            % app.filename = input('Please type the filename including the extension (i.e. filename):\n','s');
% 
% loadData(app.filename);

%%%%%%%%%%%%
% if app.BrowseButtonPushed(~,:)==0
% 
%     opts=struct('WindowStyle','modal','Interpreter','tex') %to give the warning a lil *pizzaz*
%     warndlg('\color{Blue}Warning: No file input','No File Chosen',opts);
% end

            %switches tab
            app.TabGroup.SelectedTab=app.GraphingTab;

            pathCheck=exist(app.dataFolderPath);

            if app.TabGroup.SelectedTab==app.GraphingTab && pathCheck==0;
            
              
                warndlg('You are trying to graph without any data, please choose which data you want to graph first.',...
                    'WHAT ARE YOU DOING? Have you ever made a graph before with no data');
           
             app.TabGroup.SelectedTab=app.DataLoadTab;

            app.GraphButton.BackgroundColor=[0.96,0.96,0.96];
            app.GraphButton.Text="Graph";
            end

        end

        % Value changing function: TitleEditField
        function TitleEditFieldValueChanging(app, event)
            changingValue = event.Value;
            app.title= changingValue; %setting the changing value to the variable we made 
            %disp(app.title); %sanity check to make sure everything was going as planned

           app.UIAxes.Title.String=app.title; %sets the title string for the separate
           %  graphing function to the editable title box

        end

        % Button pushed function: BrowseButton
        function BrowseButtonPushed(app, event)
          
%opens a modal dialogue box so user can search for the data in their files
app.dataFolderPath = uigetdir('C:\',"Dummy Thicc Data"); % FIX: need to specify
%path more than just C:\ in the future

dataFolderPath=app.dataFolderPath; %app is picky so in order to display you
%have to make a variable and set it equal to the app.variable
%I tried to just straight up have dataFolderPath=uigetdir..... but it
%wouldn't display in the command window cause it didn't recognize it as a
%char or str even though if you set a break point and use
%class(app.Variable) it clearly says its type is "char"..... things be
%weird


app.ChoosepathTextArea.Value=dataFolderPath;


    figure(app.UIFigure); %keeps GUI open and not minimized since it auto minimizes after clicking browse



        end

        % Value changing function: XAxisLabelEditField
        function XAxisLabelEditFieldValueChanging(app, event)
            changingValue = event.Value; 
            
           app.horz_axis_label=changingValue; %shove changingValue into this variable
           app.UIAxes.XLabel.String=app.horz_axis_label; %tell the UIAxes label to use the text field we provided


        end

        % Value changing function: YAxisLabelEditField
        function YAxisLabelEditFieldValueChanging(app, event)
            changingValue = event.Value;
            app.vert_axis_label=changingValue; %same as before just change the variable names
            app.UIAxes.YLabel.String=app.vert_axis_label;
           
        end

        % Button pushed function: SaveFileLocationButton
        function SaveFileLocationButtonPushed(app, event)
          %same code as the Browse button just different variable names
            
            app.saveFilePath = uigetdir('C:\',"Choose wisely, this is where we send your graph");

        saveFilePath=app.saveFilePath;

        app.TextArea.Value=saveFilePath;

         figure(app.UIFigure);
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 640 480];
            app.UIFigure.Name = 'MATLAB App';

            % Create TabGroup
            app.TabGroup = uitabgroup(app.UIFigure);
            app.TabGroup.Position = [1 1 640 480];

            % Create DataLoadTab
            app.DataLoadTab = uitab(app.TabGroup);
            app.DataLoadTab.Title = 'Data Load';
            app.DataLoadTab.BackgroundColor = [0.9412 0.9412 0.9412];

            % Create GraphButton
            app.GraphButton = uibutton(app.DataLoadTab, 'push');
            app.GraphButton.ButtonPushedFcn = createCallbackFcn(app, @GraphButtonPushed, true);
            app.GraphButton.FontName = 'Segoe UI';
            app.GraphButton.Position = [19 159 100 24];
            app.GraphButton.Text = 'Graph';

            % Create DataReviewProjectConfigurationPanel
            app.DataReviewProjectConfigurationPanel = uipanel(app.DataLoadTab);
            app.DataReviewProjectConfigurationPanel.Title = 'Data Review Project Configuration';
            app.DataReviewProjectConfigurationPanel.BackgroundColor = [0.9412 0.9412 0.9412];
            app.DataReviewProjectConfigurationPanel.FontName = 'Segoe UI';
            app.DataReviewProjectConfigurationPanel.Position = [9 195 617 259];

            % Create BrowseButton
            app.BrowseButton = uibutton(app.DataReviewProjectConfigurationPanel, 'push');
            app.BrowseButton.ButtonPushedFcn = createCallbackFcn(app, @BrowseButtonPushed, true);
            app.BrowseButton.FontName = 'Segoe UI';
            app.BrowseButton.Position = [14 197 100 24];
            app.BrowseButton.Text = 'Browse';

            % Create ChoosepathTextAreaLabel
            app.ChoosepathTextAreaLabel = uilabel(app.DataReviewProjectConfigurationPanel);
            app.ChoosepathTextAreaLabel.HorizontalAlignment = 'right';
            app.ChoosepathTextAreaLabel.FontName = 'Segoe UI';
            app.ChoosepathTextAreaLabel.Position = [125 199 72 22];
            app.ChoosepathTextAreaLabel.Text = 'Choose path';

            % Create ChoosepathTextArea
            app.ChoosepathTextArea = uitextarea(app.DataReviewProjectConfigurationPanel);
            app.ChoosepathTextArea.Position = [212 199 383 24];

            % Create GraphingTab
            app.GraphingTab = uitab(app.TabGroup);
            app.GraphingTab.Title = 'Graphing';

            % Create UIAxes
            app.UIAxes = uiaxes(app.GraphingTab);
            title(app.UIAxes, 'Title')
            xlabel(app.UIAxes, 'X')
            ylabel(app.UIAxes, 'Y')
            zlabel(app.UIAxes, 'Z')
            app.UIAxes.FontName = 'Segoe UI';
            app.UIAxes.Position = [19 233 300 185];

            % Create LabelsPanel
            app.LabelsPanel = uipanel(app.GraphingTab);
            app.LabelsPanel.TitlePosition = 'centertop';
            app.LabelsPanel.Title = 'Labels';
            app.LabelsPanel.FontName = 'Segoe UI';
            app.LabelsPanel.Position = [344 214 260 221];

            % Create TitleEditFieldLabel
            app.TitleEditFieldLabel = uilabel(app.LabelsPanel);
            app.TitleEditFieldLabel.HorizontalAlignment = 'center';
            app.TitleEditFieldLabel.VerticalAlignment = 'bottom';
            app.TitleEditFieldLabel.FontName = 'Segoe UI';
            app.TitleEditFieldLabel.Position = [74 158 28 22];
            app.TitleEditFieldLabel.Text = 'Title';

            % Create TitleEditField
            app.TitleEditField = uieditfield(app.LabelsPanel, 'text');
            app.TitleEditField.ValueChangingFcn = createCallbackFcn(app, @TitleEditFieldValueChanging, true);
            app.TitleEditField.FontName = 'Segoe UI';
            app.TitleEditField.Position = [113 157 100 22];

            % Create XAxisLabelEditFieldLabel
            app.XAxisLabelEditFieldLabel = uilabel(app.LabelsPanel);
            app.XAxisLabelEditFieldLabel.HorizontalAlignment = 'right';
            app.XAxisLabelEditFieldLabel.FontName = 'Segoe UI';
            app.XAxisLabelEditFieldLabel.Position = [30 120 68 22];
            app.XAxisLabelEditFieldLabel.Text = 'X Axis Label';

            % Create XAxisLabelEditField
            app.XAxisLabelEditField = uieditfield(app.LabelsPanel, 'text');
            app.XAxisLabelEditField.ValueChangingFcn = createCallbackFcn(app, @XAxisLabelEditFieldValueChanging, true);
            app.XAxisLabelEditField.FontName = 'Segoe UI';
            app.XAxisLabelEditField.Position = [113 120 100 22];

            % Create YAxisLabelEditFieldLabel
            app.YAxisLabelEditFieldLabel = uilabel(app.LabelsPanel);
            app.YAxisLabelEditFieldLabel.HorizontalAlignment = 'right';
            app.YAxisLabelEditFieldLabel.FontName = 'Segoe UI';
            app.YAxisLabelEditFieldLabel.Position = [30 80 68 22];
            app.YAxisLabelEditFieldLabel.Text = 'Y Axis Label';

            % Create YAxisLabelEditField
            app.YAxisLabelEditField = uieditfield(app.LabelsPanel, 'text');
            app.YAxisLabelEditField.ValueChangingFcn = createCallbackFcn(app, @YAxisLabelEditFieldValueChanging, true);
            app.YAxisLabelEditField.FontName = 'Segoe UI';
            app.YAxisLabelEditField.Position = [113 80 100 22];

            % Create SaveConfigurationPanel
            app.SaveConfigurationPanel = uipanel(app.GraphingTab);
            app.SaveConfigurationPanel.Title = 'Save Configuration';
            app.SaveConfigurationPanel.FontName = 'Segoe UI';
            app.SaveConfigurationPanel.Position = [23 24 581 91];

            % Create SaveFileLocationButton
            app.SaveFileLocationButton = uibutton(app.SaveConfigurationPanel, 'push');
            app.SaveFileLocationButton.ButtonPushedFcn = createCallbackFcn(app, @SaveFileLocationButtonPushed, true);
            app.SaveFileLocationButton.FontName = 'Segoe UI';
            app.SaveFileLocationButton.Position = [46 36 110 24];
            app.SaveFileLocationButton.Text = 'Save File Location';

            % Create TextArea
            app.TextArea = uitextarea(app.SaveConfigurationPanel);
            app.TextArea.Position = [213 38 300 21];

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = GUIapp_converted

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end