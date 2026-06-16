function [ axesLabelString ] = axesLabelStringFromSensorType( typeArray, varargin )
%axesLabelStringFromSensorType ( typeArray )
%   [ axesLabelString ] = axesLabelStringFromSensorType( typeArray )
%
%
%

if nargin == 2
    unitArray = varargin{1};
else
    unitArray = [];
end

%Play nice with the users
typeArray = upper(typeArray);

ptFlag = false;
tcFlag = false;
fmFlag = false;
lsFlag = false;
vsFlag = false;
vpFlag = false;

unknownFlag = false;

firstLabel = true;

labels = [];
units = [];
axesLabelString = '';
axesUnitString = '';

for i = 1:length(typeArray)
    if ~isempty(unitArray)
        switch lower(unitArray{i})
            case {'pa', 'paa', 'kpa', 'kpaa', 'mpa', 'mpaa', 'psi', 'psid', 'psia'}
                ptFlag = true;
                if ~contains(axesUnitString, unitArray{i})
                    axesUnitString = [axesUnitString ', ' unitArray{i}];
                end
                
        end
    else
        switch typeArray{i}
            case 'PT'
                ptFlag = true;
            case 'TC'
                tcFlag = true;
            case 'FM'
                fmFlag = true;
            case 'LS'
                lsFlag = true;
            case {'DCVNC' 'DCVNO'}
                vsFlag = true;
            case {'PCVNC' 'PCVNO'}
                vpFlag = true;
            otherwise
                unknownFlag = true;
        end
    end
    
end

    if (ptFlag);	labels = [labels {'Pressure'}];        end
    if (tcFlag);	labels = [labels {'Temperature'}];     end
    if (fmFlag);	labels = [labels {'Flow Rate'}];       end
    if (lsFlag);	labels = [labels {'Level'}];           end
    if (vsFlag);	labels = [labels {'Valve State'}];     end
    if (vpFlag);	labels = [labels {'Valve Position'}];     end
    
for i = 1:length(labels)
    if ((i - 1) && (i ~= length(labels)) && (length(labels) ~= 2))
        
        axesLabelString = [axesLabelString, ', '];
    
    elseif ((i - 1) && (i == length(labels)))
        
        axesLabelString = [axesLabelString, ' and '];
   
    end
 
    axesLabelString = [axesLabelString, labels{i}];

end

if ~isempty(axesUnitString)
    if strcmpi(axesUnitString(1), ',')
        axesUnitString(1) = [];
    end

    axesUnitString = strtrim(axesUnitString);
    axesLabelString = sprintf('%s (%s)', axesLabelString, axesUnitString);
end

    
end

