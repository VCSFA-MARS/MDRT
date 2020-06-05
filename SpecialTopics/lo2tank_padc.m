%% Physical Constants and Unit Conversions

% Units: kg, m

g = struct; % Gravitational acceleration
    g.ms2 = 9.81;               %  m/s^2
    g.fs2 = 32.1740;            % ft/s^2
    g.in2 = 386.09;             % in/s^2

convert = struct; % factors. Multiply inches by convert.intoft for feet
    convert.in3togal    = 0.004329;
    convert.m3togal     = 264.172;
    convert.m3toin3     = 61023.7;
    convert.m2toin2     = 1550;
    convert.intoft      = 1/12;
    convert.fttoin      = 12;
    convert.galtoL      = 3.78541;
    convert.galtom3     = 0.00454609;
    convert.kgtolbm     = 2.2046226218488;
    convert.kgm3tolbft3 = 0.062428;
    convert.kgm3tolbin3 = 3.6127e-5;
    convert.kPatoin     = 4.01865;
    convert.kPatopsi    = 0.145038;
    convert.Ltogal      = 0.264172;
    convert.Ltom3       = 0.001;
    convert.psftopsi    = 0.00694444;
    convert.psitoin     = 27.7076;
    convert.psitokPa    = 6.89476;
    convert.intopsi     = 0.0360912;
    convert.intokPa     = 0.24884;
    
sensor = struct;
    sensor.lowP = 0;        % psi
    sensor.highP = 10;      % psi
    sensor.lowI = 4;        % mA
    sensor.highI = 20;      % mA
    

LN2 = struct;
    LN2.density=struct;
        LN2.density.kgm3    = 808;           % kg/m^3
    	LN2.density.lbin3 	= LN2.density.kgm3 * convert.kgm3tolbin3;    
    
LOX = struct;
    LOX.density=struct;
        LOX.density.kgm3    = 1141;           % kg/m^3
        LOX.density.lbin3 	= LOX.density.kgm3 * convert.kgm3tolbin3;

%% Tank Geometry Definition and Function Definitions
%
%   The tank structure holds important geometrical parameters for the tank.
%   Inline functions are defined here that reference the tank geometry and
%   allow calculation of useful parameters based on the tank geometry and
%   liquid parameters.

tank = struct;
    tank.radius  = (82.125 - 1)/2;    % inches ( minus 1 inch for material thickness closely aligns with volumes on drawing)
    tank.length  = 210;         % inches
    tank.mfgvol  = 5970;        % gallons
    tank.mfgfull = 5672;        % gallons (operational capacity 95% )
    


    
cylVol = @(h) (tank.radius^2 * acos((tank.radius-h)./tank.radius)-(tank.radius-h).*sqrt(2*tank.radius.*h-h.^2)) * tank.length; % Takes inches, Returns cubic inches
sphVol = @(h) pi() ./ 3 .* h.^2 .* (1.5 * tank.radius * 2 - h); % Takes inches, Returns cubic inches

tnkVol = @(h) real(( cylVol(h) + sphVol(h) ) .* convert.in3togal ); % gallons

headPress = @(h, liquid) liquid.density.lbin3  * h; % takes inches, gives psi
press2h   = @(p, liquid) p./ liquid.density.lbin3;  % takes psi, gives inches of liquid column

p2raw = @(h) round(h./10 * 30000);
ma2p  = @(I) ( I - 4 ) / 16 * (sensor.highP - sensor.lowP); % current to psid

raw2vol = @(h) polyval(C, h);


%% Manufacturer's Data
% These tabulated values were taken directly from the manufacturer's cut
% sheet for the tank. Pressure was given in "H2O and volume was given in US
% Gallons.
%
% These vectors are converted to multiple units and passed into tables that
% can be called with whatever units are required: mfgrHead.inwc for the
% head pressure in water column head.

mfgrPress = [0 1  2  3  4  5  6  7  8  9 10 11 12 13 14 15  ...
             16 17 18 19 20 21 22 23 24 25 26 27 28 29 30  ...
             31 32 33 34 35 36 37 38 39 40 41 42 43 44 45  ...
             46 47 48 49 50 51 52 53 54 55 56 57 58 59 60  ...
             61 62 63 64 65 66 67 68 69 70 71 72 73 74 75  ...
             76 77 78 79 80 81 82 83 84 85 ]; % inches H2O

mfgrVolm = [ 0  35   100   186   289   406   537   680   833   997  1171 ...
              1354  1545  1745  1952  2166  2388  2616  2850  3091  3337 ...
              3589  3846  4107  4374  4645  4920  5199  5482  5768  6058 ...
              6351  6647  6946  7247  7550  7856  8164  8473  8784  9097 ...
              9411  9725 10041 10358 10675 10992 11309 11627 11944 12261 ...
             12578 12893 13208 13522 13834 14145 14455 14762 15068 15371 ...
             15672 15971 16266 16559 16849 17135 17418 17696 17971 18242 ...
             18508 18769 19026 19277 19523 19763 19997 20225 20446 20660 ...
             20867 21066 21256 21439 21612]; % Liters


mfgrHead = table(   mfgrPress, ... 
                    mfgrPress*convert.intopsi, ...
                    mfgrPress*convert.intokPa, ...
                    'VariableNames', {'inwc', 'psi', 'kPa'} );

mfgrVol  = table(   mfgrVolm, ... 
                    mfgrVolm*convert.Ltogal, ...
                    mfgrVolm*convert.Ltom3, ...
                    'VariableNames', {'L', 'gal', 'm3'});

%% Plot Poly Fits for Comparison

% p = [fo.p1, fo.p2, fo.p3]

[p, S] = polyfit(mfgrHead.psi, mfgrVol.gal, 4);



plot(mfgrHead.psi', polyval(p, mfgrHead.psi), 'displayname', '4th order');
hold on;


[p, S] = polyfit(mfgrHead.psi, mfgrVol.gal, 3);
plot(mfgrHead.psi', polyval(p, mfgrHead.psi), '-g', 'displayname', '3rd order');


plot(mfgrHead.psi, mfgrVol.gal, '-r', 'displayname', 'MFGR Data')


plotStyle;
legend('Location', 'SouthEast');



%% 

% LO2FitMfgr = {  'poly fit order',                'psi to gal',                   'kPa to Liter',                         'kPa to %'; ...
%                 '3rd order',     polyfit(mfgrHead.psi', mfgrVol.gal', 3),	polyfit(mfgrHead.kPa', mfgrVol.L', 3),	polyfit(mfgrHead.kPa', mfgrVol.gal'./tank.mfgvol, 3); ...
%                 '4th order',     polyfit(mfgrHead.psi', mfgrVol.gal', 4),	polyfit(mfgrHead.kPa', mfgrVol.L', 4),	polyfit(mfgrHead.kPa', mfgrVol.gal'./tank.mfgvol, 4)  ...
% }

LO2FitMfgr = struct;
    LO2FitMfgr.cubic = struct;
        LO2FitMfgr.cubic.psitogal = polyfit(mfgrHead.psi, mfgrVol.gal,  3);
        LO2FitMfgr.cubic.kPatoL   = polyfit(mfgrHead.kPa, mfgrVol.L,    3);
        LO2FitMfgr.cubic.kPatopct = polyfit(mfgrHead.kPa, mfgrVol.gal./tank.mfgvol*100, 3);
    LO2FitMfgr.quart = struct;
        LO2FitMfgr.quart.psitogal = polyfit(mfgrHead.psi, mfgrVol.gal,  4);
        LO2FitMfgr.quart.kPatoL   = polyfit(mfgrHead.kPa, mfgrVol.L,    4);
        LO2FitMfgr.quart.kPatopct = polyfit(mfgrHead.kPa, mfgrVol.gal./tank.mfgvol*100, 4);

liquidHeight = 0:83; % inches - tank is 82 1/8 inches tall internally
LN2pressVect = headPress(liquidHeight, LN2); % vector of pressures for tank profile in psi
LOXpressVect = headPress(liquidHeight, LOX); % vector of pressures for tank profile in psi


% LO2Fit = struct;
%     LO2Fit.cubic = struct;
%         LO2Fit.cubic.psitogal = polyfit(mfgrHead.psi, tnkVol(press2h(mfgrHead.psi, LOX)), 3);
%         LO2Fit.cubic.kPatoL   = polyfit(mfgrHead.kPa, tnkVol(press2h(mfgrHead.psi, LOX)), 3);
%         LO2Fit.cubic.kPatopct = polyfit(mfgrHead.kPa, tnkVol(press2h(mfgrHead.psi, LOX))/tank.mfgvol*100, 3);
%     LO2Fit.quart = struct;
%         LO2Fit.quart.psitogal = polyfit(mfgrHead.psi, tnkVol(press2h(mfgrHead.psi, LOX)), 4);
%         LO2Fit.quart.kPatoL   = polyfit(mfgrHead.kPa, tnkVol(press2h(mfgrHead.psi, LOX)), 4);
%         LO2Fit.quart.kPatopct = polyfit(mfgrHead.kPa, tnkVol(press2h(mfgrHead.psi, LOX))/tank.mfgvol*100, 4);              

        
LO2Fit = struct;
    LO2Fit.cubic = struct;
        LO2Fit.cubic.psitogal = polyfit(LOXpressVect,                  tnkVol(liquidHeight), 3);
        LO2Fit.cubic.kPatoL   = polyfit(LOXpressVect*convert.psitokPa, tnkVol(liquidHeight).*convert.galtoL, 3);
        LO2Fit.cubic.kPatopct = polyfit(LOXpressVect*convert.psitokPa, tnkVol(liquidHeight)/tank.mfgvol*100, 3);
    LO2Fit.quart = struct;
        LO2Fit.quart.psitogal = polyfit(LOXpressVect,                  tnkVol(liquidHeight), 4);
        LO2Fit.quart.kPatoL   = polyfit(LOXpressVect*convert.psitokPa, tnkVol(liquidHeight).*convert.galtoL, 4);
        LO2Fit.quart.kPatopct = polyfit(LOXpressVect*convert.psitokPa, tnkVol(liquidHeight)/tank.mfgvol*100, 4);        

        
LN2Fit = struct;
    LN2Fit.cubic = struct;
        LN2Fit.cubic.psitogal = polyfit(LN2pressVect,                  tnkVol(liquidHeight), 3);
        LN2Fit.cubic.kPatoL   = polyfit(LN2pressVect*convert.psitokPa, tnkVol(liquidHeight).*convert.galtoL, 3);
        LN2Fit.cubic.kPatopct = polyfit(LN2pressVect*convert.psitokPa, tnkVol(liquidHeight)/tank.mfgvol*100, 3);
    LN2Fit.quart = struct;
        LN2Fit.quart.psitogal = polyfit(LN2pressVect,                  tnkVol(liquidHeight), 4);
        LN2Fit.quart.kPatoL   = polyfit(LN2pressVect*convert.psitokPa, tnkVol(liquidHeight).*convert.galtoL, 4);
        LN2Fit.quart.kPatopct = polyfit(LN2pressVect*convert.psitokPa, tnkVol(liquidHeight)/tank.mfgvol*100, 4);         
        
        


%% Make Percent Figure

% plot( polyval(LO2FitMfgr.cubic.psitopct, mfgrHead.kPa) )

results = [];
% results = mfgrHead.kPa;
results = vertcat(results, polyval(LO2FitMfgr.cubic.kPatopct, mfgrHead.kPa));
results = vertcat(results, polyval(LO2FitMfgr.quart.kPatopct, mfgrHead.kPa));
results = vertcat(results, polyval(    LO2Fit.cubic.kPatopct, mfgrHead.kPa));
results = vertcat(results, polyval(    LO2Fit.quart.kPatopct, mfgrHead.kPa));
results = vertcat(results, mfgrVol.gal/tank.mfgvol*100);

labels = {'Mfgr 3rd order', 'Mfgr 4th order', 'LO2 3rd order', 'LO2 4th order', 'Mfgr Table'};


fig = figure;

orient('landscape');

plot(mfgrHead.psi, results);
legend(labels, 'location', 'southeast')
hax = gca;
title('Poly-fits for LO2: kPa to % full');
ylabel('Percent full');
xlabel('Differential pressure in kPa');
grid('minor');
grid on

saveas(fig, '~/Downloads/percent_LO2.pdf', 'pdf')




%% Make psi Gallons Figure

results = [];
% results = mfgrHead.kPa;
results = vertcat(results, polyval(LO2FitMfgr.cubic.psitogal, mfgrHead.psi));
results = vertcat(results, polyval(LO2FitMfgr.quart.psitogal, mfgrHead.psi));
results = vertcat(results, polyval(    LO2Fit.cubic.psitogal, mfgrHead.psi));
results = vertcat(results, polyval(    LO2Fit.quart.psitogal, mfgrHead.psi));
results = vertcat(results, mfgrVol.gal);

labels = {'Mfgr 3rd order', 'Mfgr 4th order', 'LO2 3rd order', 'LO2 4th order', 'Mfgr Table'};

fig = figure;

orient('landscape');

plot(mfgrHead.kPa, results);

hax = gca;
legend(labels, 'location', 'southeast')
title('Poly-fits for LO2: psi to gallons');
ylabel('gallons');
xlabel('Differential pressure in psi');
grid('minor');
grid on

saveas(fig, '~/Downloads/gallons_LO2.pdf', 'pdf')


%% Make kPa L Figure

results = [];
% results = mfgrHead.kPa;
results = vertcat(results, polyval(LO2FitMfgr.cubic.kPatoL, mfgrHead.kPa));
results = vertcat(results, polyval(LO2FitMfgr.quart.kPatoL, mfgrHead.kPa));
results = vertcat(results, polyval(    LO2Fit.cubic.kPatoL, mfgrHead.kPa));
results = vertcat(results, polyval(    LO2Fit.quart.kPatoL, mfgrHead.kPa));
results = vertcat(results, mfgrVol.L);

labels = {'Mfgr 3rd order', 'Mfgr 4th order', 'LO2 3rd order', 'LO2 4th order', 'Mfgr Table'};


fig = figure;

orient('landscape');

plot(mfgrHead.kPa, results);
legend(labels, 'location', 'southeast')
hax = gca;
title('Poly-fits for LO2: kPa to Liters');
ylabel('Liters');
xlabel('Differential pressure in kPa');
grid('minor');
grid on

saveas(fig, '~/Downloads/Liters_LO2.pdf', 'pdf')




%% Make LN2 kPa L Figure

results = [];

results = vertcat(results, polyval(    LN2Fit.cubic.kPatoL, mfgrHead.kPa));
results = vertcat(results, polyval(    LN2Fit.quart.kPatoL, mfgrHead.kPa));
results = vertcat(results, mfgrVol.L);

labels = {'LN2 3rd order', 'LN2 4th order', 'Mfgr Table for LO2'};


fig = figure;

orient('landscape');

plot(mfgrHead.kPa, results);
legend(labels, 'location', 'southeast')
hax = gca;
title('Poly-fits for LN2: kPa to Liters');
ylabel('Liters');
xlabel('Differential pressure in kPa');
grid('minor');
grid on

saveas(fig, '~/Downloads/Liters_LN2.pdf', 'pdf')



%% Make LN2 kPa to Percent Figure

results = [];

results = vertcat(results, polyval(    LN2Fit.cubic.kPatopct, mfgrHead.kPa));
results = vertcat(results, polyval(    LN2Fit.quart.kPatopct, mfgrHead.kPa));
results = vertcat(results, mfgrVol.gal/tank.mfgvol*100);

labels = {'LN2 3rd order', 'LN2 4th order', 'Mfgr Table for LO2'};


fig = figure;

orient('landscape');

plot(mfgrHead.kPa, results);
legend(labels, 'location', 'southeast')
hax = gca;
title('Poly-fits for LN2: kPa to Percent');
ylabel('Percent Full');
xlabel('Differential pressure in kPa');
grid('minor');
grid on

saveas(fig, '~/Downloads/Percent_LN2.pdf', 'pdf')

