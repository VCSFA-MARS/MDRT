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

        function testCheckFDStructWithNameArg(testCase)
            fd = newFD('FullString', 'MyFullstring');

            actSolution = checkStructureType(fd);
            expSolution = 'fd';

            testCase.verifyEqual(actSolution, expSolution);
        end

        function testGraphStruct(testCase)
            graph = newGraphStructure;

            actSolution = checkStructureType(graph);
            expSolution = 'graph';

            testCase.verifyEqual(actSolution, expSolution);
        end

    end
     
end
