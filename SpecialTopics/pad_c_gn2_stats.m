%% pad_c_gn2_stats 
% prints statistics for use in our overview plots.
% use data brushing and save as the default name 'brushedData'
% then execute the appropriate code block and paste into a text box

%% Average consumption rate in psig

tm = trendMath(brushedData);
min = tm.rate
hr = min * 60;
day = hr * 60;

sprintf('%.3f psig/min\n%.1f psig/hr\n%.0f psig/day', min, hr, day)

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

%% 
