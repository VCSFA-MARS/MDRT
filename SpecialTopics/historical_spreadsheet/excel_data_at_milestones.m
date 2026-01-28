milestones_list = {
  'LOLS Transfer Line Chill Cmd', true;
  'LOLS LHFO Cmd', true;
  'LOLS Stop Flow Cmd', true;
  'T+10 Min', false;
};

fd_strs = {
  'Ghe PT-4930 Press Sensor Mon'˙¬
  'Ghe TC-4928 Temp Sensor Mon';≥
};

HEADER_ROWS = 2;

one_hr = 1/24;
one_min = one_hr/60;

config = MDRTConfig.getInstance;
t = load(fullfile(config.dataArchivePath, 'dataIndex.mat'));
dataIndex = t.dataIndex;

% all_ms = {};
% flag_first_run = true;

col_heads = cell(1,numel(fd_strs));
for n = 1:numel(fd_strs)
  this_fd = load_fd_by_name(fd_strs{n}, 'folder', dataIndex(end).pathToData);
  col_heads{1,n} = sprintf('%s (%s)', displayNameFromFD(this_fd), this_fd.ts.DataInfo.Units);
end

col_heads = horzcat({'Mission', 'Date'}, repmat(col_heads', length(milestones_list), 1)');
out_data = cell(length(dataIndex), length(col_heads));

out_data(2,:) = col_heads;
for c = 1:length(milestones_list)
  col = 1 + (c * 2);
  out_data{1, col} = milestones_list{c,1};
end



set_times = [];
%% Loop through each data set
for ds_ind = 1:numel(dataIndex)

  row = ds_ind + HEADER_ROWS;

  this_set = dataIndex(ds_ind);
  this_end_time = this_set.metaData.timeSpan(end);
  this_end_time_str = datestr(this_end_time);
  this_set_path = this_set.pathToData;
  this_set_name = this_set.metaData.operationName;

  if contains(this_set_name, 'Scrub')
    fprintf('Skipping scrub: %s\n', this_set_name)
    continue
  end

  e = load(fullfile(this_set_path, 'timeline.mat'));
  timeline = e.timeline;
  set_milestones = timeline.milestone;

  % if flag_first_run && isempty(all_ms)
  %   all_ms = {set_milestones.FD}';
  %   flag_first_run = false;
  % else
  %   disp(this_set_name)
  %   all_ms = intersect(all_ms, {set_milestones.FD}')
  % end
  
  
  times = make_times_vect_for_set_from_milestones(timeline, milestones_list);
  
  out_data{row, 1} = this_set_name;
  out_data{row, 2} = this_end_time_str;
  


  %% Loop through each milestone
  for m = 1:numel(times)
    this_milestone = get_matching_milestone(milestones_list{m}, set_milestones);



    this_time = times(m);
    col_start = 2+ 2*(m-1);

    %% Loop through each FD
    for n = 1:numel(fd_strs)
      this_fd_str = fd_strs{n};
      thisFD = load_fd_by_name(this_fd_str, 'folder', this_set_path);
      this_data = get_value_from_fd_at_time(thisFD, this_time);    
      
      out_data{row, col_start + n} = this_data;
    end


  end




end

function times = make_times_vect_for_set_from_milestones(timeline, milestones_list)

  one_hr = 1/24;
  one_min = one_hr/60;

  milestone_vect = timeline.milestone;
  uset0 = timeline.uset0;
  t0 = timeline.t0;

  times = zeros(length(milestones_list), 1);
  for i = 1:length(milestones_list)
    if milestones_list{i, 2}
      tms = get_matching_milestone(milestones_list{i,1}, milestone_vect);
      times(i) = tms.Time;
    else
      if ~uset0
        continue
      end
      times(i) = t0.time + 5*one_min;
    end
  end
end


function milestone = get_matching_milestone(fd_str, milestone_vect)
  milestone = [];
  for i = 1:numel(milestone_vect)
    if strcmpi(milestone_vect(i).FD, fd_str)
      milestone = milestone_vect(i);
      return
    end
  end
end

function value = get_value_from_fd_at_time(fd_struct, time)
  ts = getsampleusingtime(fd_struct.ts, 0,time);
  value = ts.Data(end);
end