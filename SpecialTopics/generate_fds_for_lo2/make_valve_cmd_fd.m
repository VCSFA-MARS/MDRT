function [new_fd] = make_valve_cmd_fd(cmd_fd_str, cmd_fd)
%make_valve_cmd_fd creates and properly populates the FD struct for a
%discrete valve command - use this on Spare Discrete Channel FDs

SYSTEM_STRS = ['RP1', 'LO2', 'LN2', 'GHE', 'GN2'];

% state_fd_str = 'DCVNC-2152 State';


% 'LO2 DCVNC-2006 Ball Valve  Ctl Param'
% 'LO2 PCVNO-2013 Globe Valve  Cmd Param'


new_fd = newFD;
new_fd.FullString = cmd_fd_str;

this_fd_info       = getDataParams(cmd_fd_str);
new_fd.ID          = this_fd_info.ID;
new_fd.Type        = this_fd_info.Type;
new_fd.System      = this_fd_info.System;
new_fd.FullString  = this_fd_info.FullString;
new_fd.isValve     = true;

% Fix Missing Commodity Marker
if ~contains(SYSTEM_STRS, upper(new_fd.System))
    [~, is_numeric] = str2num(cmd_fd.Type);
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

% 'LO2 DCVNC-2006 Ball Valve  Ctl Param'
% 'LO2 PCVNO-2013 Globe Valve  Cmd Param'

new_fd_str = [ new_fd.System ' ' ...
               new_fd.Type '-' ...
               new_fd.ID ' Ball Valve  Ctl Param'];

new_fd.FullString = new_fd_str;

cmd_ts = cmd_fd.ts;
cmd_ts.Name = new_fd.FullString;

new_fd.ts = cmd_ts;

end