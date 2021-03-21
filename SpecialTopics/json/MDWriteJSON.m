function [ out ] = MDWriteJSON( name, object, filename, varargin )
%MDWriteJSON saves a variable or object as a JSON text file.

%     if verLessThan('matlab', '9.1')
%     else   
%         % MATLAB builtin ?
%     end

    if isstruct(object)
        switch checkStructureType(object)
            case 'graph'
                debugout('Writing MDRT Graph to JSON')
                out = savejson('graph', object, 'FileName', filename, 'FloatFormat', '%.15g' );
                return
            otherwise
                
        end
    end
    
    debugout('writing to JSON')
    out = savejson( '', object, filename );

end

