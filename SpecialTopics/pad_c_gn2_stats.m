%% pad_c_gn2_stats 
% prints statistics for use in our overview plots.
% use data brushing and save as the default name 'brushedData'
% then execute the appropriate code block and paste into a text box

%% Snap Time Axes to center on a single day with 1 hr margin

oneHr = 1/24;
middle_time = mean(gca().XLim);
day_rate = floor(middle_time);

ax = findall(gcf, 'tag', 'MDRTAxes');
set(ax, 'XLim', [day_rate - oneHr, day_rate + 1 + oneHr]);

%% Average consumption rate in psig
% 1) save brushed data as 'brushedData'
% 2) place and select a textbox above the brushed data
% 3) run this section of code


hl = findall(gcf, 'Type', 'Stair'); % get all lines in plot
l_ind = strcmpi({hl.DisplayName}, 'PT-5902'); %find MGPN2
hl = hl(l_ind);
bh = hl.BrushHandles;

brushedIdx = logical(hl.BrushData);
brushedTime = hl.XData(brushedIdx)';
brushedData = hl.YData(brushedIdx)';
bLim = [brushedTime(1), brushedTime(end)];


% Do Calculations and build string
tm = trendMath([brushedTime, brushedData]);
min_rate = tm.rate;
hr_rate = min_rate * 60;
day_rate = hr_rate * 60;

trend_string = sprintf('%.3f psig/min\n%.1f psig/hr\n%.0f psig/day', min_rate, hr_rate, day_rate)
box_str = splitlines(trend_string);



% Try to find a textbox that overlaps this window
htb = findall(gcf,'Type',  'TextBox', 'Parent', hl.Parent);
if isempty(htb)
    % make a textbox - position values are normalized to axes limits
    hax = hl.Parent;
    time_width = diff(hax.XLim);
    brush_start_delta = (bLim(1) - hax.XLim(1));
    brush_start_norm = brush_start_delta / time_width;
    box_height = 0.05

    xapf = @(x,pos,xl) pos(3)*(x-min(xl))/diff(xl)+pos(1);                % 'x' Annotation Position Function
    yapf = @(y,pos,yl) pos(4)*(y-min(yl))/diff(yl)+pos(2);                % 'y' Annotation Position Function
    
    tb_pos = [ xapf(min(bLim), hax.Position, hax.XLim), ...
               hax.Position(2) + 0.6*hax.Position(4), ...
               0.05, 0.05];

    htb = annotation('textbox', tb_pos, 'String', '')
    

else
    htb = findall(gcf,'Type',  'TextBox', 'Selected', 'on');
end

htb.String = box_str;
htb.FitBoxToText = 'on';





%% Flow Meter Consumption Data
avg = mean(brushedData(:,2));
lbm = integrateTotalFlow(brushedData, 's');
scf = lbm * 13.803

mpv = 1800*2
mol = 775645
m_gn2 = 28.02
kg_storage = mol * m_gn2 / 1000
sprintf('%f', kg_storage)
kg2scf = 30.42
21733.572900 * kg2scf

one_storage_scf = 21733.572900 * kg2scf
perc = scf/one_storage_scf

sprintf('%.3f lbm/s average flow\n%.0f lbm total flow\n%.1f%% of total MPGN2 Storage', avg, lbm, perc*100)

%% Update selected textbox

tb_sel = findall(gcf,'Type',  'TextBox', 'Selected', 'on');


