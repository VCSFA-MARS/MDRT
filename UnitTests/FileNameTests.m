classdef FileNameTests < matlab.unittest.TestCase

    
    properties
    end
    
    methods (Test)
        function testDataFileNameGenerator(testCase)
            fd = newFD;
            fd.ID = '1016';
            fd.Type = 'FM';
            fd.System = 'RP1';
            fd.FullString = 'RP1 FM-1016 Coriolis Meter  Mon';
            fd.isValve = false;

            fd.ts = timeseries;
            fd.ts.Name = 'RP1 FM-1016 Coriolis Meter  Mon';
            fd.ts.Time = datenum('January 1 2020'):1/24:datenum('January 2 2020');
            fd.ts.Data = 100 * rand(size(fd.ts.Time));

            actSolution = makeFileNameForFD(fd);
            expSolution = '1016 RP1 FM-1016 Coriolis Meter Mon';

            testCase.verifyEqual(actSolution, expSolution);
        end
        
        
        
    end
     
end
