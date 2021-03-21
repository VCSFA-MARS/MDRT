classdef MDJsonTests < matlab.unittest.TestCase
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    %   http://10.1.7.74/data-review/MDRT/wikis/unit-testing
    
    properties
        graph
        newGraph
    end
    
    
    
    methods(TestMethodSetup)
        function createGraphStruct(testCase)
            
            graph = newGraphStructure;
            graph.subplots = {'Subplot 1' 'Subplot 2'};
            graph.streams(1).toPlot = {'FD 1', 'FD 2', 'FD 3'};
            graph.streams(2).toPlot = {'FD 4', 'FD 5', 'FD 6'};
            
            testCase.graph = graph;
            
            MDWriteJSON('', graph, 'testJGCF.jgcf');
            testCase.newGraph = MDReadJSON('testJGCF.jgcf');
            
        end
    end

    
    methods (Test)
        function saveLoadGraph2streams(testCase)
            actSolution = testCase.newGraph;
            expSolution = testCase.graph;
        
            % Test that we read in the same object we wrote out
                testCase.verifyEqual(actSolution, expSolution);
        end
        
        function loadGraphStreams(testCase)
            % Test that streams is the correct data type

            known  =  testCase.graph.streams;
            actual =  testCase.newGraph.streams;
            knownClass = class(known);

            testCase.verifyClass( actual, knownClass )
        end
        
        function loadGraphSubplots(testCase)
            % Test that subplot is the correct data type
            known  =  testCase.graph.subplots;
            actual =  testCase.newGraph.subplots;
            knownClass = class(known);

            testCase.verifyClass( actual, knownClass )
        end
        
        function loadGraphWithStopEvent(testCase)
            graph = testCase.graph;
            
            startTime = struct( 'String',   'Some FD Name', ...
                                'Time',     now() );
            
            graph.time.startTime = startTime;
            
            MDWriteJSON('', graph, 'testJGCF.jgcf');
            newGraph = MDReadJSON('testJGCF.jgcf');
            
            oneSecond = 24*60*60;
            oneMillisecond = oneSecond / 1000;
            
            testCase.verifyEqual(newGraph, graph, 'AbsTol', oneMillisecond/2 );
            
        end
        
    end
    
end