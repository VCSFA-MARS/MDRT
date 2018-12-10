%% TEL Rapid Retract Valve Firing - Specialty Plot
%
%   One-time script with hard-coded data files and paths. Generates a plot
%   with 6 subplots, x and y axes linked. Puts each valve in its own
%   subplot.

path = '/Users/engineer/Data Repository/2018-11-16 - NG-10 Launch/data';

files = {   'TELHS RRFPV1 Device Status.mat';
            'TELHS RRFPV2 Device Status.mat';
            'TELHS RRFPV3 Device Status.mat';
            'TELHS RRFPV4 Device Status.mat';
            'TELHS RRFPV5 Device Status.mat';
            'TELHS RRFPV6 Device Status.mat'};
        
f = makeMDRTPlotFigure;

ax = MDRTSubplot(2, 3);
suptitle('NG-10 TEL Rapid Retract Valve Firing')

for i = 1:numel(files)
    axes(ax(i));
    fd = load(fullfile(path, files{i}));
    stairs(fd.fd.ts.Time, fd.fd.ts.Data, 'DisplayName', fd.fd.FullString);
    legend show
end

linkaxes(ax(1:end), 'xy')
dynamicDateTicks(ax(1:end), 'linked')

