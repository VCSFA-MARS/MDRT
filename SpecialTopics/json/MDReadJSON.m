function [ data ] = MDReadJSON( filename, varargin )
%MDReadJSON reads a JSON text file and returns a MATLAB object or variable

%     if verLessThan('matlab', '9.1')
%     else   
%         % MATLAB builtin ?
%     end    

data = loadjson( filename, 'SimplifyCell', 1);

switch lower(char(fieldnames(data)))
    case 'graph'
        debugout('Detected graph struct, translating')
        if iscell(data.graph.streams)
            data.graph.streams = [data.graph.streams{:}];
            
            % Fix empty cell in "toPlot" struct array
            for si = 1:numel(data.graph.streams)
                if isempty(data.graph.streams(si).toPlot)
                    debugout('Fixing empty toPlot struct')
                    data.graph.streams(si).toPlot = cell(0);
                end
            end
            
            % Fix Time and String structs?
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
            
            data = data.graph;
            return
        end
        
    otherwise
        
end

end