function graph = cleanUpJsonGraphStruct(data)
% This helper function takes the output of MDReadJSON and parses it to a
% valid graphConfig struct. Update this function as required to account
% for JSON import quirks using the JSONLab library.
% 
% Called by MDReadJSON if a 'graph' is detected




    %% Fix empty cell "stream" structs
    if iscell(data.graph.streams)
        data.graph.streams = [data.graph.streams{:}];

        % Fix empty cell in "toPlot" struct array
        for si = 1:numel(data.graph.streams)
            if isempty(data.graph.streams(si).toPlot)
                debugout('Fixing empty toPlot struct')
                data.graph.streams(si).toPlot = cell(0);
            end
        end
    end

    %% Fix Time and String structs?
    if ~isstruct(data.graph.time.startTime)
        if isempty(data.graph.time.startTime)
            data.graph.time.startTime = struct([]);
        end
    end

    if ~isstruct(data.graph.time.stopTime)
        if isempty(data.graph.time.stopTime)
            data.graph.time.stopTime = struct([]);
        end                
    end

graph = data.graph;


