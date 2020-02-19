%% TEL Rapid Retract Valve Firing - Specialty Plot
%
%   One-time script with hard-coded data files and paths. Generates a plot
%   with 6 subplots, x and y axes linked. Puts each valve in its own
%   subplot.

% path = '/Users/engineer/Data Repository/2018-11-16 - NG-10 Launch/data';
defaultpath = '/Users/engineer/Imported Data Repository/2019-03-27 - NG-11 Prep TELHS-6/data';

path = uigetdir(defaultpath); % No checking implemented yet!

%% Auto generate plot title:
defaultTitle = 'TEL Rapid Retract Valve Firing';
    
    if exist(fullfile(path, 'metadata.mat'),'file')
        load(fullfile(path, 'metadata.mat'), '-mat');
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
    fd = load(fullfile(path, files{i}));
    stairs(fd.fd.ts.Time, fd.fd.ts.Data, 'DisplayName', fd.fd.FullString);
    h_leg = legend('show')

    set(h_leg, 'Interpreter', 'none');
    
    reviewPlotAllTimelineEvents;
end

linkaxes(ax(1:end), 'xy')
dynamicDateTicks(ax(1:end), 'linked')
ax(1).YLim = [0 5];

% Override the data cursor text callback to show time stamp
    dcmObj = datacursormode(gcf);
    set(dcmObj,'UpdateFcn',@dateTipCallback,'Enable','on');
