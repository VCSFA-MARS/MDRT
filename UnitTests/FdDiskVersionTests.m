classdef FdDiskVersionTests < matlab.unittest.TestCase

    properties
        fd
        test_data_folder = './TestData';
        test_file
    end

    methods (TestClassSetup)
        % Shared setup for the entire test class
        function makeTimeseries(testCase)
            yesterday = floor(now) - 1;
            oneHour = 1/24;
            oneMin = oneHour/60;
            oneSec = oneMin/60;
    
            start = yesterday + (8*oneHour);
            stop  = start * (2 * oneHour);
            interval = 15 * oneSec;

            data_name = 'FCS SV-1234 Command Param';

            Time = start:interval:stop;
            Data = randi(1, size(Time), 'logical');

            ts = timeseries(Data, Time, 'Name', data_name);
            ts.DataInfo.Units = 'my_units';

            this_fd = newFD('FullString', data_name);
            this_fd.ID = 1234;
            this_fd.System = 'FCS';
            this_fd.Type = 'SV';
            this_fd.isValve = true;
            this_fd.ts = ts;

            testCase.fd = this_fd;

            test_file = fullfile(testCase.test_data_folder, ...
                [makeFileNameForFD(this_fd.FullString), '.mat']);

        end
    end

    methods (TestMethodSetup)
        % Setup for each test
        function delete_old_test_file(testCase)
            if exist(testCase.test_file, 'file')
                delete(testCase.test_file);
            end
        end
    end

    methods (Test)
        % Test methods
        function testSaveFDLegacy(testCase)
            disp(pwd)
            disp(testCase.test_data_folder)
            assert(isfolder(testCase.test_data_folder))

            save_fd_to_disk(testCase.fd, 'folder', testCase.test_data_folder);
            
            actSolution = load_fd_by_name(testCase.fd.FullString, 'folder', testCase.test_data_folder);
            expSolution = testCase.fd;

            exp_fields = fieldnames(expSolution);
            act_fields = fieldnames(actSolution);

            for f = 1:length(exp_fields)
                exp_field = exp_fields{f};
                assert(ismember(exp_field, act_fields));
                if (strcmp(exp_field, 'fd'))
                    continue
                end
                testCase.verifyEqual(expSolution.(exp_field), actSolution.(exp_field));
            end

            testCase.verifyEqual(actSolution.ts.Time, expSolution.ts.Time);
            testCase.verifyEqual(actSolution.ts.Data, expSolution.ts.Data);
            testCase.verifyEqual(actSolution.ts.Name, expSolution.ts.Name);
            testCase.verifyEqual(actSolution.ts.DataInfo.Units, expSolution.ts.DataInfo.Units);

        end
        
        function testCheckFDStructV2(testCase)

            save_fd_to_disk(testCase.fd,        ...
                'disk-version',           'v2', ...
                'folder',                 testCase.test_data_folder);
            
            actSolution = load_fd_by_name(testCase.fd.FullString, 'folder', testCase.test_data_folder);
            expSolution = testCase.fd;

            exp_fields = fieldnames(expSolution);
            act_fields = fieldnames(actSolution);

            for f = 1:length(exp_fields)
                exp_field = exp_fields{f};
                assert(ismember(exp_field, act_fields));
                if (strcmp(exp_field, 'fd'))
                    continue
                end
                testCase.verifyEqual(expSolution.(exp_field), actSolution.(exp_field));
            end

            testCase.verifyEqual(actSolution.ts.Time, expSolution.ts.Time);
            testCase.verifyEqual(actSolution.ts.Data, expSolution.ts.Data);
            testCase.verifyEqual(actSolution.ts.Name, expSolution.ts.Name);
            testCase.verifyEqual(actSolution.ts.DataInfo.Units, expSolution.ts.DataInfo.Units);

        end

    end

end