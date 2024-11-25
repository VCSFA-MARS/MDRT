function [state_fd] = make_state_fd_from_inds(state_fd_str, open_ind_fd, close_ind_fd)
%make_state_fd_from_inds Processes the switch state FDs and generates a
%state fd for use with the usual MDRT visualizations

state_fd = newFD;
state_fd.FullString = state_fd_str;

new_fd         = getDataParams(state_fd_str);
state_fd.ID          = new_fd.ID;
state_fd.Type        = new_fd.Type;
state_fd.System      = new_fd.System;
state_fd.FullString  = new_fd.FullString;
state_fd.isValve     = true;

%% Fix Missing Commodity Marker

SYSTEM_STRS = ['RP1', 'LO2', 'LN2', 'GHE', 'GN2'];

if ~contains(SYSTEM_STRS, upper(new_fd.System))
    [~, is_numeric] = str2num(new_fd.ID);
    if ~is_numeric
        new_type = new_fd.System;
        new_id = new_fd.Type;
        switch(new_id(1))
            case '1'
                sys_str = 'RP1';
            case '2'
                sys_str = 'LO2';
            case '3'
                sys_str = 'LN2';
            case '4'
                sys_str = 'GHE';
            case '5'
                sys_str = 'GN2';
            otherwise
                sys_str = '';
        end
        
        new_fd.ID = new_id;
        new_fd.Type = new_type;
        new_fd.System = sys_str;
    end
end



% 'LO2 DCVNC-2006 State'
new_fd_str = [ new_fd.System ' ' ...
               new_fd.Type '-' ...
               new_fd.ID ' State'];

new_fd.FullString = new_fd_str;

%% Prepare to step through both switch FDs

% close = '/Users/nick/data/import/2023-11-30 - RP1 Flow Test day 2/data/1010 RP1 DCVNC-1010 Ball Valve Close Ind.mat' 
% open = '/Users/nick/data/import/2023-11-30 - RP1 Flow Test day 2/data/1010 RP1 DCVNC-1010 Ball Valve Open Ind.mat'

timevect = sort(unique([open_ind_fd.ts.Time; close_ind_fd.ts.Time]));
open_ts = open_ind_fd.ts;
close_ts = close_ind_fd.ts;

state_time = [];
state_data = [];


for n = 1:length(timevect)
    this_time = timevect(n);
    this_open = open_ts.getsampleusingtime(0, this_time);
    this_close = close_ts.getsampleusingtime(0, this_time);

    % Undefined state if no switch data have been logged for either switch
    if isempty(this_open.Data) | isempty(this_close.Data)
        continue
    end

    this_open_val = this_open.Data(end);
    this_close_val = this_close.Data(end);

    this_state = make_state(this_open_val, this_close_val);
    state_data = vertcat(state_data, this_state);
    state_time = vertcat(state_time, this_time);
end

state_data = double(state_data);

state_ts = timeseries(state_data, state_time, 'Name', new_fd.FullString);

state_fd.ts = state_ts;

end




function state = make_state(open, close)

    if ~open && close
        state = 0;
    elseif open && ~close
        state = 1;
    elseif ~open && ~close
        state = 2;
    elseif open && close
        state = 3;
    else
        error('Undefined valve state')
    end

end