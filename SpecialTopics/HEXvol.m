% Units: kg, m

C = [-2.67E-08, 0.0006435, 1.65, 0];    % CCT's poly LO2 tank volume fit
C = [0.02632, -0.06500]; % CCT's HEX Poly

raw2proc = @(raw) polyval(C, raw);
proc2raw = @(proc) (proc - C(2)) ./ C(1);
 


% <PolynomialCoefficient coefficient="0" value="-0.06500"/>
% <PolynomialCoefficient coefficient="1" value="0.026327"/>


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
    


LN2 = struct;
    LN2.sg = 0.808; % Specific Gravity
    LN2.density = struct;
        LN2.density.kgm3 = 867.2;
        LN2.density.lbin3 = LN2.density.kgm3 * convert.kgm3tolbin3;
 
tank = struct;
    tank.radius = 59.5 / 2;         % inches
    tank.length = 162;              % inches

coil_center = 12.13;                % inches below centerline
coil_diam   = 15.6;                 % inches diameter
coil_height = tank.radius - coil_center + (coil_diam / 2);




cylVol = @(h) (tank.radius^2 * acos((tank.radius-h)./tank.radius)-(tank.radius-h).*sqrt(2*tank.radius.*h-h.^2)) * tank.length;
% sphVol = @(h) pi() ./ 3 .* h.^2 .* (1.5 * tank.radius * 2 - h);

tnkVol = @(h) ( cylVol(h) ) .* convert.in3togal; % gallons

headPress = @(inLN2) LN2.density.lbin3  * inLN2; % takes inches, gives psi
psi2in    = @(p) p .* 27.7076;    % Convert psi to inH2O
in2psi    = @(in) in ./ 27.7076;  % Convert inH2O to psi

p2raw = @(h) round(h./10 * 30000); % psi to RAW

raw2fcs = @(r) polyval(C, r);
colFromPress = @(h2o) h2o ./ LN2.sg; % inches water measured pressure to ln2 height

fig1 = makeMDRTPlotFigure;

plot(tnkVol(0:tank.radius*2), 'displayname', 'True Volume');
hold on; 
plot(raw2fcs(p2raw(headPress( 0:tank.radius*2 ))), '-g', 'displayname', 'FCS Volume')
plot([coil_height, coil_height], [0, 2300], '-r', 'displayname', 'HEX Coil Top')
% set(gca,'YTickLabel',sprintf('%3.f\n',get(gca, 'YTick')))
xlabel('Inches of LN2 head');
ylabel(gca, 'LN2 Volume in tank');
title('HEX Volume Curves');
plotStyle;
legend('Location', 'SouthEast');


colHeight = 0:0.1:tank.radius*2;
pressVect = (0:0.1:tank.radius*2) .* LN2.sg;
gallons   = cylVol(colHeight);




% 
% 
% fig2 = makeMDRTPlotFigure;
% h = 0:tank.radius*2;
% p = headPress(h);
% geo = tnkVol(h);
% calc = raw2vol(p2raw(p));
% plot(h./max(h), calc-geo, 'displayname', 'geometric error')
% xlabel('Inches of LOX in tank (as % of full height)')
% ylabel('Error in gallons from perfect pressure measurement to geometry')
% title('Error in pressure derrived tank level vs liquid height as %')
% plotStyle
% legend show