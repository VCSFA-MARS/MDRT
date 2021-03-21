%% runAllTests - execute each test in the MDRT Unit Test Suite

% Add each unit test to this list manually until the automated "testsuite"
% method is implemented. I know, this sucks.

allResults = table;

fileTests = FileNameTests;
results = run(fileTests);
allResults = vertcat(allResults, results.table);

jsonTests = MDJsonTests;
results = run(jsonTests);
allResults = vertcat(allResults, results.table);


allResults

