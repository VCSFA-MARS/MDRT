classdef NIParser
    %NIParser is the National Instruments .csv file parser module for MDRT
    %   
    
    properties
    end
    
    properties (Constant)
        NIEpoch = struct( ...
            'String',   '01/01/1904 00:00:00.00', ...               % Human readable Epoch for National Instruments timestamps
            'Datenum',  datenum('01/01/1904 00:00:00.00'), ...      % Matlab datenum for the National Instruments timestamp epoch
            'NIInt2MLInt', 1/24/60/60, ...                          % 1 integer from NI = 1 second.
            'Delta', datenum('01/01/1904 00:00:00.00') ...          % Add to a NI timestamp to find MATLAB datenum
        );
    end
    
    methods (Static)
        
        function timeVect = makeMDRTTimeVector(NITime)
            % makeMDRTTimeVector returns a Matlab datenum timestamp vector
            % accepts a numeric vector (doubles) of National Instruments
            % timestamp values and returns a vector of matlab datenums.
            %
            % Returns an empty value [] if passed bad data
            
            timeVect = [];
            
            if isnumeric(NITime)
                epoch = NIParser.NIEpoch;
                timeVect = NITime .* epoch.NIInt2MLInt + epoch.Delta;
            else
                badType = class(NITime);
                warning(['makeMDRTTimeVector() expected a numeric argument. User passed a ' badType]);
            end
        end
        
        
        
    end
    
end

