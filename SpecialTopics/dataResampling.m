%% Decimate TEL RRRA Data

sparsePrefix='Sparse ';


timeInterval = 1/24/12; % 5 minute interval


origFiles = {
                '/Users/nick/data/imported/2019-07-29 - TEL RRRA/data/2915 LO2 TC-2915 Temp Sensor Mon.mat';
                '/Users/nick/data/imported/2019-07-29 - TEL RRRA/data/3915 LN2 TC-3915 Temp Sensor Mon.mat';
                '/Users/nick/data/imported/2019-07-29 - TEL RRRA/data/TELHS_SYS1 LT7 Mon.mat';
                '/Users/nick/data/imported/2019-07-29 - TEL RRRA/data/TELHS_SYS1 LT8 Mon.mat';
                '/Users/nick/data/imported/2019-07-29 - TEL RRRA/data/TELHS_SYS1 PT92 Mon.mat';
                '/Users/nick/data/imported/2019-07-29 - TEL RRRA/data/TELHS_SYS2 LT9 Mon.mat';
                '/Users/nick/data/imported/2019-07-29 - TEL RRRA/data/TELHS_SYS2 LT10 Mon.mat';
                '/Users/nick/data/imported/2019-07-29 - TEL RRRA/data/TELHS_SYS2 PT94 Mon.mat'
            };



load(origFiles{end})

startTime = floor(fd.ts.Time(1));
endTime = ceil(fd.ts.Time(end));

newTimeVector = startTime:timeInterval:endTime;


for i = 1:length(origFiles)
    disp(origFiles{i})
    load(origFiles{i});
    
    newData = fd.ts.resample(newTimeVector);
    
    keyboard
end

