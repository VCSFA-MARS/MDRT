function [ out ] = MDWriteJSON( name, object, filename, varargin )
%MDWriteJSON saves a variable or object as a JSON text file.

    out = savejson( name, object, filename );

end

