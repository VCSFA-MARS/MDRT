function MDRTdatePicker

%% Load Figure and get handle structure

hf = openfig('SpecialTopics/time/MDRTdatePicker.fig');

uicomponents = { 'utcDateStringBox';
                 'uipanel1';
                 'cancelButton';
                 'selectButton';
                 };

for i = 1:numel(uicomponents)
    hs.(uicomponents{i}) = findobj(hf, 'Tag', uicomponents{i} );
end
             
%% Populate uipanel with java date picker


com.mathworks.mwswing.MJUtilities.initJIDE;
jPanel = com.jidesoft.combobox.DateChooserPanel;
[hPanel,hContainer] = javacomponent(jPanel,[10,10,300,300],hs.uipanel1);

    hContainer.Units = 'norm';
    hContainer.Position = [0 0 1 1];

jPanel.setShowWeekNumbers(false);    % Java syntax
set(hPanel,'ShowTodayButton',true);  % Matlab syntax

% jModel = hPanel.getSelectionModel;  % a com.jidesoft.combobox.DefaultDateSelectionModel object
% jModel.setSelectionMode(jModel.MULTIPLE_INTERVAL_SELECTION);

%% Instantiate Java Date Manipulation Objects
    % import the Java classes needed for this process
        import java.text.SimpleDateFormat ;
        import java.util.Date ;
        import java.util.TimeZone ;
    % instantiate a SimpleDateFormat object with a fixed time/date format and UTC time zone
        utcFormatObject = SimpleDateFormat('yyyy-MM-dd HH:mm:ss') ;
        utcFormatObject.setTimeZone(TimeZone.getTimeZone('UTC')) ;


        

%% Set Callback for date selection update!

hModel = handle(hPanel.getSelectionModel, 'CallbackProperties');
set(hModel, 'ValueChangedCallback', @selectionChangedCallback );


    function thisDateNum = selectionChangedCallback(hobj, ~)
        
        thisDateJStr = utcFormatObject.format(hobj.getSelectedDate);
        thisDateChar = char(thisDateJStr);
        thisDateNum = datenum(thisDateChar);
        
        % hs.utcDateStringBox.String = thisDateChar;
        
        dayOfYear = day(datetime(thisDateChar, 'inputformat', 'yyyy-MM-dd hh:mm:ss'), 'dayofyear');
        
        thisDateTAM_Str = sprintf('%d%03d_%s', year(thisDateNum), dayOfYear, datestr(datenum(thisDateChar), 'HHMMSS') );
        
        hs.utcDateStringBox.String = thisDateTAM_Str;
    end


end
