% Script for writing relief valve selector function.
% ----------------------------------------------------------------------


% ----------------------------------------------------------------------
% We etsblish the workspace and command window.
% ----------------------------------------------------------------------
clear;clc;
close all force
% ----------------------------------------------------------------------


% ----------------------------------------------------------------------
% We define dummy input values.
% ----------------------------------------------------------------------
Commodity = 'GN2';
Cv = .26;
MAWP = 1000;
T = 0;
SetPressure = 1800;
Z = 1;
PercentOver = 10;
Kc = 1;
% ----------------------------------------------------------------------


% ----------------------------------------------------------------------
% We define reference tables and master logic table.
% ----------------------------------------------------------------------
ReferencePath = fullfile('Relief Valve Selector', ...
    'ReliefValveSelectorReference.xlsx');

CommodityRef = readtable(ReferencePath,'Sheet','CommodityRef', ...
    'PreserveVariableNames',true);
ModelTypeRef = readtable(ReferencePath,'Sheet','ModelTypeRef', ...
    'PreserveVariableNames',true);
TempMaterialRef = readtable(ReferencePath,'Sheet','TempMaterialRef', ...
    'PreserveVariableNames',true);

OptsMaster = detectImportOptions(ReferencePath,'Sheet','Master');
OptsMaster = setvartype(OptsMaster,'ValveType','string');
OptsMaster.VariableNamingRule = 'preserve';
Master = readtable(ReferencePath,OptsMaster,'Sheet','Master');

OptsThermoRef = detectImportOptions(ReferencePath,'Sheet','ThermoRef');
OptsThermoRef = setvartype(OptsThermoRef,'ValveType','string');
OptsThermoRef.VariableNamingRule = 'preserve';
ThermoRef = readtable(ReferencePath,OptsThermoRef,'Sheet','ThermoRef');
% ----------------------------------------------------------------------


% ----------------------------------------------------------------------
% We pull physical constants based on the selected commodity.
% ----------------------------------------------------------------------
state = CommodityRef{strcmp(Commodity,CommodityRef.Commodity), ...
    'State'};
Sg = CommodityRef{strcmp(Commodity,CommodityRef.Commodity), ...
    'SpecificGravity'};
M = CommodityRef{strcmp(Commodity,CommodityRef.Commodity), ...
    'MolecularWeight'};
C = CommodityRef{strcmp(Commodity,CommodityRef.Commodity), ...
    'GasConstant'};
% ----------------------------------------------------------------------


% ----------------------------------------------------------------------
% We calculate maximum possible flow rate, V.
% ----------------------------------------------------------------------
if strcmp(state,'gas')
    V = Cv*MAWP/(2*sqrt(Sg));
elseif strcmp(state,'liquid')
    V = Cv*sqrt(MAWP)/sqrt(Sg);
end
% ----------------------------------------------------------------------


% ----------------------------------------------------------------------
% We filter against orifice size. Rquired discharge area is a function 
% of nozzle coefficient, K, which is a property of the relief valve and 
% varies with model number. The calculation is repeated for each model 
% number; sub-types of each model number are eliminated if their orifice
% size is smaller than the required discharge area. If a model/sub-type 
% combination is eliminated, its value in ModelTypeRef is changed to 
% zero.
% ----------------------------------------------------------------------
if strcmp(state,'gas')
    for i = 2:height(ModelTypeRef)
        Areq = V*sqrt(M*(T+459.67)*Z)/(6.32*C*ModelTypeRef.K(i)*((1+ ...
            PercentOver/100)*SetPressure+14.7));
        ModelTypeRef{i,2+find(ModelTypeRef{1,3:end} < Areq)} = 0;
    end
elseif strcmp(state,'liquid')
    % liquid support added later
end
% ----------------------------------------------------------------------


% ----------------------------------------------------------------------
% We filter against operating temperature of the relief valve material
% (Brass, CD, or SS). If any material is precluded, all columns in
% ThermoRef associated with that material are deleted.
% ----------------------------------------------------------------------
for i = 1:height(TempMaterialRef)
    if T < TempMaterialRef{i,'T Min'} || T > TempMaterialRef{i,'T Max'}
        ThermoRef = removevars(ThermoRef,find(contains(ThermoRef. ...
            Properties.VariableNames,TempMaterialRef{1,'Material'})));
    end
end
% ----------------------------------------------------------------------


% ----------------------------------------------------------------------
% We filter against operating temperature of the relief valve seat
% material. If any material is precluded, all rows in ThermoRef 
% associated with that material are deleted.
% ----------------------------------------------------------------------
ThermoRef(T < ThermoRef{:,'T Min'} | T > ThermoRef{:,'T Max'},:) = [];
% ----------------------------------------------------------------------


% ----------------------------------------------------------------------
% We filter against set pressure range. Satisfactory model/seal/sub-type
% combinations are assigned a true value in their 'P Min' / 'P Max' 
% columns in ThermoRef; unsatisfactory combinations are assigned false 
% values in the same columns. ThermoRef is then trimmed by removing all 
% 'P Min' columns and any empty (all false) columns.
% ----------------------------------------------------------------------
MinColumns = find(contains(ThermoRef.Properties.VariableNames,'P Min'));

for i = 1:height(ThermoRef)
    SetCheck = SetPressure > ThermoRef{i,MinColumns} & SetPressure < ...
        ThermoRef{i,MinColumns+1};
    SetCheck = reshape(repmat(SetCheck,2,1),1,[]);
    ThermoRef{i,4+find(SetCheck)} = 1;
    ThermoRef{i,4+find(~SetCheck)} = 0;
end

ThermoRef = removevars(ThermoRef,find(contains(ThermoRef.Properties. ...
    VariableNames,'P Min')));
ThermoRef = removevars(ThermoRef,4+find(~any(ThermoRef{:,5:end})));
% ----------------------------------------------------------------------


% ----------------------------------------------------------------------
% For all acceptable combinations of relief valve type, seat material,
% material, and sub-type, the associated cell in Master is changed from
% false to true.
% ----------------------------------------------------------------------
for i = 1:height(ThermoRef)
    ValveType = ThermoRef.ValveType(i);
    SeatMaterial = convertCharsToStrings(ThermoRef.SeatMaterial{i});
    Headers = strrep(ThermoRef.Properties.VariableNames(4+find( ...
        ThermoRef{i,5:end})),' P Max','');
    Master{intersect(find(Master.ValveType == ValveType), ...
        find(Master.SeatMaterial == SeatMaterial)),Headers} = 1;
end
% ----------------------------------------------------------------------