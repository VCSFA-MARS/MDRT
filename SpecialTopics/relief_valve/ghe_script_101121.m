%%
% Walter Taraila
% Pad 0A - GHe system analysis

%% Notes:
% Reference ASME Section VIII Div 1
%
%% Helpful Definitions:
%% Set Pressure: 
% the supply pressure at which the dome pressure is 70% of
% the supply pressure. This corresponds to the initial audible discharge of
% gas or first steady stream of liquid from the main valves. 
% 1481 to 6170 inclusive (psig)
% Tolerance (as % of set) = +/- 3%
%% crack pressure:
% the supply pressure at which gas flow begins at the pilot exhaust.
% (as % of set) Min 96 %
%% simmer: 
% the audible or visible escape of fluid between the seat and disk
% at an inlet static pressure below the popping pressure and at no
% measurable capacity. It applies to safety or safety relief valves on
% compressible fluid service. 
%% reseat pressure:
% the supply pressure at which the dome pressure increases to 75% of supply
% pressure. The dome pressure will continue to increase until the supply
% pressure decreases to 95% of set.
% 96 to 100
%% Valve Operation:
% - System pressure is applied at the inlet to the seat area and exerts a
% force on the spindle. This upward force is counteracted by the downward
% force of the spring. While the system pressure is below set pressure, the
% pressure in the spring chamber, the inner chamber and the outlet is
% atmospheric (or uniformly exposed to the current superimposed back
% pressure (if any).
% - A secondary orifice, consisting of two or more holes in the guide,
% permits gas discharge to the spring chamber when the valve opens. This
% orifice also functions to develop a back pressure in the spring chamber
% after valve actuation. If the system pressure increases to the point
% where the total upward force overcomes the spring force, the valve opens.
% 
%% Analysis:
% - Focus on: 1. Opening Pressure
%             2. Reseat Pressure
%             3. Flow Rate associated with an MAWP of 3420 in the system
%             4. Corresponding discharge area to not go above 3420
% - Graph the following:
%             1. ASME Code specs for closing pressure (-2 to -8% stamped)
%             2. Opening Pressure (-3 to +3% stamped)
%             3. VR shop capabilities for closing pressure(-4 to -5% stamp)
%             4. VR shop capabilities for opening pressure (+2% stamped)
%             5. Vehicle MAWP
%             6. RV Stamp value
%             7. Optimal System MEOP (10% under stamped)
%% Code
mawp=3270;

zero=0;
system_meop=.9*mawp;        %
fcs_yellow_low=2950;        %
rv_closing_pressure_low=.92*mawp;    % -8% stamped
fcs_green_low=3050;         %
vr_shop_closing = .955*mawp; % -4.5% stamped
rv_closing_pressure_high=0.98*mawp;  % -2% stamped
target_lo=3150;             %
target=3175;                %
target_high=3200;           %
%crack_rv=.98*mawp;          %
fcs_green_high=3225;        %
fcs_yellow_high=3257;       %
rv_stamp=mawp;          %
rv_opening_low=mawp-mawp*.03; % -3% stamp
vr_opening = mawp+mawp*.025;
rv_opening_high=mawp+mawp*.03;% +3% stamp
vehicle_mawp=3420;
SP=3175; % Target

fig=figure; hax=axes; x=0:0.1:4000; hold on; grid on;
xlabel('Pressure (psig)'); set(gca,'YTickLabel',[]);
axis([2900 3450 0 .7]); % axis([XMIN XMAX YMIN YMAX])
set(gcf, 'Position',  [1000, 1000, 1400, 400])

%% FCS BOXES
% red box, lower
fcs_red_box1_x=[zero,zero,fcs_yellow_low, fcs_yellow_low,zero]; 
fcs_box_y=[0,1,1,0,0];
% yellow box, lower
fcs_yellow_box1_x=[fcs_yellow_low,fcs_yellow_low,fcs_green_low,fcs_green_low,fcs_yellow_low]; 
% green box
fcs_green_box_x=[fcs_green_low,fcs_green_low,fcs_green_high,fcs_green_high,fcs_green_low]; 
% yellow box, upper
fcs_yellow_box2_x=[fcs_green_high,fcs_green_high,fcs_yellow_high,fcs_yellow_high,fcs_green_high]; 
% red box, upper
fcs_red_box2_x=[fcs_yellow_high,fcs_yellow_high,3500,3500,fcs_yellow_high]; 
%Plot red box
plot([zero zero],[0 1]); plot([fcs_yellow_low fcs_yellow_low],[0 1])
% Plot Yellow box low
plot([fcs_yellow_low fcs_yellow_low],[0 1]); plot([fcs_green_low fcs_green_low],[0 1])
% Plot green box
plot([fcs_green_low fcs_green_low],[0 1]); plot([fcs_green_high fcs_green_high],[0 1])
%text(fcs_green_low,0.5,'CNC-band','Rotation',90); text(fcs_green_high,0.5,'CNC-band','Rotation',90)
% Plot Yellow box high
plot([fcs_green_high fcs_green_high],[0 1]); plot([fcs_yellow_high fcs_yellow_high],[0 1])
% Plot red box high
plot([fcs_yellow_high fcs_yellow_high],[0 1]); plot([3500 3500],[0 1])
patch(fcs_red_box1_x,fcs_box_y,'black','FaceColor','red','FaceAlpha',0.1);
patch(fcs_yellow_box1_x,fcs_box_y,'black','FaceColor','yellow','FaceAlpha',0.1);
patch(fcs_green_box_x,fcs_box_y,'black','FaceColor','green','FaceAlpha',0.1);
patch(fcs_yellow_box2_x,fcs_box_y,'black','FaceColor','yellow','FaceAlpha',0.1);
patch(fcs_red_box2_x,fcs_box_y,'black','FaceColor','red','FaceAlpha',0.1);

%% Plot RV Info
plot([system_meop system_meop],[0 .59], 'Color', [0 0 0],'LineWidth',2)
plot([rv_closing_pressure_low rv_closing_pressure_low],[0 .19],'Color', [0 0.4470 0.7410],'LineWidth',2)
plot([vr_shop_closing vr_shop_closing],[0 .49],'Color', [0.8500 0.3250 0.0980],'LineWidth',2)
plot([rv_closing_pressure_high rv_closing_pressure_high],[0 .19],'Color', [0 0.4470 0.7410],'LineWidth',2)
%plot([crack_rv crack_rv],[0 .59],'Color', [0 0.4470 0.7410],'LineWidth',2)
plot([target_lo target_lo],[0 1], '-.','Color', 'k','LineWidth',1)
plot([target target],[0 1], '-.', 'Color', 'k','Marker','p','LineWidth',1)
plot([target_high target_high],[0 1],'-.', 'Color', 'k','LineWidth',1)
plot([rv_stamp rv_stamp],[0 .59],'Color', [0 0 0],'LineWidth',2)
plot([rv_opening_low rv_opening_low],[0 .19],'Color', [0 0.4470 0.7410],'LineWidth',2)
plot([vr_opening vr_opening],[0 .49],'Color', [0.8500 0.3250 0.0980],'LineWidth',2)
plot([rv_opening_high rv_opening_high],[0 .19],'Color', [0 0.4470 0.7410],'LineWidth',2)
plot([vehicle_mawp vehicle_mawp],[0 .59],'Color', [0 0 0],'LineWidth',2)

text(system_meop,0.63,{'Optimal System MEOP';'-10% MAWP'...
    ;num2str(system_meop)},...
    'Rotation',0,'FontSize', 12, 'HorizontalAlignment', 'center')
text(rv_closing_pressure_low,0.25,{'RV Closing Pressure (Low)';'-8% Stamp (ASME)'...
    ;num2str(rv_closing_pressure_low)},...
    'Rotation',0,'FontSize', 12, 'HorizontalAlignment', 'center')
text(vr_shop_closing,0.53,{'VR Shop Closing (tuned)';'-4.5% Stamp'...
    ;num2str(vr_shop_closing)},...
    'Rotation',0,'FontSize', 12, 'HorizontalAlignment', 'center')
text(rv_closing_pressure_high,0.25,{'RV Closing Pressure (High)';'-2% Stamp (ASME)';...
    ;num2str(rv_closing_pressure_high)},...
    'Rotation',0,'FontSize', 12, 'HorizontalAlignment', 'left')
%text(crack_rv,0.63,{'RV Crack';num2str(crack_rv)},...
%    'Rotation',0,'FontSize', 14, 'HorizontalAlignment', 'center')
%text(target_lo,0.5,'Target low','Rotation',90)
%text(target,0.5,'Target','Rotation',90)
%text(target_high,0.5,'Target high','Rotation',90)
text(rv_stamp,0.63,{'RV Stamp';num2str(rv_stamp)},...
    'Rotation',0,'FontSize', 12, 'HorizontalAlignment', 'center')
text(rv_opening_low,0.25,{'RV Opening Pressure (Low)';'-3% Stamp (ASME)'...
    ;num2str(rv_opening_low)},...
    'Rotation',0,'FontSize', 12, 'HorizontalAlignment', 'right')
text(vr_opening,0.53,{'VR Shop Opening (tuned)';'+2.5% Stamp'...
    ;num2str(vr_opening)},...
    'Rotation',0,'FontSize', 12, 'HorizontalAlignment', 'center')
text(rv_opening_high,0.25,{'RV Opening Pressure (High)';'+3% Stamp (ASME)'...
    ;num2str(rv_opening_high)},...
    'Rotation',0,'FontSize', 12, 'HorizontalAlignment', 'left')
text(vehicle_mawp,0.63,{'Vehicle MAWP';num2str(vehicle_mawp)},...
    'Rotation',0,'FontSize', 12, 'HorizontalAlignment', 'center')

%% Cv calcs

% Case #1 - DLREG-4054,REG-4053 full open





