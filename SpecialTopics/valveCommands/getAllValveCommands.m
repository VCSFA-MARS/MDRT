%% getAllValveCommands: Generate table of all valve commands sent during a data set

dataFolders = '/Users/nick/data/archive/2021-02-19 - NG-15 Launch/data';
    
filesCommand = {
        '1003 RP1 DCVNC-1003 Ball Valve Ctl Param.mat';
        '1010 RP1 DCVNC-1010 Ball Valve Ctl Param.mat';
        '1021 RP1 DCVNC-1021 Ball Valve Ctl Param.mat';
        '1022 RP1 DCVNO-1022 Ball Valve Ctl Param.mat';
        '1023 RP1 DCVNC-1023 Ball Valve Ctl Param.mat';
        '1024 RP1 DCVNC-1024 Ball Valve Ctl Param.mat';
        '2002 LO2 DCVNC-2002 Ball Valve Ctl Param.mat';
        '2006 LO2 DCVNC-2006 Ball Valve Ctl Param.mat';
        '2010 LO2 DCVNO-2010 Ball Valve Ctl Param.mat';
        '2027 LO2 DCVNO-2027 Ball Valve Ctl Param.mat';
        '2031 LO2 DCVNC-2031 Ball Valve Ctl Param.mat';
        '2032 LO2 DCVNO-2032 Ball Valve Ctl Param.mat';
        '2035 LO2 DCVNO-2035 Ball Valve Ctl Param.mat';
        '2040 LO2 DCVNO-2040 Ball Valve Ctl Param.mat';
        '2056 LO2 DCVNC-2056 Ball Valve Ctl Param.mat';
        '2067 LO2 DCVNO-2067 Ball Valve Ctl Param.mat';
        '2093 LO2 DCVNC-2093 Ball Valve Ctl Param.mat';
        '2096 LO2 DCVNC-2096 Ball Valve Ctl Param.mat';
        '2097 LO2 DCVNC-2097 Ball Valve Ctl Param.mat';
        '2099 LO2 DCVNO-2099 Ball Valve Ctl Param.mat';
        '3009 LN2 DCVNC-3009 Ball Valve Ctl Param.mat';
        '3010 LN2 DCVNC-3010 Ball Valve Ctl Param.mat';
        '3014 LN2 DCVNC-3014 Ball Valve Ctl Param.mat';
        '3015 LN2 DCVNC-3015 Ball Valve Ctl Param.mat';
        '3025 LN2 DCVNC-3025 Ball Valve Ctl Param.mat';
        '3026 LN2 DCVNO-3026 Ball Valve Ctl Param.mat';
        '3051 LN2 DCVNC-3051 Ball Valve Ctl Param.mat';
        '3056 LN2 DCVNO-3056 Ball Valve Ctl Param.mat';
        '3066 LN2 DCVNC-3066 Ball Valve Ctl Param.mat';
        '3068 LN2 DCVNO-3068 Ball Valve Ctl Param.mat';
        '3092 LN2 DCVNC-3092 Ball Valve Ctl Param.mat';
        '3131 LN2 DCVNO-3131 Ball Valve Ctl Param.mat';
        '4061 Ghe DCVNO-4061 Ball Valve Ctl Param.mat';
        '4062 Ghe DCVNO-4062 Ball Valve Ctl Param.mat';
        '4063 Ghe DCVNC-4063 Ball Valve Ctl Param.mat';
        '4070 Ghe DCVNC-4070 Ball Valve Ctl Param.mat';
        '4083 Ghe DCVNC-4083 Ball Valve Ctl Param.mat';
        '4084 Ghe DCVNC-4084 Ball Valve Ctl Param.mat';
        '4085 Ghe DCVNC-4085 Ball Valve Ctl Param.mat';
        '4089 Ghe DCVNO-4089 Ball Valve Ctl Param.mat';
        '4106 Ghe DCVNC-4106 Ball Valve Ctl Param.mat';
        '4183 Ghe DCVNC-4183 Ball Valve Ctl Param.mat';
        '4193 Ghe DCVNC-4193 Ball Valve Ctl Param.mat';
        '5015 GN2 DCVNC-5015 Ball Valve Ctl Param.mat';
        '5047 GN2 DCVNO-5047 Ball Valve Ctl Param.mat';
        '5078 GN2 DCVNC-5078 Ball Valve Ctl Param.mat';
        '5079 GN2 DCVNO-5079 Ball Valve Ctl Param.mat';
        '5106 GN2 DCVNC-5106 Ball Valve Ctl Param.mat';
        '5126 GN2 DCVNC-5126 Ball Valve Ctl Param.mat';
        '5127 GN2 DCVNC-5127 Ball Valve Ctl Param.mat';
        '5178 GN2 DCVNO-5178 Ball Valve Ctl Param.mat';
        '5179 GN2 DCVNO-5179 Ball Valve Ctl Param.mat';
        '5198 GN2 DCVNC-5198 Ball Valve Ctl Param.mat';
        '5245 ECS DCVNC-5245 Ball Valve Ctl Param.mat';
        '5463 GN2 DCVNO-5463 Ball Valve Ctl Param.mat';
        '5464 GN2 DCVNC-5464 Ball Valve Ctl Param.mat';
        '8020 HSS DCVNO-8020 Ball Valve Ctl Param.mat';
        '8021 HSS DCVNO-8021 Ball Valve Ctl Param.mat';
        '8030 HSS DCVNC-8030 Ball Valve Ctl Param.mat';
        '8031 HSS DCVNC-8031 Ball Valve Ctl Param.mat';
        '8032 HSS DCVNC-8032 Ball Valve Ctl Param.mat';
        };
    
propCommand = {
        '1014 RP1 PCVNC-1014 Globe Valve Cmd Param.mat';
        '1015 RP1 PCVNC-1015 Globe Valve Cmd Param.mat';
        '1049 RP1 PCVNC-1049 Globe Valve Cmd Param.mat';
        '2013 LO2 PCVNO-2013 Globe Valve Cmd Param.mat';
        '2014 LO2 PCVNO-2014 Globe Valve Cmd Param.mat';
        '2029 LO2 PCVNO-2029 Globe Valve Cmd Param.mat';
        '2059 LO2 PCVNC-2059 Globe Valve Cmd Param.mat';
        '2069 LO2 PCVNC-2069 Globe Valve Cmd Param.mat';
        '2220 LO2 PCVNO-2220 Globe Valve Cmd Param.mat';
        '2221 LO2 PCVNC-2221 Globe Valve Cmd Param.mat';
        '3021 LN2 PCVNC-3021 Globe Valve Cmd Param.mat';
        '3028 LN2 PCVNC-3028 Globe Valve Cmd Param.mat';
        '3055 LN2 PCVNC-3055 Globe Valve Cmd Param.mat';
        '3070 LN2 PCVNC-3070 Globe Valve Cmd Param.mat';
        '3086 LN2 PCVNC-3086 Globe Valve Cmd Param.mat';
        '4168 Ghe PCVNC-4168 Globe Valve Cmd Param.mat';
        '5256 ECS PCVNC-5256 Globe Valve Cmd Param.mat';
        '5258 ECS PCVNC-5258 Globe Valve Cmd Param.mat';
        '0003 AIR RV-0003 Positioner Cmd Param.mat';
        '0004 AIR RV-0004 Positioner Cmd Param.mat';
        };
    
    
%% Pressure Sensor FDs

filesPressure = { 
        '5903 GN2 PT-5903 Press Sensor Mon.mat';
        '5070 GN2 PT-5070 Press Sensor Mon.mat';
        '5930 GN2 PT-5930 Press Sensor Mon.mat';
    };    
    

%% Load All Command Data

filesCommand    = unique(sort([filesCommand; propCommand]));
totalValves = numel(filesCommand);
    

% allData = cell(totalValves,1);
allData = [];

for fi = 1:totalValves
    
    [s, e] = regexp(filesCommand{fi}, '[DP]CVN[CO]-\d*');
    findNumber = filesCommand{fi}(s:e);
    
    thisFile = fullfile(dataFolders, filesCommand{fi});
    
    if ~ exist(thisFile, 'file')
        fprintf('Skipping %s - File not found\n', findNumber);
        continue
    end
    
    load(thisFile);
    
    allData = vertcat(allData, fd.ts);
    
end


%% Find every command change



dataStruct = [];
numAllData = length(allData);
oneData = 1/numAllData;

progressbar('Valve', 'Command');
for di = 1:length(allData)
    
    thisCommand = allData(di).Data;
    thisTime    = allData(di).Time;
    thisName    = allData(di).Name;

    changeInds = [  1; 
                    find([0;diff(thisCommand)]) ; 
                    length(thisCommand) ];

    valveProg = di / length(allData) - oneData;
    
    for n = 1:length(changeInds)

        thisInd = changeInds(n);

        param = thisCommand(thisInd);
        time  = thisTime(thisInd);
        
        trimIndex = strfind(thisName, 'Param') - 2;
        

        thisStruct = struct('ValveName',            thisName, ...
                            'ValveCommand',         thisName(1:trimIndex), ...
                            'CommandTime',          time, ...
                            'CommandTimeXl',        m2xdate(time), ...
                            'CommandTimeString',    datestr(time, 'HH:MM:SS.FFF'), ...
                            'CommandParam',         param ...
                        );
                    

        dataStruct = vertcat(dataStruct, thisStruct);
        
        commandProg = n / length(changeInds);
        progressbar(valveProg + (commandProg*oneData), commandProg);
    end
    
end


valveTable = struct2table(dataStruct);


% writetable(valveTable, 'NG-15_ValveCommands.csv');