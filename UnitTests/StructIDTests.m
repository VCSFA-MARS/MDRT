classdef StructIDTests < matlab.unittest.TestCase

    
    properties
    end
    
    methods (Test)
        %% FD Struct Tests - special cases, ensure well-formed and identifiable
        function testCheckFDStruct(testCase)
            fd = newFD();

            actSolution = checkStructureType(fd);
            expSolution = 'fd';

            testCase.verifyEqual(actSolution, expSolution);
        end

        function testCheckLegacyFDStruct(testCase)
            fd = newFD('version', 'v1');
            if isfield(fd, 'version')
                fd = rmfield(fd, 'version');
            end

            actSolution = checkStructureType(fd);
            expSolution = 'fd';

            testCase.verifyEqual(actSolution, expSolution);
        end
        
        function testCheckFDStructV2(testCase)
            fd = newFD('version', 'v2');

            actSolution = checkStructureType(fd);
            expSolution = 'fd';

            testCase.verifyEqual(actSolution, expSolution);
        end

        function testCheckFDStructWithNameArg(testCase)
            fd = newFD('FullString', 'MyFullstring');

            actSolution = checkStructureType(fd);
            expSolution = 'fd';

            testCase.verifyEqual(actSolution, expSolution);
        end

    end
     
end
