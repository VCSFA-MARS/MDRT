classdef NIParser
    %NIParser is the National Instruments .csv file parser module for MDRT
    %   
    
    properties
        Table           % The parsed NI-PAD-0C IO Table (Matlab table class)
        
    end
    
    properties (Constant)
        NIEpoch = struct( ...
            'String',   '01/01/1904 00:00:00.00', ...               % Human readable Epoch for National Instruments timestamps
            'Datenum',  datenum('01/01/1904 00:00:00.00'), ...      % Matlab datenum for the National Instruments timestamp epoch
            'NIInt2MLInt', 1/24/60/60, ...                          % 1 integer from NI = 1 second.
            'Delta', datenum('01/01/1904 00:00:00.00') ...          % Add to a NI timestamp to find MATLAB datenum
        );
    end
    
    
    methods
       
        function self = NIParser()
            % Constructor method
            % NIParser('PADC_IO.xlsx', 'PADC_Data.csv')
            % 
            % 
            
            
            
            
            
            
        end
        
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
        
        function dataTable = csvFileToTable(fileNameWithPath)
            % reads a ,csv file and returns a Matlab Table
            %
            % Returns empty value [] if file not found or unable to parse.
            
            
            dataTable = [];
            
            if ~exist(fileNameWithPath, 'file')
                % return empty value if file doesn't exist
                warning(['file does not exist: ' fileNameWithPath]);
                return
            end
            
            try
                dataTable = readtable(fileNameWithPath);
            catch
                warning(['unable to parse ' fileNameWithPath]);
                dataTable = [];
                return
            end
        end
        
        function P0ADecoder = IOspreadsheet2table(fileNameWithPath)
            % Parses the RL/P0A IO spreadsheet to generate FD descriptions
            %
            % Example:
            %
            % r = NIParser.IOspreadsheet2table('IOSpreadsheet.xlsx');
            % 
            % To search for a value:
            %
            % r.Description(strcmp(r.IOCode,'KF-KI-DVL-B-288'))
            %
            % ans = 
            % 
            %     'Pump Transfer valve'
            
            P0ADecoder = [];

            if isempty(fileNameWithPath)
                % Will point to production IO Spreadsheet in future
                % versions
                return
            end
            
            if ~exist(fileNameWithPath, 'file')
                warning(['file does not exist: ' fileNameWithPath]);
                return
            end
            
            P0ADecoder = readtable(fileNameWithPath);
            
            % Set variable names.
            % NOTE: These headers are awful - we need to get some standard
            % column names. We should see if there's a file that can be
            % directly exported by RL. Or use whatever file they import to
            % their configuration utility.

            P0ADecoder.Properties.VariableNames = P0ADecoder.Properties.VariableNames;
            
            P0ADecoder.Description(strcmp(P0ADecoder.IOCode,'KF-KI-DVL-B-288'));
            
            % EndDevice_P_IDDesignator
            % I_O_Code
            
        end
        
    end
    
end

