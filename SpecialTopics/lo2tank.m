% Units: kg, m

C = [-2.67E-08, 0.0006435, 1.65, 0];    % CCT's poly LO2 tank volume fit

g = struct;
    g.ms2 = 9.81;               %  m/s^2
    g.fs2 = 32.1740;            % ft/s^2
    g.in2 = 386.09;             % in/s^2

convert = struct;
    convert.in3togal    = 0.004329;
    convert.m3togal     = 264.172;
    convert.m3toin3     = 61023.7;
    convert.m2toin2     = 1550;
    convert.intoft      = 1/12;
    convert.fttoin      = 12;
    convert.kgtolbm     = 2.2046226218488;
    convert.kgm3tolbft3 = 0.062428;
    convert.kgm3tolbin3 = 3.6127e-5;
    convert.psftopsi    = 0.00694444;
    

LOX = struct;
    LOX.density=struct;
        LOX.density.kgm3    = 1141;           % kg/m^3
    	LOX.density.lbin3 	= LOX.density.kgm3 * convert.kgm3tolbin3;
 
tank = struct;
    tank.radius = 65.5;         % inches
    tank.length = 1344;    % inches
    
    
hPipe = 30 - 11.145;            % inches - height from outer shell to top of insulation. Minus space between shells
hPipe = 18.5;                   % inches - from bottom of tank to center line of bottom-fill line
dPipe = 2;                      % 2" line


cylVol = @(h) (tank.radius^2 * acos((tank.radius-h)./tank.radius)-(tank.radius-h).*sqrt(2*tank.radius.*h-h.^2)) * tank.length;
sphVol = @(h) pi() ./ 3 .* h.^2 .* (1.5 * tank.radius * 2 - h);

tnkVol = @(h) ( cylVol(h) + sphVol(h) ) .* convert.in3togal; % gallons

headPress = @(h) LOX.density.lbin3  * h; % takes inches, gives psi

p2raw = @(h) round(h./10 * 30000);

raw2vol = @(h) polyval(C, h);


figure = makeMDRTPlotFigure;

plot(tnkVol(0:tank.radius*2), 'displayname', 'True Volume');
hold on; plot(raw2vol(p2raw(headPress( 0:tank.radius*2 ))), '-g', 'displayname', 'FCS Volume')
plot([hPipe, hPipe], [0, 82400], '-r', 'displayname', 'Outlet height')
set(gca,'YTickLabel',sprintf('%3.f\n',get(gca, 'YTick')))
xlabel('Inches of LOX head');
ylabel(gca, 'LOX Volume in tank');
title('MARS 32 Volume Curves');
plotStyle;
legend('Location', 'SouthEast');