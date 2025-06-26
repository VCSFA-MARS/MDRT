function [ModelNum,MinDischargeArea,ActualDischargeArea] = ...
    ReliefValveSelectorFunc(Commodity,Cv,PressIn,PressSet,Temp,Z, ...
    PressOver,Kc)
% -------------------------------------------------------------------------


% -------------------------------------------------------------------------
% This script provides a generic selector application to determine a
% candidate relief valve model and associated orifice size, given
% parameters pertaining to the location of the relief valve within a system
% and the relief valve's functionality. The application also returns the
% force exerted on supporting structure(s) by the relief valve when flowing
% at full capacity.
%
% The script is to be run without alteration to the code. All user inputs
% and result outputs will be contained within a separate UI window.
%
% Inputs...
%   -> Commodity: Commodity
%   -> Cv: Cv of Upstream Regulator [dimensionless]
%   -> PressIn: MAWP of Upstream Regulator [psig]
%   -> PressSet: Relief Valve Set Pressure [psig]
%   -> Temp: Operating Temperature [°F/°C]
%   -> Z: Commpresibility Factor, Z [dimensionless] (nominally 1)
%   -> PressOver: Percent Overpressure [%] (nominally 10%)
%   -> Kc: Combination Correction Factor, Kc [dimensionless] (nominally 1)
%
% Outputs...
%   -> Recommended Anderson Greenwood Relief Valve Model Number
%   -> Minimum Discharge Area [in^2]
%   -> Discharge Area of Recommended Relief Valve [in^2]
%
% Constants...
%   -> PressBack: Back Pressure [psig] (constrained as 0)
%
% -------------------------------------------------------------------------
% REVISION LOG ------------------------------------------------------------
% -------------------------------------------------------------------------
% Rev0: placeholder
%   placeholder
% -------------------------------------------------------------------------


% -------------------------------------------------------------------------
% We define constants.
% -------------------------------------------------------------------------
PressBack = 0;
% -------------------------------------------------------------------------


% -------------------------------------------------------------------------
% We create a lookup table with constant values for possible commodities.
% -------------------------------------------------------------------------
CommodityRef = table('VariableNames',['Commodity','State', ...
    'SpecificGravity','MolWeight','SpecificHeatRatio'],'VariableTypes', ...
    ['char','char','double','double','double']);
CommodityRef.Commodity = ['GN2','GHe'];
CommodityRef.
CommodityRef.SpecificGravity = [0.967,0.138];
CommodityRef.MolWeight = [28.0134,4.002602];
CommodityRef.SpecificHeatRatio = [1.40,1.66]


% -------------------------------------------------------------------------
% We calculate the required effective discharge area (MinDischargeArea).
% -------------------------------------------------------------------------



% -------------------------------------------------------------------------
% We close the function.
% -------------------------------------------------------------------------
end
% -------------------------------------------------------------------------