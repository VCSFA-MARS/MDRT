r_from_t = @(t, A, B, C) 100*(1 + A.*t + B.*t.^2 + C.*(t - 100).*t.^3);

r_from_TCR3851 = @(t) r_from_t(t, 3.9083e-3, -5.775e-7, -4.183e-12 * (t<0));
r_from_TCR3916 = @(t) r_from_t(t, 3.9739e-3, -5.870e-7, -4.4e-12   * (t<0));
r_from_FLK392  = @(t) r_from_t(t, 3.9827e-3, -5.875e-7, -4.171e-12 * (t<0));
r_from_FLK385  = @(t) r_from_t(t, 3.9083e-3, -5.775e-7, -4.183e-12 * (t<0));


T = [-210:10:30];
R3851 = zeros(size(T));
R3616 = zeros(size(T));
RF392 = zeros(size(T));
RF385 = zeros(size(T));

  
for i = 1:length(T)
  R3851(i) = r_from_TCR3851(T(i));
  R3616(i) = r_from_TCR3916(T(i));
  RF392(i) = r_from_FLK392(T(i));
  RF385(i) = r_from_FLK385(T(i));
end

  
r_tol_class_b  = @(t) interp1([-200,0], [0.56, 0.3],  t);
t_tol_class_b  = @(t) interp1([-200,0], [1.3,  0.56], t);
t_from_TCR3851 = @(t) interp1(R3851,T,t);
t_from_TCR3916 = @(t) interp1(R3616,T,t);
t_from_FLK392  = @(t) interp1(RF392,T,t);
t_from_FLK385  = @(t) interp1(RF385,T,t);


% hf = figure();
% hax = axes(hf)
% hax.YLabel.String = 'Temperature °C'
% hax.XLabel.String = 'Resistance (Ohms)';
% hold on;
%
% plot(R3851, T, 'DisplayName', 'TCR385');
% plot(R3616, T, 'DisplayName', 'TRC392');
% plot(RF392, T, 'DisplayName', 'FLK392', 'LineStyle', ':', 'Marker', 'o');
% plot(RF385, T, 'DisplayName', 'FLK385', 'LineStyle', '--', 'Marker', 'x');


%% Calibration Data - test points and aggregate results

t_cryo = -195.65;
t_warm =   26.67;

err_warm = [
   0.63;
   0.53;
   0.63;
   0.65;
   0.71;
   0.60;
   0.41;
   0.20;
   0.63;
   0.46;
   0.43;
   0.68;
   0.33;
   0.61;
  -0.34;
   0.27;
  -0.06;
   0.10;
  ];

err_cryo = [
  -1.82;
  -2.22;
  -2.12;
  -2.00;
  -2.52;
  -2.42;
  -1.62;
  -2.72;
  -2.12;
  -2.32;
  -2.32;
  -2.29;
  -2.12;
  -0.36;
  -2.08;
  -1.93;
  -1.65;
  -1.63;
  ];



%% Compute The Resistance reported by NI9216 given the temp reading and TCR385

% These are the temperatures and corresponding resistance values using the 
% TCR385 coefficients (NI9216 Documentation)
TC385 = t_cryo + err_cryo;
RC385 = r_from_TCR3851(TC385);

TW385 = t_warm + err_warm;
RW385 = r_from_TCR3851(TW385);

Vcryo = 0.001 * RC385;
Vcryo_ideal = 0.001 * r_from_TCR3851(t_cryo);
Vcryo_err = Vcryo - Vcryo_ideal;

Vwarm = 0.001 * RW385;
Vwarm_ideal = 0.001 * r_from_TCR3851(t_warm);
Vwarm_err = Vwarm - Vwarm_ideal;


boxchart(Vcryo);
hold on;
yline(Vcryo_ideal);



