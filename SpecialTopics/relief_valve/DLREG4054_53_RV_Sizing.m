%% Cv calcs

% Case #1 - DLREG-4054,REG-4053 full open
Cv=12.0143; %12.0143 (all 3 parallel legs open)
P1=5000; %psig
SG=0.138; %Helium
V=P1*Cv/(2*sqrt(SG)) %SCFM

M=4; %Molecular weight of commodity
T=540; %Relieving Temp of inlet gas (deg R)
Z=1; %Compressibility Factor (1=conservative)
C=377.9; %Coefficient relative to ratio of specific heats for commodity
Kd=0.878; %Effective coefficient of discharge
Kc=1; %combination correction factor 
Kb=1; %Capacity correction factor due to backpressure
RV_stamp=3420;
P1_1=1.1*RV_stamp+14.7; %RV Set Pressure + %rise allowed + atmospheric
A=(V*sqrt(M*T*Z))/(6.32*C*Kd*Kc*Kb*P1_1)

% RV-4186 orifice diameter = 0.357''