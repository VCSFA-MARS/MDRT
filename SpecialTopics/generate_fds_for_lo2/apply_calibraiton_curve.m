function proc_vals = apply_calibraiton_curve(type, curve_args, raw_values)
%apply_calibraiton_curve translates RAW values from temorary IO to
%processed values.
%   type: (str) matching one of the valid calibration curve classes in the
%               MCS codebase (as seen in the "data_config" : "fds" : "fd_name" :
%               "cal_curve" from the MCS display JSON file
%   arguments: in order of definition in MCS

proc_vals = [];

switch type
    case 'PressureTransducer'
        proc_vals = PressureTransducer(curve_args, raw_values);
    
    case 'TemperatureSensor'
        proc_vals = TemperatureSensor(curve_args, raw_values);

    case 'LiquidColumnHeight'
        proc_vals = LiquidColumnHeight(curve_args, raw_values);

    case 'HemisphericalTank'
        proc_vals = HemisphericalTank(curve_args, raw_values);

    case 'TorrosphericalTank'
        proc_vals = TorrosphericalTank(curve_args, raw_values);

    otherwise
        return

end

end



function values = PressureTransducer(args, raw)
    % Expects 'sensor_range' argument
    values = double(raw) .* args.sensor_range ./ 30000;

end


function values = TemperatureSensor(args, raw)
    % Expects 'manufacturer' argument
    consts = struct(...
        'connax',   [0.017764,           -320.7], ...
        'sci-inst', [0.0234866666666667, -320.8], ...
        'rdf',      [0.0251333333333333, -345.85] ...
        );

    slope = consts.(args.manufacturer)(1);
    offset = consts.(args.manufacturer)(2);

    values = raw .* slope + offset;
end


function values = LiquidColumnHeight(args, raw)
    % Expects 'commodity', 'pressure_units'

    PRESS_UNITS = struct ( ...
        'psi',      27.679904, ...
        'psig',     27.679904, ...
        'psid',     27.679904, ...
        'inwc',     1, ...
        'inches',   1  ...
    );
    
    SPECIFIC_GRAVITY = struct(...
        'LO2',      1.14, ...
        'LN2',      0.808, ...
        'RP1',      0.820, ...
        'H2O',      1.000  ...
    );

    sg = SPECIFIC_GRAVITY.(args.commodity);
    pressure_mult = PRESS_UNITS.(args.pressure_units);

    values = raw .* (pressure_mult / sg);

end


function values = SphericalCaps(args, liquid_height)
    % Expects 'radius' (in inches)
    radius = double(args.radius);
    
    in3_per_gal = 231.0;

    zero_inds = liquid_height <= 0;
    full_inds = liquid_height > radius;

    liquid_height(zero_inds) = 0;
    liquid_height(full_inds) = radius * 2.0;

    vol_in3 = (pi() .* liquid_height.^2 * radius) - (pi() * liquid_height.^3 ./ 3.0);
    
    values = vol_in3 ./ in3_per_gal ; % Convert to gallons

end


function values = HorizontalCylinderTank(args, liquid_height)
    % Expects 'length' and 'radius' (both in inches)
    radius = double(args.radius);
    length = double(args.length);
    
    in3_per_gal = 231.0;

    zero_inds = liquid_height <= 0;
    full_inds = liquid_height > radius;

    liquid_height(zero_inds) = 0;
    liquid_height(full_inds) = radius * 2.0;

    R = radius;
    D = radius * 2;
    H = liquid_height;

    area = R^2 .* acos((R - H) ./ R) - (R - H) .* sqrt(D .*H - H.^2);
    values = area .* length ./ in3_per_gal;
    
end


function values = HemisphericalTank(args, liquid_height)
    % Expects 'tank_radius', 'cyl_length', 'return_mode'

    cyl_length = args.cyl_length;
    tank_radius = args.tank_radius;

    args_hcyl = struct( ...
        'radius',       tank_radius, ...
        'length',       cyl_length );

    args_caps = struct('radius', tank_radius);

    cyl_vol = HorizontalCylinderTank( args_hcyl, liquid_height);
    caps_vol = SphericalCaps(args_caps, liquid_height);

    combined_volume = cyl_vol + caps_vol;

    if ~ contains(fields(args), 'return_mode')
        args.return_mode = 'volume';
    end

    switch args.return_mode
        case 'volume'
            values = combined_volume;
            return
        case 'percent'
            full_caps = SphericalCaps(args_caps, tank_radius * 2);
            full_cyl  = HorizontalCylinderTank(args_hcyl, tank_radius * 2);
            full_tank_vol = full_caps + full_cyl;
            values = combined_volume ./ full_tank_vol .* 100.0;
            return
        otherwise
            error('Invalid return type "%s" for HemisphericalTank', args.return_mode)
    end

    
end

function values = TorrosphericalTank(args, liquid_height)
    % Expects 'tank_radius', 'cyl_length', 'return_mode'

    in3_per_gal = 231.0;

    L = args.cyl_length;
    R = args.tank_radius;
    D = R * 2;
    H = liquid_height;

    vol_in = L * (R^2*cos((R - H)./R) - (R - H) .* sqrt(D * H - H.^2));
    
    if ~ contains(fields(args), 'return_mode')
        args.return_mode = 'volume';
    end
    
    switch args.return_mode
        case 'volume'
            values = vol_in ./ in3_per_gal;
            return
        case 'percent'
            full_vol_in =  L * (R^2*cos((R - D)./R) - (R - D) .* sqrt(D * D - D.^2));
            values = vol_in ./ full_vol_in .* 100.0;
            return
        otherwise
            error('Invalid return type "%s" for TorrosphericalTank', args.return_mode)
    end


end
