
%% Generate milestone list from `times` variable

temp_timeline = newTimelineStructure;
new_milestones = [];


event_name = 'HSS High Flow Testing';
event_fd = 'HSS High Flow';

% event_name = 'HSS T-2 Flow Testing';
% event_fd = 'HSS T-2';

% event_name = 'HSS Autosequence Flow Testing';
% event_fd = 'HSS Autosequence';

% event_name = 'HSS Off Nominal Testing';
% event_fd = 'HSS Off-Nom';

for i = 1:size(times,2)
    this_event = struct( ...
        'String', event_name, ...
        'FD', event_fd, ...
        'Time', times(i).Position(1) ...
    );

    new_milestones = vertcat(new_milestones, this_event);

end

%% Update/Create timeline file for current repository

config = getConfig;
CREATE_TIMELINE = false;

timeline_file = fullfile(config.dataFolderPath, 'timeline.mat');
this_timeline = [];
this_milestone = [];

if exist(timeline_file, 'file')
    disp('appending to existing timeline file')
    s = load(timeline_file);
    this_timeline = s.timeline;
    this_milestone = this_timeline.milestone;
    this_milestone = vertcat(this_milestone, new_milestones);
    this_timeline.milestone = this_milestone;
    
else
    CREATE_TIMELINE = true;
    disp('creating new timeline file')
    this_timeline = newTimelineStructure;
    this_timeline.milestone = new_milestones;

end

disp('writing timeline file to disk')
timeline = this_timeline;
save(timeline_file, 'timeline')

