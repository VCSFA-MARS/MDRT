%% Decimate TEL RRRA Data

sparsePrefix='Sparse ';


timeInterval = 1/24/12; % 5 minute interval


origFiles = {
<<<<<<< Updated upstream
                '/Users/nick/data/imported/2019-07-29 - TEL RRRA/data/2915 LO2 TC-2915 Temp Sensor Mon.mat';
                '/Users/nick/data/imported/2019-07-29 - TEL RRRA/data/3915 LN2 TC-3915 Temp Sensor Mon.mat';
                '/Users/nick/data/imported/2019-07-29 - TEL RRRA/data/TELHS_SYS1 LT7 Mon.mat';
                '/Users/nick/data/imported/2019-07-29 - TEL RRRA/data/TELHS_SYS1 LT8 Mon.mat';
                '/Users/nick/data/imported/2019-07-29 - TEL RRRA/data/TELHS_SYS1 PT92 Mon.mat';
                '/Users/nick/data/imported/2019-07-29 - TEL RRRA/data/TELHS_SYS2 LT9 Mon.mat';
                '/Users/nick/data/imported/2019-07-29 - TEL RRRA/data/TELHS_SYS2 LT10 Mon.mat';
                '/Users/nick/data/imported/2019-07-29 - TEL RRRA/data/TELHS_SYS2 PT94 Mon.mat'
            };

=======
		'/Users/engineer/Imported Data Repository/2019-07-29 - TELHS RRRA Data/data/2915 LO2 TC-2915 Temp Sensor Mon.mat';
		'/Users/engineer/Imported Data Repository/2019-07-29 - TELHS RRRA Data/data/3915 LN2 TC-3915 Temp Sensor Mon.mat';
		'/Users/engineer/Imported Data Repository/2019-07-29 - TELHS RRRA Data/data/TELHS_SYS1 LT7 Mon.mat';
		'/Users/engineer/Imported Data Repository/2019-07-29 - TELHS RRRA Data/data/TELHS_SYS1 LT8 Mon.mat';
		'/Users/engineer/Imported Data Repository/2019-07-29 - TELHS RRRA Data/data/TELHS_SYS1 PT92 Mon.mat';
		'/Users/engineer/Imported Data Repository/2019-07-29 - TELHS RRRA Data/data/TELHS_SYS2 LT9 Mon.mat';
		'/Users/engineer/Imported Data Repository/2019-07-29 - TELHS RRRA Data/data/TELHS_SYS2 LT10 Mon.mat';
		'/Users/engineer/Imported Data Repository/2019-07-29 - TELHS RRRA Data/data/TELHS_SYS2 PT94 Mon.mat'
	};
>>>>>>> Stashed changes


load(origFiles{end})

startTime = floor(fd.ts.Time(1));
endTime = ceil(fd.ts.Time(end));

newTimeVector = startTime:timeInterval:endTime;


for i = 1:length(origFiles)
    disp(origFiles{i})
    load(origFiles{i});
    
    newData = fd.ts.resample(newTimeVector);
    
<<<<<<< Updated upstream
    keyboard
end

=======
    newData.Name = [sparsePrefix, newData.Name]
    fd.ts = newData
    fd.FullString = newData.Name 
    
    
    [PATHSTR,NAME,EXT] = fileparts(origFiles{i});
    newFileName=[sparsePrefix, NAME];
    
    save(fullfile(PATHSTR, [newFileName, EXT]), 'fd')
    
end

%% Make Excel File

sparseFiles = {
	'/Users/engineer/Imported Data Repository/2019-07-29 - TELHS RRRA Data/data/Sparse 2915 LO2 TC-2915 Temp Sensor Mon.mat';
	'/Users/engineer/Imported Data Repository/2019-07-29 - TELHS RRRA Data/data/Sparse 3915 LN2 TC-3915 Temp Sensor Mon.mat';
	'/Users/engineer/Imported Data Repository/2019-07-29 - TELHS RRRA Data/data/Sparse TELHS_SYS1 LT7 Mon.mat';
	'/Users/engineer/Imported Data Repository/2019-07-29 - TELHS RRRA Data/data/Sparse TELHS_SYS1 LT8 Mon.mat';
	'/Users/engineer/Imported Data Repository/2019-07-29 - TELHS RRRA Data/data/Sparse TELHS_SYS1 PT92 Mon.mat';
	'/Users/engineer/Imported Data Repository/2019-07-29 - TELHS RRRA Data/data/Sparse TELHS_SYS2 LT9 Mon.mat';
	'/Users/engineer/Imported Data Repository/2019-07-29 - TELHS RRRA Data/data/Sparse TELHS_SYS2 LT10 Mon.mat';
	'/Users/engineer/Imported Data Repository/2019-07-29 - TELHS RRRA Data/data/Sparse TELHS_SYS2 PT94 Mon.mat'
};

% tomsData = cell(length(newTimeVector) + 1, length(sparseFiles) +1 );

tomsData = zeros(length(newTimeVector), length(sparseFiles) +1 );

% Populate date column
tomsData(:, 1)=m2xdate(newTimeVector);
headerRow = cell(1, length(sparseFiles) +1);

headerRow{1,1}='time';

for n = 1:length(sparseFiles)
    
    col = n + 1;
    
    load(sparseFiles{n});
	 
    tomsData(:, col) = fd.ts.Data;
    
    headerRow{1,col} = [fd.Type, fd.ID];
    
end


tomsData = num2cell(tomsData);
tomsTable = cell2table(tomsData);
tomsTable.Properties.VariableNames = headerRow;

writetable(tomsTable, 'TELHS_RRRA_Data.csv')



>>>>>>> Stashed changes
