function [ModelNum,MinDischargeArea,ActualDischargeArea] = ...
    ReliefValveSelectorFunc(Commodity,Cv,PressIn,PressSet,Temp,Z, ...
    PressOver,Kc)
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
CommodityRef.SpecificHeatRatio = [1.40,1.66];


% -------------------------------------------------------------------------
% We calculate the required effective discharge area (MinDischargeArea).
% -------------------------------------------------------------------------



% -------------------------------------------------------------------------
% We close the function.
% -------------------------------------------------------------------------
end
% -------------------------------------------------------------------------