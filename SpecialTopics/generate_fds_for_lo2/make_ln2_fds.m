fds = {'CB7 Analog In 04  Mon';
       'CB7 Analog In 05  Mon'
      };




%% Calculate MARS-10 Ullage Pressure

press_fd = load_fd_by_name('CB7 Analog In 05  Mon');

% --------------------------------------------------------
% |             Tank Ullage Sensor Constants             |
% --------------------------------------------------------

PRESS_SENSOR_FD = "CB7 Analog In 05  Mon" % CB7_AI3_I1 PT-3396 0-300

PRESS_SENSOR_RANGE = 300;
OFF_SCALE_HIGH = 32769;
OFF_SCALE_LOW  = 32770;
MAX_SCALE = 30000;

proc_vals = press_fd.ts.Data ./ MAX_SCALE * PRESS_SENSOR_RANGE;

fd = newFD();
fd.ID = '3396';
fd.Type = 'PT';
fd.System = 'LN2';
fd.FullString = 'LN2 PT-3396 Press Sensor  Mon';
fd.ts = press_fd.ts;
fd.ts.Data = proc_vals;
fd.ts.Name = fd.FullString;
fd.ts.DataInfo.Units = 'psig';

save_fd_to_disk(fd);


%% Calculate MARS-10 Tank Level

press_fd = load_fd_by_name('CB7 Analog In 05  Mon');

% --------------------------------------------------------
% |        Level Sensor and Tank Volume Constants        |
% --------------------------------------------------------

LEVEL_SENSOR_FD = "CB7 Analog In 04  Mon"; % CB7_AI2_I4 LS-3394  

LEVEL_SENSOR_RANGE = 600.0; % inches

TANK_NET_VOLUME = 15060.0 ; % Gallons

TANK_BOT_SEG_HEIGHT = 22.5; % inches
TANK_TOP_SEG_HEIGHT = 361.6; % inches

TANK_BOT_MAX_VOL = 588.0; % GAL
TANK_TOP_MAX_VOL = 15051.0; % GAL

TANK_BOT_SLOPE = TANK_BOT_MAX_VOL / TANK_BOT_SEG_HEIGHT;
TANK_TOP_SLOPE = (TANK_TOP_MAX_VOL-TANK_BOT_MAX_VOL) / (TANK_TOP_SEG_HEIGHT - TANK_BOT_SEG_HEIGHT);

LN2_SPECIFIC_GRAVITY = 0.808;
H2O_INCH_TO_PSI = 0.0360912;
INCH_CUBE_TO_GAL = 0.004329;


dpt_fd = load_fd_by_name('CB7 Analog In 04  Mon');



tank_dp = dpt_fd.ts.Data * LEVEL_SENSOR_RANGE / MAX_SCALE;
tank_level = tank_dp / LN2_SPECIFIC_GRAVITY;

cyl_slope = (15051.0 - TANK_BOT_MAX_VOL) / (TANK_TOP_SEG_HEIGHT - TANK_BOT_SEG_HEIGHT);
bot_slope = TANK_BOT_MAX_VOL / TANK_BOT_SEG_HEIGHT;

tank_vol = tank_level;
in_bot = tank_level <= TANK_BOT_SEG_HEIGHT;
in_top = ~in_bot;

tank_vol(in_bot) = (tank_dp(in_bot) * bot_slope);
tank_vol(in_top) = (tank_dp(in_top) - TANK_BOT_SEG_HEIGHT) * cyl_slope + TANK_BOT_MAX_VOL;


fd = newFD();
fd.ID = '3394';
fd.Type = 'LS';
fd.System = 'LN2';
fd.FullString = 'LN2 LS-3394 Level Sensor  Mon';
fd.ts = dpt_fd.ts;
fd.ts.Data = tank_vol;
fd.ts.Name = fd.FullString;
fd.ts.DataInfo.Units = 'gal';

save_fd_to_disk(fd);


fd.ID = '3394';
fd.Type = 'dPT';
fd.System = 'LN2';
fd.FullString = 'LN2 dPT-3394 Press Sensor  Mon';
fd.ts = dpt_fd.ts;
fd.ts.Data = tank_dp * H2O_INCH_TO_PSI; % Calculated in "H2O
fd.ts.Name = fd.FullString;
fd.ts.DataInfo.Units = 'psid';

save_fd_to_disk(fd);


fd.ID = '3394';
fd.Type = 'LH';
fd.System = 'LN2';
fd.FullString = 'LN2 LH-3394 Liquid Height Mon';
fd.ts = dpt_fd.ts;
fd.ts.Data = tank_level;
fd.ts.Name = fd.FullString;
fd.ts.DataInfo.Units = 'inches';

save_fd_to_disk(fd);


% Calculate the output pressure - must build new pressure fd to do math
new_time_vect = unique(sort(vertcat(dpt_fd.ts.Time, press_fd.ts.Time)));

dpt_fd.ts.Data = tank_dp;
press_fd.ts.Data = proc_vals;

new_dp = dpt_fd.ts.resample(new_time_vect);
new_ul = press_fd.ts.resample(new_time_vect);

outlet_press = new_ul + (new_dp * H2O_INCH_TO_PSI);

fd.ID = '3394';
fd.Type = 'cPT';
fd.System = 'LN2';
fd.FullString = 'LN2 MARS-10 Discharge Pressure Mon';
fd.ts = outlet_press;
fd.ts.Name = fd.FullString;
fd.ts.DataInfo.Units = 'psig';

save_fd_to_disk(fd);
%% Calculate MARS-10 Discharge Pressure
