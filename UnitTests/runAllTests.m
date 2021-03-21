%% runAllTests - execute each test in the MDRT Unit Test Suite

% Add each unit test to this list manually until the automated "testsuite"
% method is implemented. I know, this sucks.


fileTests = FileNameTests;
results = run(fileTests)

jsonTests = MDJsonTests;
results = run(jsonTests)



