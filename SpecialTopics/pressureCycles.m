% Data massager for storage vessel pressure cycle analysis
% This can be stuffed into a function/gui for easier analysis.

% Sorry for the hardcoded fd struct. 

input_data_file = '~/data/import/2023-01-02 - All MPGN2 Storage Pressure Data/data/5902 GN2 PT-5902 Press Sensor Mon - Filtered.mat';
output_excel_file = '~/Downloads/2023 MP GN2 Pressure.xlsx';

load(input_data_file);
t = fd.ts.Time;
p = fd.ts.Data;

lmax = islocalmax(p, "MinSeparation", 100, "MinProminence", 100);
lmin = islocalmin(p, "MinSeparation", 100, "MinProminence", 100);

lring = islocalmax(p, "MinSeparation", 100);


figure();
plot(t, p, 'DisplayName', 'MP GN2 Storage Pressure Peak Analysis');
hold on;

% pr = plot(t(lring), p(lring), 'LineStyle','none', 'Marker','*','Color','magenta');
pp = plot(t(lmax), p(lmax), 'LineStyle','none', 'Marker','*','Color','r');
pq = plot(t(lmin), p(lmin), 'LineStyle','none', 'Marker','*','Color','r');

dynamicDateTicks;
plotStyle;

lall = lmax | lmin;

press_table = table(cellstr(datestr(t(lall))), ...
                    m2xdate(t(lall)), p(lall),  ...
                    'VariableNames',{'DateString', 'ExcelDateNum', 'Pressure'})

writetable(press_table, output_excel_file, 'Sheet',1)
