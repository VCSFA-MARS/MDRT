function [ out ] = MDWriteJSON( name, object, filename, varargin )
%MDWriteJSON saves a variable or object as a JSON text file.

%     if verLessThan('matlab', '9.1')
%     else   
%         % MATLAB builtin ?
%     end

        out = savejson( name, object, filename );

end

