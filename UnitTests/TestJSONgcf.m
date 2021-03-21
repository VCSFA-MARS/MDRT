%% Simple script to test JSON save/load of graph structs

outputPath = 'TestOutputFiles';
filename = fullfile(outputPath, 'testJGCF.jgcf');



graph = newGraphStructure;
graph.subplots = {'Subplot 1' 'Subplot 2'};
graph.streams(1).toPlot = {'FD 1', 'FD 2', 'FD 3'};
graph.streams(2).toPlot = {'FD 4', 'FD 5', 'FD 6'};

MDWriteJSON('', graph, filename);
newGraph = MDReadJSON(filename);

actSolution = newGraph;
expSolution = graph;

% Test that we read in the same object we wrote out
    if ~isequal(actSolution, expSolution)
        disp('Failed equality test: loaded object differs from saved object')
    end
    

% Test that subplot is the correct data type
    known  = expSolution.subplots;
    actual =  actSolution.subplots;

    if ~strcmpi( class(known), class(actual) )
        str = sprintf('Expected %s but loaded %s', class(known), class(actual));
        fprintf('Failed subplot class test: %s\n', str)
    end


% Test that streams is the correct data type

    known  = expSolution.streams;
    actual =  actSolution.streams;

    if ~strcmpi( class(known), class(actual) )
        str = sprintf('Expected %s but loaded %s', class(known), class(actual));
        fprintf('Failed streams class test: %s\n', str)
    end