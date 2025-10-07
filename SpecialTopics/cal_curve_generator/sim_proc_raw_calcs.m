curves = [

    struct( 'name', '1901', ...
            'raw_to_proc',	[0	0.4398	0.000060815	-1.42E-09], ...
            'proc_to_raw',	[0.00E+00	1.54E+00	-5.65E-05	1.28E-09], ...
            'raw_range',   'default' );
                                
    struct( 'name', '2902', ...
            'raw_to_proc',	[0	1.65	0.0006435	-2.67E-08], ...
            'proc_to_raw',	[0	0.36	-6.15E-06	5.12E-11], ...
            'raw_range',    0:100:14720 );
                                
    struct( 'name', '3917', ...
            'raw_to_proc',	[-0.1	0.00419	0.000002232	-1.52E-10], ...
            'proc_to_raw',	[238.92	120.72	-1.01E+00	6.00E-03], ...
            'raw_range',   0:50:8200 );

    struct( 'name', '3918', ...
            'raw_to_proc',	[-0.1	0.00419	0.000002232	-1.52E-10], ...
            'proc_to_raw',	[238.92	120.72	-1.01E+00	6.00E-03], ...
            'raw_range',   0:50:8200 );
                                
    struct( 'name', '4914', ...
            'raw_to_proc',	[3.9067	    0.171161	-5.61E-07	2.66E-11	-4.10E-16], ...
            'proc_to_raw',	[-2.28E+01	5.84E+00	1.21E-04	3.41E-08	3.14E-12], ...
            'raw_range',   'default' );

    struct( 'name', '4915', ...
            'raw_to_proc',	[6.381	    0.1698019	-3.92E-07	2.08E-11	-3.41E-16], ...
            'proc_to_raw',	[-3.76E+01	5.89E+00	8.40E-05	-2.64E-08	2.58E-12], ...
            'raw_range',   'default' );

    struct( 'name', '4918', ...
            'raw_to_proc',	[0.03929331	0.16753	    -2.69E-07	1.55E-11	-2.59E-16], ...
            'proc_to_raw',	[2.36E-01	5.96E+00	6.70E-05	-2.31E-08	2.31E-12], ...
            'raw_range',   'default' );

    struct( 'name', '4919', ...
            'raw_to_proc',	[-3.2	    0.16501	    9.10E-08	-4.90E-12	1.20E-16], ...
            'proc_to_raw',	[1.92E+01	6.02E+00	3.16E-05	-1.35E-08	1.47E-12], ...
            'raw_range',   'default' );
                                
    struct( 'name', '4934', ...
            'raw_to_proc',	[0.117396	0.3369	-7.26E-07	5.55E-11	-1.44E-15], ...
            'proc_to_raw',	[-0.0132501	2.8383	2.07E-04	-9.63E-08	1.89E-11	-1.32E-15], ...
            'raw_range',   'default' );
];

RAW_RANGE = [1:30000]';
RAW_CALC_RANGE = [1:30000/60:30000];
ORDER_LOW = 2;
ORDER_HIGH = 5;

all_figs = [];


%% Output Table Instantiation
poly_orders = ORDER_LOW:ORDER_HIGH;
table_cols = {};
for i = 1:numel(poly_orders)
    table_cols = horzcat(table_cols, sprintf('%d_order', poly_orders(i)));
end

out_table = table;



%% Process Polys - do the math

calc_poly = @(C, x) polyval(fliplr(C), x);

for ci = 1:length(curves)
    curve = curves(ci);
    out_table(curve.name, 'fwd_poly') = {mat2str(curve.raw_to_proc)};

    if strcmp('default', curve.raw_range)
        raw_calc_range = RAW_CALC_RANGE;
    else
        raw_calc_range = curve.raw_range;
    end


    % Plot (sub)Title generation
    fprintf('Calculating the inverse of %s: \n', curve.name);
    subplot_titles = {
        sprintf('%s : Forward and Inverse RAW v Proc Curves', curve.name);
        sprintf('%s : Errors', curve.name);    
    };
    fig_title = sprintf('Inverse Polynomial Determination for %s', curve.name);
    
    % (sub)plot creation
    [haxes, hfig] = makeManyMDRTSubplots(subplot_titles, fig_title);
    all_figs = vertcat(all_figs, hfig);
    
    proc_vals = calc_poly(curve.raw_to_proc, raw_calc_range);
    plot(haxes(1), raw_calc_range, proc_vals, 'DisplayName','Raw2Proc', Marker='x')

    for order = ORDER_LOW:ORDER_HIGH
        Ci = polyfit(proc_vals, raw_calc_range, order);
        calc_raw_vals = polyval(Ci, proc_vals);
        errors = abs(calc_raw_vals - raw_calc_range);
        
        % Tabulate Results
        inv_poly_col = sprintf('inv_poly_%d', order);
        out_table(curve.name, inv_poly_col) = {fliplr(Ci)};
        
        poly_avg_err_col = sprintf('avg_err_%d', order);
        out_table(curve.name, poly_avg_err_col) = {mean(errors)};
        
        % Visualize Results
        hold on;
        plot(haxes(1), calc_raw_vals, proc_vals, 'DisplayName', sprintf('InverseFunc %d', order))
        plot(haxes(2), raw_calc_range, errors, 'DisplayName', sprintf('Error Order %d', order))
    end
    
    linkaxes(haxes, 'x');
    for sp = 1:numel(haxes)
        haxes(sp).XLim(1) = 0;
        legend(haxes(sp))
        haxes(sp).Legend.Location = 'best';
        title(haxes(sp),  subplot_titles(sp) );
    end
    haxes(1).XTickLabelMode = 'manual';
    haxes(2).XTickLabelMode = 'auto';


end



%% Hold for plot adjustment before writing results to disk

keyboard

path = '~/Documents/MATLAB/plots';

writetable(out_table, fullfile(path,'sim_proc_to_raw.csv'), "WriteRowNames",true)

keyboard

for p = 1:numel(all_figs)
    hfig = all_figs(p);

    sth = findobj(hfig, 'Tag','suptitle');
    graphTitle = sth.Children.String;
    
    defaultName = regexprep(graphTitle,'^[!@$^&*~?.|/[]<>\`";#()]','');
    defaultName = regexprep(defaultName, '[:]','-');
    
    saveas(hfig, fullfile(path, defaultName),'pdf');

end



