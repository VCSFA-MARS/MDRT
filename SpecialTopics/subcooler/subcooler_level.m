classdef subcooler_level
    %UNTITLED3 Summary of this class goes here
    %   Detailed explanation goes here

    properties
        sub_chart
    end

    methods
        function obj = subcooler_level()
            %UNTITLED3 Construct an instance of this class
            %   Detailed explanation goes here
            s = load('sub_level_data.mat');
            obj.sub_chart = s.sub_chart;
        end

        function outputArg = method1(obj,inputArg)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            outputArg = obj.sub_chart + inputArg;
        end
    end
end