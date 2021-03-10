classdef TestMDJson < matlab.unittest.TestCase
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    %   http://10.1.7.74/data-review/MDRT/wikis/unit-testing
    
    properties
    end
    
    methods (Test)
        function saveLoadGraph2streams(testCase)
            graph = newGraphStructure;
            graph.subplots = {'Subplot 1' 'Subplot 2'};
            graph.streams(1).toPlot = {'FD 1', 'FD 2', 'FD 3'};
            graph.streams(2).toPlot = {'FD 4', 'FD 5', 'FD 6'};
            
            MDWriteJSON('', graph, 'testJGCF.jgcf');
            
            newGraph = MDReadJSON('testJGCF.jgcf');
            
            actSolution = newGraph;
            expSolution = graph;
        
            testCase.verifyEqual(actSolution, expSolution);
            testCase.verifyClass(expSolution.subplots,  actSolution.subplots,   class(expSolution.subplots) )
            testCase.verifyClass(expSolution.streams,   actSolution.streams,    class(expSolution.streams))
        end
    end
    
end