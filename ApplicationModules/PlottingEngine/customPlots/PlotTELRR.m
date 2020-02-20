%% TEL Rapid Retract Valve Firing - Specialty Plot
%
%   One-time script with hard-coded data files and paths. Generates a plot
%   with 6 subplots, x and y axes linked. Puts each valve in its own
%   subplot.

%% Prompt user for data set - start with set selected in 'review'

config = MDRTConfig.getInstance;
[pth, fldr, b] = fileparts(config.userWorkingPath);
questStr = ['Generate plot from data set in ', fldr];

result = questdlg(questStr, 'Continue with data set', ...
            'Yes', 'Select New', 'Quit', 'Yes');

switch result
    case 'Yes'     
        
    case 'Select New'
        hbox = msgbox('Select the ''data'' folder that contains the .mat files.', 'Directions');
        uiwait(hbox, 5);
        defaultpath = config.dataArchivePath;
        pth = uigetdir(defaultpath); % No checking implemented yet!;
        
    case 'No'    
        disp('Quitting plot tool');
        return
        
    otherwise
        disp('Unknown selection');
        return
end


%% Auto generate plot title:
defaultTitle = 'TEL Rapid Retract Valve Firing';
    
    if exist(fullfile(pth, 'metadata.mat'),'file')
        load(fullfile(pth, 'metadata.mat'), '-mat');
        plotTitle = '';
        if metaData.isOperation
            plotTitle = [plotTitle, metaData.operationName];
        end
        if metaData.isMARSprocedure
            plotTitle = [plotTitle, ' ', metaData.MARSprocedureName];
        end
        
        plotTitle = [plotTitle, ' ', 'Rapid Retract Valve Firing'];
    else
        plotTitle = defaultTitle;
    end
    
    if exist(fullfile(pth, 'timeline.mat'), 'file')
        tl = load(fullfile(pth, 'timeline.mat'), '-mat');
    else
        warning(['Could not load ', fullfile(pth, 'timeline.mat')]);
        tl = struct;
        tl.timeline = newTimelineStructure;
    end



files = {   'TELHS RRFPV1 Device Status.mat';
            'TELHS RRFPV2 Device Status.mat';
            'TELHS RRFPV3 Device Status.mat';
            'TELHS RRFPV4 Device Status.mat';
            'TELHS RRFPV5 Device Status.mat';
            'TELHS RRFPV6 Device Status.mat'};
        
f = makeMDRTPlotFigure;

ax = MDRTSubplot(2, 3);
H_ST = suptitle(plotTitle);
H_ST.Interpreter = 'none';

for i = 1:numel(files)
    axes(ax(i));
    fd = load(fullfile(pth, files{i}));
    stairs(fd.fd.ts.Time, fd.fd.ts.Data, 'DisplayName', fd.fd.FullString);
    h_leg = legend('show');

    set(h_leg, 'Interpreter', 'none');
    
    reviewPlotAllTimelineEvents(tl.timeline);
end

linkaxes(ax(1:end), 'xy')
dynamicDateTicks(ax(1:end), 'linked')
ax(1).YLim = [0 5];

% Override the data cursor text callback to show time stamp
    dcmObj = datacursormode(gcf);
    set(dcmObj,'UpdateFcn',@dateTipCallback,'Enable','on');
