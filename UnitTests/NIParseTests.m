classdef NIParseTests < matlab.unittest.TestCase
    % Unit test cases for NIParse object
    %   
    
    properties
        
    end
    
    properties (Constant)
        UnitTestPath 	= fileparts(mfilename('fullpath'));                 % Path to unit test directory
        TestFileFolder  = fullfile(NIParseTests.UnitTestPath, 'TestData'); 	% Path to unit test data folder
        
        TestFileGood 	= 'PADC_IO.xlsx';                                   % Nominal NI IO Decoder spreadsheet
        TestFileEmpty   = 'Empty.xlsx';                                     % Spreadsheet file with no contents
        TestFileBogus   = 'Nonexistant.xlsx';                               % Filename that does not exist
        
        IOSpreadsheet   = fullfile(NIParseTests.TestFileFolder, 'PADC_IO.xlsx'); % Fullfile to production IO Spreadsheet
    end
    
    methods (Test)
    
        function TestFileNotFound(testCase)
            % Verify that IOspreadsheet2table returns empty table if file
            % not found
            fileToTest = fullfile(NIParseTests.TestFileFolder, NIParseTests.TestFileBogus);
            IOTable = NIParser.IOspreadsheet2table(fileToTest);
            testCase.verifyEmpty(IOTable)
        end
        
        function TestFileIsEmpty(testCase)
            % Verify that IOspreadsheet2table returns empty table if file
            % contains an empty spreadsheet
            fileToTest = fullfile(NIParseTests.TestFileFolder, NIParseTests.TestFileEmpty);
            IOTable = NIParser.IOspreadsheet2table(fileToTest);
            testCase.verifyEmpty(IOTable)
        end
        
        function ReadNormal_IO_Spreadsheet(testCase)
            % Verify that IOspreadsheet2table returns empty table if file
            % contains an empty spreadsheet
            fileToTest = fullfile(NIParseTests.TestFileFolder, NIParseTests.TestFileGood);
            IOTable = NIParser.IOspreadsheet2table(fileToTest);
            testCase.verifyNotEmpty(IOTable)
        end
    
    end

end

