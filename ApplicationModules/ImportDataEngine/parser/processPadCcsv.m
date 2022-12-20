function processPadCcsv(fileList, destFolder, autoSkip)

HEADER_LINES = 1;
disp(fileList)


% Loop through files
for f = 1:numel(fileList)
    thisFile = fileList{f};
    fid = fopen(thisFile, 'r+');
    first_line = fgetl(fid);
    
    chan_names = getChannelNames(first_line);
    
    all_data = getAllData(fid, chan_names, HEADER_LINES);
    
    fclose(fid);
    
    timeVect = makeTimeVect(all_data{1});
    
    makeFDsFromAllData(timeVect, all_data, chan_names, destFolder, autoSkip);
    
end



end



%% Supporting Functions

function makeFDsFromAllData(timeVect, data, chans, saveTo, skipError)
    numChans = numel(chans);
    progressbar('Processing Pad-0C Data')
    
    for c = 1:numChans
        if any(contains(chans(c), {'Time', 'EpochTime'}, 'IgnoreCase', true))
            continue
        end
        
        fd = newFD;
        fd.Name = chans{c};
        
        dataVect = makeDataVect(data{c});
        
        fd.ts = timeseries(dataVect, timeVect, 'Name', chans{c});
        
        filename = fullfile(saveTo, makeFileNameForFD(fd));
        
        save(filename, 'fd');
        
        progressbar(c/numChans)
        
    end


end

function dataVect = makeDataVect(data_cell)

data_type = '';
    try
        dataVect = str2double(data_cell);
        data_type = 'numeric';
        return
    catch
    end
    
    if isempty(data_type)
        switch(lower(data_cell{1}))
            case { 'true' 'on' 'false' 'off' 'yes' 'no' }
                % treat as bool
                trues = {'true', 'on', 'yes'};
                falses = {'false', 'off', 'no'};
                
                false_inds = find(contains(data_cell, falses));
                true_inds =  find(contains(data_cell, trues));
                
                dataVect = false(numRows, 1);
                dataVect(true_inds) = true;
                
                data_type = 'bool';
                
        end
    end
    return
end


function timeVect = makeTimeVect(data_cell)
    timeVect = datenum(data_cell, 'yyyy-mm-ddTHH:MM:SS.FFF');
end



function datacell = getAllData(fileID, chan_name_cell, header_lines)
    num_cols = numel(chan_name_cell);
    
    fmt_cell = repmat({'%s'},1,num_cols);
    
    byte_chans = getByteChannelInds(chan_name_cell);
    fmt_cell(byte_chans) = {'%[^,]'};
    
    fmt_str = strip([fmt_cell{:}]);

    frewind(fileID);
    datacell = textscan(fileID, fmt_str, 'HeaderLines', header_lines, 'Delimiter', ',');
    
end


function channels = getChannelNames(headerStr)

    channels = textscan(headerStr, '%s', 'delimiter', ',');
    channels = channels{1};

end

function byte_chan_inds = getByteChannelInds(chan_names)
    byte_chan_inds = find(contains(chan_names, 'Packet_TimeStamp', 'IgnoreCase', true));
end
